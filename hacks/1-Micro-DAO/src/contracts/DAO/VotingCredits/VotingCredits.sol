pragma solidity ^0.6.8;

import "./VotingCreditsFactory.sol";
import "./lib/MiniMeToken.sol";

contract VotingCredits is MiniMeToken {
  /// @notice Constructor to create a VotingCredits
  /// @param _tokenFactory The address of the VotingCreditsFactory contract that
  ///  will create the Clone token contracts, the token factory needs to be
  ///  deployed first
  /// @param _parentToken Address of the parent token, set to 0x0 if it is a
  ///  new token
  /// @param _parentSnapShotBlock Block of the parent token that will
  ///  determine the initial distribution of the clone token, set to 0 if it
  ///  is a new token
  /// @param _tokenName Name of the new token
  /// @param _decimalUnits Number of decimals of the new token
  /// @param _tokenSymbol Token Symbol for the new token
  function VotingCredits(
    address _tokenFactory,
    address _parentToken,
    uint _parentSnapShotBlock,
    string _tokenName,
    uint8 _decimalUnits,
    string _tokenSymbol
  ) public {
    tokenFactory = MiniMeTokenFactory(_tokenFactory);
    name = _tokenName;                                 // Set the name
    decimals = _decimalUnits;                          // Set the decimals
    symbol = _tokenSymbol;                             // Set the symbol
    parentToken = MiniMeToken(_parentToken);
    parentSnapShotBlock = _parentSnapShotBlock;
    transfersEnabled = false;
    creationBlock = block.number;
  }

  /// @notice Creates a new clone token with the initial distribution being
  ///  this token at `_snapshotBlock`
  /// @param _cloneTokenName Name of the clone token
  /// @param _cloneDecimalUnits Number of decimals of the smallest unit
  /// @param _cloneTokenSymbol Symbol of the clone token
  /// @param _snapshotBlock Block when the distribution of the parent token is
  ///  copied to set the initial distribution of the new clone token;
  ///  if the block is zero than the actual block, the current block is used
  /// @param _transfersEnabled True if transfers are allowed in the clone
  /// @return The address of the new MiniMeToken Contract
  function createCloneToken(
    string _cloneTokenName,
    uint8 _cloneDecimalUnits,
    string _cloneTokenSymbol,
    uint _snapshotBlock,
    bool _transfersEnabled
  ) public returns(address) {
    if (_snapshotBlock == 0) _snapshotBlock = block.number;
    MiniMeToken cloneToken = tokenFactory.createCloneToken(
      this,
      _snapshotBlock,
      _cloneTokenName,
      _cloneDecimalUnits,
      _cloneTokenSymbol,
      false
    );

    cloneToken.changeController(msg.sender);

    // An event to make the token easy to find on the blockchain
    NewCloneToken(address(cloneToken), _snapshotBlock);
    return address(cloneToken);
  }
}
