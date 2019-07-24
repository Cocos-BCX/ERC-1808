pragma solidity ^0.5.0;

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
     
    address public myERC1808Addr = 0xE6c28FEF0491c7626c002131a2c833094f6135D3;
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

contract MyCompose is AccessAdmin1 {
 
    mapping(uint256 => bool) tokenIdToComposable;
    mapping(uint256 => bool) tokenIdToParent;
    mapping(uint256 => uint256) tokenIdToComposeTokenId;
    event TokenComposed(uint256 indexed tokenId, uint256 indexed composedWith, bool indexed isParent);
	///当NFT解除组合时，会发出此消息。
    event TokenReleased(uint256 indexed tokenId, uint256 indexed composedWith);
 
    /// 设置NFT的是否支持组合的特性
    function setComposable(uint256 _tokenId, bool _isComposable) public whenNotPaused isValidToken(_tokenId) onlyBusinessAdmin {
        tokenIdToComposable[_tokenId] = _isComposable;
    }

    /// 是否支持组合
    function isComposable(uint256 _tokenId) public whenNotPaused view returns (bool) {
        return tokenIdToComposable[_tokenId];
    }
	/// 组合
    function setCompose(uint256 _tokenId, uint256 _composedWith, bool _isParent) public 
    whenNotPaused 
    isValidToken(_tokenId) 
    isValidToken(_composedWith) {
        require(tokenIdToComposable[_tokenId] == true, "发起者没有该特性");
        require(tokenIdToComposable[_composedWith] == true, "被组合者没有该特性");
        address owner1 = myERC1808.ownerOf(_tokenId);
        address owner2 = myERC1808.ownerOf(_composedWith);
        require(owner1 == owner2, "");
        // require(owner1 != address(0),"");
        require(msg.sender == owner1 || msg.sender == myERC1808.getAuthorized(_tokenId) || myERC1808.isAuthorizedForAll(owner1,msg.sender) == true, "");
        require(tokenIdToComposeTokenId[_tokenId] == 0, "发起者重复组合");
        require(tokenIdToComposeTokenId[_composedWith] == 0, "被组合者重复组合");
        tokenIdToParent[_tokenId] = _isParent;
        tokenIdToParent[_composedWith] = !_isParent;
        tokenIdToComposeTokenId[_tokenId] = _composedWith;
        tokenIdToComposeTokenId[_composedWith] = _tokenId;
        emit TokenComposed(_tokenId, _composedWith, _isParent);
    }
  
    function releaseComposedToken(uint256  _tokenId, uint256  _composedWith) public 
    whenNotPaused 
    isValidToken(_tokenId) 
    isValidToken(_composedWith) {
        address owner1 = myERC1808.ownerOf(_tokenId);
        address owner2 = myERC1808.ownerOf(_composedWith);
        require(owner1 == owner2, "");
        require(msg.sender == owner1 || msg.sender == myERC1808.getAuthorized(_tokenId) ||  myERC1808.isAuthorizedForAll(owner1,msg.sender) == true, "");
        require(tokenIdToComposeTokenId[_tokenId] == _composedWith, "");
        delete tokenIdToComposeTokenId[_tokenId];
        delete tokenIdToComposeTokenId[_composedWith];
        delete tokenIdToParent[_tokenId];
        delete tokenIdToParent[_composedWith];
        emit TokenReleased(_tokenId, _composedWith);

    }

    function releaseComposedTokenForce(uint256  _tokenId, uint256  _composedWith) public 
    whenNotPaused
    onlyBusinessAdmin
    isValidToken(_tokenId) 
    isValidToken(_composedWith) {
        // address owner1 = myERC1808.ownerOf(_tokenId);
        // address owner2 = myERC1808.ownerOf(_composedWith);
        require(tokenIdToComposeTokenId[_tokenId] == _composedWith, "");
        delete tokenIdToComposeTokenId[_tokenId];
        delete tokenIdToComposeTokenId[_composedWith];
        delete tokenIdToParent[_tokenId];
        delete tokenIdToParent[_composedWith];
        emit TokenReleased(_tokenId, _composedWith);

    }


    /// 是否已经组合
    function isComposed(uint256 _tokenId) public isValidToken(_tokenId) view returns (bool) {
       
        if (tokenIdToComposeTokenId[_tokenId] != 0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    function isValidComposed(uint256 _tokenId) public isValidToken(_tokenId) view returns (bool) {
        uint256 _composedWith = tokenIdToComposeTokenId[_tokenId];
        
        if (_composedWith == 0)
        {
            return false;
        }
        address owner1 = myERC1808.ownerOf(_tokenId);
        address owner2 = myERC1808.ownerOf(_composedWith);
        if (owner1 == owner2) {
            return true;
        }
        else {
            return false;
        }
    }
    
}

