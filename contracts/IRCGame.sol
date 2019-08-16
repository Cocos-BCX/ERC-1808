pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2; 

interface IRCGame {
    event AddGame(address indexed addAddress, uint256 indexed gameId, string gameName);
    event ChangeGameState(address indexed businessAddress, uint256 indexed gameId, bool indexed state);
    event ChangeGameExtAttrCount(address indexed businessAddress, uint256 indexed gameId, uint256 indexed extAttrCount);
    event ChangeTokenExtAttr(address indexed businessAddress,uint256 indexed gameId, uint256 indexed tokenId, uint256 index, string extData );
    event ChangeTokenExtAttrs(address indexed businessAddress,uint256 indexed gameId, uint256 indexed tokenId, string[] extDatas );

    /// @notice add new game.
    /// @dev  Throws if the length of `_gameName` less than zero.
    /// Throws if the length of `_gameName` is greater than 32.
    /// Throws unless an authorized operator of the current owner.
    /// @param _gameName The new game name.
    /// @param _extAttrCount The NFT extra attribute's count.
    function addGame(string memory _gameName, uint256 _extAttrCount) public;
    
    /// @notice set game state.
    /// @dev  Throws if the `_state` equal to the game state.
    /// Throws if the `_gameId` is valid.
    /// Throws unless an authorized operator of the current owner.
    /// @param `_gameId` The game id.
    /// @param `_state` The game state.
    function setGameState(uint256 _gameId, bool _state) public;

    /// @notice set game extra attribute's count.
    /// @dev  Throws if the `_extAttrCount` less than the game extAttrCount.
    /// Throws if the `_gameId` is valid.
    /// Throws unless an authorized operator of the current owner.
    /// @param `_gameId` The game id.
    /// @param `_extAttrCount` The NFT extra attribute's count.
    function setGameExtAttrCount(uint256 _gameId, uint256 _extAttrCount) public;

    /// @notice get games info.
    /// @return gameIds, gameNames and flags
    function getGames() public view returns(uint256[] memory gameId,string[] memory gameName, bool[] memory flags);

    /// @notice get game counts.
    /// @return the game counts.
    function getGameCount() public view returns(uint256);
    
    /// @notice get game.
    /// @dev  Throws if the `_gameId` - 1 is greater than the game array length.
    /// Throws if the `_gameId` less than 0.
    /// @param `_gameId` The game id.
    /// @return the game name and state.
    function getGame(uint256 _gameId) public view returns(string memory gameName, bool state);

    /// @notice check the game state.
    /// @dev  Throws if the `_gameId` - 1 is greater than the game array length.
    /// Throws if the `_gameId` less than 0.
    /// @param `_gameId` The game id.
    /// @return the game state.
    function isEnableGame(uint256 _gameId) public view returns(bool flag);

    /// @notice set the game extra data.
    /// @dev  Throws if the `_gameId` - 1 is greater than the game array length.
    /// Throws if the contract is paused.
    /// Throws if the `_gameId` is valid.
    /// Throws if the `_tokenId` is valid.
    /// Throws if the `_index` is greater than the game extra attribute count.
    /// Throws if the game extra data count less than 0.
    /// @param `_gameId` The game id.
    /// @param `_tokenId` The token id.
    /// @param `_index` The array index.
    /// @param `_extData` The extra data.
    function setExtData(uint256 _gameId, uint256 _tokenId, uint256 _index, string memory _extData) public;

    /// @notice set the game extra data.
    /// @dev  Throws if the `_gameId` - 1 is greater than the game array length.
    /// Throws if the contract is paused.
    /// Throws if the `_gameId` is valid.
    /// Throws if the `_tokenId` is valid.
    /// Throws if the lenght of `_extDataArray` is greater than the game extra attribute count.
    /// Throws if the lenght of `_extDataArray` less than 0.
    /// Throws if the game extra data count less than 0.
    /// @param `_gameId` The game id.
    /// @param `_tokenId` The token id.
    /// @param `_extDataArray` The array of extra data.
    function setExtData(uint256 _gameId, uint256 _tokenId, string[] memory _extDataArray) public;

    /// @notice get the game extra data.
    /// @param `_gameId` The game id.
    /// @param `_tokenId` The token id.
    /// @param `_index` The array index.
    /// @return the game tokenAttr.
    function getExtData(uint256 _gameId, uint256 _tokenId, uint256 _index) public view  returns(string memory tokenAttr);

    /// @notice get all game extra datas
    /// @dev  Throws if the `_gameId` is valid.
    /// Throws if the `_tokenId` is valid.
    /// Throws if the game extra data count less than 0.
    /// @param `_gameId` The game id.
    /// @param `_tokenId` The token id.
    /// @return the game attributes.
    function getExtDatas(uint256 _gameId, uint256 _tokenId) public view isValidToken(_tokenId) isValidGameId(_gameId) returns(string[] memory attrs);
}
