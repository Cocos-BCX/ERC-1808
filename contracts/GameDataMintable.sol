pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2; 

contract MyERC1808 {
    function getAuthorized(uint256 _tokenId) external view returns (address);
    function isAuthorizedForAll(address _owner, address _operator) external view returns (bool);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function isPaused() external view returns (bool); 
    function businessAdmin(address _address ) external view returns (bool);
    function getFashionArrayLength() external view returns (uint256);
    function getBusinessAdmin(address _businessAdmin) external view returns(bool);
}

contract AccessAdmin1 {
     
    address public myERC1808Addr = 0x74b3926AA4D22247540e5578D15BF221ADdf8B44;
    MyERC1808 myERC1808 = MyERC1808(myERC1808Addr);
   
    modifier onlyBusinessAdmin() {
        require(myERC1808.getBusinessAdmin(msg.sender), "不是业务管理员");
        _;
    }
    modifier whenNotPaused() {
        require(!myERC1808.isPaused(), "合约已经冻结");
        _;
    }

    modifier whenPaused() {
        require(myERC1808.isPaused(), "合约没有冻结");
        _;
    }
    
    modifier isValidToken(uint256 _tokenId) {
        require(_tokenId >= 1 && _tokenId <= myERC1808.getFashionArrayLength(), "");
        require(myERC1808.ownerOf(_tokenId) != address(0), "");
        _;
    }
}

contract MyGameData1 is AccessAdmin1, IRCGame {

    struct Game {
        string gameName;
        uint256 extAttrCount; /// 扩展属性个数
        bool state;
    }
    
    mapping(uint256 => Game) gameIdToGame;
    Game[] public gameArray;
    mapping(uint256 => mapping(uint256 =>string[])) gameIdToTokenAttr;

    event AddGame(address indexed addAddress, uint256 indexed gameId, string gameName);
    event ChangeGameState(address indexed businessAddress, uint256 indexed gameId, bool indexed state);
    event ChangeGameExtAttrCount(address indexed businessAddress, uint256 indexed gameId, uint256 indexed extAttrCount);
    event ChangeTokenExtAttr(address indexed businessAddress,uint256 indexed gameId, uint256 indexed tokenId, uint256 index, string extData );
    event ChangeTokenExtAttrs(address indexed businessAddress,uint256 indexed gameId, uint256 indexed tokenId, string[] extDatas );
   
    modifier isValidGameId(uint256 _gameId) {
        require(_gameId >= 1 && _gameId <= gameArray.length, "");
        _;
    }

    function addGame(string memory _gameName, uint256 _extAttrCount) public onlyBusinessAdmin {
        require(bytes(_gameName).length > 0,"");
        require(bytes(_gameName).length <= 32,"");
        uint256 newGameId = gameArray.length + 1;
        require(newGameId < 4294967296 && newGameId > 0, "");
        gameArray.length += 1;
        Game storage game = gameArray[newGameId - 1];
        game.gameName = _gameName;
        game.extAttrCount = _extAttrCount;
        game.state = true;
        gameIdToGame[newGameId] = game;
        emit AddGame(msg.sender, newGameId, _gameName);
    }

    function setGameState(uint256 _gameId, bool _state) public isValidGameId(_gameId) onlyBusinessAdmin {
        // uint256 length = gameArray.length;
        // require(_gameId - 1 < length && _gameId > 0, "");
        Game storage _game = gameArray[_gameId - 1];
        require(_state != _game.state, "");
        _game.state = _state;
        emit ChangeGameState(msg.sender, _gameId, _state);
    }
    
    function setGameExtAttrCount(uint256 _gameId, uint256 _extAttrCount) public isValidGameId(_gameId) onlyBusinessAdmin {
        Game storage _game = gameArray[_gameId - 1];
        require(_extAttrCount > _game.extAttrCount, "");
        _game.extAttrCount = _extAttrCount;
        emit ChangeGameExtAttrCount(msg.sender, _gameId, _extAttrCount);
    }

    function getGames() public view returns(uint256[] memory gameId,string[] memory gameName, bool[] memory flags) {
        uint256 gameLength = gameArray.length;
        gameId = new uint256[](gameLength);
        flags = new bool[](gameLength);
        gameName = new string[](gameLength);
        for (uint256 i = 0; i < gameLength; ++i) {
         
            gameId[i] = i + 1;
            string memory m = gameArray[i].gameName;
            gameName[i] = m;
            flags[i] = gameArray[i].state;
        }
    }

    function getGameCount() public view returns(uint256) {
        return gameArray.length;
    }
    

    function getGame(uint256 _gameId) public view returns(string memory gameName, bool state) {
        uint256 length = gameArray.length;
        require(_gameId - 1 < length && _gameId > 0, "");
        gameName = gameIdToGame[_gameId].gameName;
        state = gameIdToGame[_gameId].state;
    }

    function isEnableGame(uint256 _gameId) public view returns(bool flag) {
        uint256 length = gameArray.length;
        require(_gameId - 1 < length && _gameId > 0, "");
        flag = gameIdToGame[_gameId].state;
    }

    function setExtData(uint256 _gameId, uint256 _tokenId, uint256 _index, string memory _extData) 
    public 
    whenNotPaused 
    isValidToken(_tokenId) 
    isValidGameId(_gameId)
    {
        // require(bytes(_extData).length > 0,"");
        // require(bytes(_extData).length <= 32,"");
        uint256 gameAttrLength = gameIdToTokenAttr[_gameId][_tokenId].length;
        string[] memory attrs;
        Game storage game = gameArray[_gameId - 1];
        require(game.extAttrCount > 0,"");
        require(_index < game.extAttrCount,"");
        if(gameAttrLength == 0){
            attrs = new string[](game.extAttrCount);
           
        }else{
            attrs = gameIdToTokenAttr[_gameId][_tokenId];
           
        }
        attrs[_index] = _extData;
        gameIdToTokenAttr[_gameId][_tokenId] = attrs;
        emit ChangeTokenExtAttr(msg.sender,_gameId,_tokenId,_index, _extData);
    } 

    function setExtData(uint256 _gameId, uint256 _tokenId, string[] memory _extDataArray) 
    public 
    whenNotPaused 
    isValidToken(_tokenId) 
    isValidGameId(_gameId)
    {
        Game storage game = gameArray[_gameId - 1];
        require(game.extAttrCount > 0,"");
        require(_extDataArray.length > 0,"");
        require(_extDataArray.length <= game.extAttrCount, "");

        // require(bytes(_extData).length > 0,"");
        // require(bytes(_extData).length <= 32,"");
        uint256 gameAttrLength = gameIdToTokenAttr[_gameId][_tokenId].length;
        string[] memory attrs;
        
        if(gameAttrLength == 0){
            attrs = new string[](game.extAttrCount);
           
        }else{
            if( gameAttrLength < game.extAttrCount )
            {
                gameIdToTokenAttr[_gameId][_tokenId].length = game.extAttrCount;
            }
            attrs = gameIdToTokenAttr[_gameId][_tokenId]; 
        }
        for(uint256 i = 0; i < _extDataArray.length; ++i){
            attrs[i] = _extDataArray[i];
        }
        
        gameIdToTokenAttr[_gameId][_tokenId] = attrs;
        emit ChangeTokenExtAttrs(msg.sender,_gameId,_tokenId,_extDataArray);
    } 

    function getExtData(uint256 _gameId, uint256 _tokenId, uint256 _index) public view  returns(string memory tokenAttr)
    {
        return gameIdToTokenAttr[_gameId][_tokenId][_index];
    }
 
    function getExtDatas(uint256 _gameId, uint256 _tokenId) public view isValidToken(_tokenId) isValidGameId(_gameId) returns(string[] memory attrs) {
        Game storage game = gameArray[_gameId - 1];
        require(game.extAttrCount > 0,"");
        attrs = new string[](game.extAttrCount);
        for (uint256 i = 0; i < game.extAttrCount; ++i) {
            string memory m = gameIdToTokenAttr[_gameId][_tokenId][i];
            attrs[i] = m;
        }
    }
    
}