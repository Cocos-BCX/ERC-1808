pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2; 

import "./IRC1808.sol";

contract AccessAdmin {
    bool public isPaused = false;
    address public systemAdmin;
    mapping(address => bool) businessAdmin;
    event SystemAdminTransferred(address indexed preSystemAdmin, address indexed newSystemAdmin);
    event BusinessAdminChanged(address indexed businessAdmin , bool indexed changeType);
   
    constructor() public {
        systemAdmin = msg.sender;
    }

    modifier onlySystemAdmin() {
        require(msg.sender == systemAdmin, "不是系统管理员");
        _;
    }

    modifier onlyBusinessAdmin() {
        require(businessAdmin[msg.sender], "不是业务管理员");
        _;
    }

    modifier whenNotPaused() {
        require(!isPaused, "合约已经冻结");
        _;
    }

    modifier whenPaused() {
        require(isPaused, "合约没有冻结");
        _;
    }

    function transferSystemAdmin(address _newSystemAdmin) external onlySystemAdmin {
        require(_newSystemAdmin != address(0), "目标地址为零地址");
        emit SystemAdminTransferred(systemAdmin, _newSystemAdmin);
        systemAdmin = _newSystemAdmin;
    }

    function setBusinessAdmin(address _businessAdmin, bool _changeType) external onlySystemAdmin {
        require(_businessAdmin != address(0), "目标地址为零地址");
        businessAdmin[_businessAdmin] = _changeType;
        emit BusinessAdminChanged(_businessAdmin, _changeType);
    }

    function isBusinessAdmin(address _businessAdmin) external view returns(bool) {
        return businessAdmin[_businessAdmin];
    }


    function doPause() external onlySystemAdmin whenNotPaused {
        isPaused = true;
    }

    function doUnpause() external onlySystemAdmin whenPaused {
        isPaused = false;
    }
 

}

contract MyChain1 {
    function getChains() public view returns(uint256[] memory chainId,bytes32[] memory chainName, bool[] memory flags);
    function getChainsCount() public view returns(uint256);
    function getChain(uint256 _chainId) public view returns(string memory chainName, bool state);
    function isEnableChain(uint256 _chainId) public view returns(bool flag);
}

contract MyERC1808Mintable is ERC1808, AccessAdmin {

    address public myChainAddr;
    MyChain1 myChain;

    struct NFT { 
        address creator;
        uint timestamp;
        string worldView;
        string baseData;
    }
  
    /// 所有装备（不超过2^32-1）
    NFT[] public nftArray;
    /// 销毁数量
    uint256 destroyNFTCount;

    mapping(uint256 => address) tokenIdToOwner;
    mapping(address => uint256[]) ownerToNFTArray;
    mapping(uint256 => uint256) tokenIdToOwnerIndex;
    mapping(uint256 => address) tokenIdToApprovals;
    mapping(address => mapping(address => bool)) operatorToApprovals;
    /// chainId =>(otherchaintfashionId=>localchainfashionId)
    mapping(uint256 => mapping(string => uint256)) chainTokenIdToLocalTokenId;
    /// localchainfashionId => (chainId => otherchaintfashionId)
    mapping(uint256 => mapping(uint256 => string)) localTokenIdToChainTokenId;
    mapping(uint256 => string) tokenIdToURI;
    
    
   
 
    event CreateNFT(address indexed owner, uint256 indexed tokenId, string baseData, uint256 chainId, string otherTokenId);
    event DeleteNFT(address indexed owner, uint256 tokenId);

    constructor(address _myChainAddr) public {
       myChainAddr = _myChainAddr;
       systemAdmin = msg.sender;
       nftArray.length += 1;
       myChain = MyChain1(myChainAddr);
    }

    modifier isValidToken(uint256 _tokenId) {
        require(_tokenId >= 1 && _tokenId <= nftArray.length, "");
        require(tokenIdToOwner[_tokenId] != address(0), "");
        _;
    }


    modifier canTransfer(uint256 _tokenId) {
        address owner = tokenIdToOwner[_tokenId];
        require(msg.sender == owner || msg.sender == tokenIdToApprovals[_tokenId] || operatorToApprovals[owner][msg.sender] == true, "");
        _;   
    }

   

    function name() public pure returns(string memory) {
        return "COCOS NTF ";
    }

    function symbol() public pure returns(string memory) {
        return "COCOSNTF";
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        return tokenIdToURI[_tokenId];
    }
    
    
    function getTokenId(uint256 _chainId, string memory otherTokenId) public view returns(uint256) {
        return chainTokenIdToLocalTokenId[_chainId-1][otherTokenId];
    }  

    /// 获取账户拥有资产的数量
    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "");
        return ownerToNFTArray[_owner].length;
    }
   
    /// 查询资产的拥有者
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return tokenIdToOwner[_tokenId];
    }

    /// 资产的转移
    function safeTransferFromWithExtData(address _from, address _to, uint256 _tokenId, string calldata data) external whenNotPaused payable {
        _safeTransferFrom(_from, _to, _tokenId, data);
    }

    /// 资产的转移
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external whenNotPaused payable {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    /// 资产的转移
    function transferFrom(address _from, address _to, uint256 _tokenId) external
     whenNotPaused isValidToken(_tokenId) canTransfer(_tokenId) payable {
        address owner = tokenIdToOwner[_tokenId];
        require(owner != address(0),"");
        require(_to != address(0),"");
        require(owner == _from, "");
        // require(fashionIdToComposeFashionId[_tokenId] == 0, "token已经组合");
        _transfer(_from, _to, _tokenId);
    }
    
    /// 授权资产的操作权
    function authorize(address _authorized, uint256 _tokenId) external whenNotPaused payable {
        address owner = tokenIdToOwner[_tokenId];
        require(owner != address(0), "");
        require(msg.sender == owner || operatorToApprovals[owner][msg.sender],"");
        tokenIdToApprovals[_tokenId] = _authorized;
        emit Authorized(msg.sender, _authorized, _tokenId);
    }

    /// 授权账户的操作权
    function setAuthorizedForAll(address _operator, bool _authorized) external whenNotPaused {
        operatorToApprovals[msg.sender][_operator] = _authorized;
        emit AuthorizedForAll(msg.sender, _operator, _authorized);
    }

    /// 获取资产的授权账户
    function getAuthorized(uint256 _tokenId) external view isValidToken(_tokenId) returns (address) {
        return tokenIdToApprovals[_tokenId];
    }

    /// 验证账户是否授权给操作者
    function isAuthorizedForAll(address _owner, address _operator) external view returns (bool) {
        return operatorToApprovals[_owner][_operator];
    }
 
    /// 获取本合约总的同质的数量
    function totalSupply() external view returns (uint256) {
        return nftArray.length - destroyNFTCount - 1;
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {

        if (_from != address(0)) {
            uint256 indexFrom = tokenIdToOwnerIndex[_tokenId];
            uint256[] storage fsArray = ownerToNFTArray[_from];
            require(fsArray[indexFrom] == _tokenId, "");

            
            if (indexFrom != fsArray.length - 1) {
                uint256 lastTokenId = fsArray[fsArray.length - 1];
                fsArray[indexFrom] = lastTokenId;
                tokenIdToOwnerIndex[lastTokenId] = indexFrom;
            }

            fsArray.length -= 1;

            if (tokenIdToApprovals[_tokenId] != address(0)) {
                delete tokenIdToApprovals[_tokenId];
            }

        }

        tokenIdToOwner[_tokenId] = _to;
        ownerToNFTArray[_to].push(_tokenId);
        tokenIdToOwnerIndex[_tokenId] = ownerToNFTArray[_to].length - 1;
         emit Transfer(_from != address(0) ? _from : address(this), _to, _tokenId);

    }

    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, string memory data) internal isValidToken(_tokenId) canTransfer(_tokenId) {

        address owner = tokenIdToOwner[_tokenId];
        require(owner != address(0), "");
        require(_to != address(0), "");
        require(owner == _from, "");
        // require(fashionIdToComposeFashionId[_tokenId] == 0, "token已经组合");
        _transfer(_from, _to, _tokenId);
      
        uint256 codeSize;
        assembly { codeSize := extcodesize(_to) }
        if (codeSize == 0) {
            return;
        }

        // bytes4 retval = ERC1808TokenReceiver(_to).onERC1808Received(_from, _tokenId, data);
        // require(retval == 0x06fd8cc1, "");

    }
    
    /// 获取NFTArrayLength
    function getNFTArrayLength() external view returns (uint256) {
        return nftArray.length;
    }
 
    /// 检验是某链（合约）的某资产是否在本链已经创建
    function isExistTokenId(uint256 _chainId, string memory _otherChainTokenId) public view returns (bool) {
        uint256 length = myChain.getChainsCount();
        require(_chainId - 1 < length && _chainId > 0, "");
        uint256 localTokenId = chainTokenIdToLocalTokenId[_chainId - 1][_otherChainTokenId];
        if (localTokenId != 0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    /// 设置NFT的在其他链（合约）的资产ID
    function setNFTOtherChainTokenId(uint256 _tokenId, uint256 _chainId, string memory _otherChainTokenId) 
    public whenNotPaused isValidToken(_tokenId)  onlyBusinessAdmin {
        uint256 length = myChain.getChainsCount();
        require(_chainId - 1 < length && _chainId > 0, "");
        require(!this.isExistTokenId(_chainId,_otherChainTokenId), "已经存在，不能重复绑定");
        //  require(localTokenIdToChainTokenId[_tokenId][_chainId]);
        // 都要检查 是否配对 chainTokenIdToLocalTokenId localTokenIdToChainTokenId
        localTokenIdToChainTokenId[_tokenId][_chainId] = _otherChainTokenId;
    }

    /// 创建资产（平台）
    function createNFT(address _owner,string memory _worldView, string memory _baseData)
    public whenNotPaused onlyBusinessAdmin
    {
        require(_owner != address(0), "");
        uint256 newTokenId = nftArray.length;
        require(newTokenId < 4294967296, "");
        nftArray.length += 1;
        NFT storage fs = nftArray[newTokenId];
        fs.creator = msg.sender;
        fs.timestamp = block.timestamp;
        fs.worldView = _worldView;
        fs.baseData = _baseData;
        _transfer(address(0), _owner, newTokenId);
        emit CreateNFT(_owner, newTokenId, _baseData, 0, '');
    }
    

    /// 创建资产（平台） 外联转移
    function createNFT(address _owner,string memory _worldView,  string memory _baseData,  uint256 _chainId, string memory _otherChainTokenId)
    public whenNotPaused onlyBusinessAdmin{
        require(_owner != address(0), "");
        uint256 length = myChain.getChainsCount();
        require(_chainId - 1 < length && _chainId > 0, "");
        require(myChain.isEnableChain(_chainId), "此链承兑已经禁用");
        require(bytes(_otherChainTokenId).length !=0, "");

        uint256 localTokenId = chainTokenIdToLocalTokenId[_chainId - 1][_otherChainTokenId];
        if (localTokenId != 0)
        {
            //本链已经存在
            address _currentOwner = tokenIdToOwner[localTokenId];
        //     NFT storage fs1 = nftArray[localTokenId];
        //       fs.creator = msg.sender;
        // fs.timestamp = block.timestamp;
        // fs.worldView = _worldView;DeleteNFT
        // fs.baseData = _baseData;
            _transfer(_currentOwner, _owner, localTokenId);
            emit CreateNFT(_owner, localTokenId, _baseData, _chainId, _otherChainTokenId);
        }
        else
        {
            //本链不存在
            uint256 newTokenId = nftArray.length;
            require(newTokenId < 4294967296, "");
            nftArray.length += 1;
            NFT storage fs = nftArray[newTokenId];
            fs.creator = msg.sender;
            fs.timestamp = block.timestamp;
            fs.worldView = _worldView;
            fs.baseData = _baseData;
            chainTokenIdToLocalTokenId[_chainId - 1][_otherChainTokenId] = newTokenId;
            localTokenIdToChainTokenId[newTokenId][_chainId - 1] = _otherChainTokenId;
            _transfer(address(0), _owner, newTokenId);
            emit CreateNFT(_owner, newTokenId, _baseData, _chainId, _otherChainTokenId);
        }

    
        
    }

 
    ///销毁资产（平台）
    function destroyNFT(uint256 _tokenId) external whenNotPaused onlyBusinessAdmin isValidToken(_tokenId) {
        address _from = tokenIdToOwner[_tokenId];
        uint256 indexFrom = tokenIdToOwnerIndex[_tokenId];
        uint256[] storage fsArray = ownerToNFTArray[_from];
        require(fsArray[indexFrom] == _tokenId,"");
        // require(fashionIdToComposeFashionId[_tokenId] == 0, "token已经组合");
        if (indexFrom != fsArray.length - 1) {
            uint256 lastTokenId = fsArray[fsArray.length - 1];
            fsArray[indexFrom] = lastTokenId;
            tokenIdToOwnerIndex[lastTokenId] = indexFrom;
        }

        fsArray.length -= 1;
        tokenIdToOwner[_tokenId] = address(0);
        delete tokenIdToOwnerIndex[_tokenId];
        uint256 chainLength = myChain.getChainsCount();
        for (uint256 i = 0; i < chainLength; ++i) {
            string memory oTokenId = localTokenIdToChainTokenId[_tokenId][i];
            delete localTokenIdToChainTokenId[_tokenId][i];
            delete chainTokenIdToLocalTokenId[i][oTokenId];
        }
       
        destroyNFTCount += 1;
        emit Transfer(_from, address(0), _tokenId);
        emit DeleteNFT(_from, _tokenId);

    }

    /// 管理员资产
    function safeTransferByContract(uint256 _tokenId, address _to) external whenNotPaused onlyBusinessAdmin {
        require(_tokenId >= 1 && _tokenId <= nftArray.length,"");
        address owner = tokenIdToOwner[_tokenId];
        require(owner != address(0),"");
        require(_to != address(0),"");
        require(owner != _to,"");
        // require(fashionIdToComposeFashionId[_tokenId] == 0, "token已经组合");
        _transfer(owner, _to, _tokenId);
    }

    ///获取单个NFT
    function getNFT(uint256 _tokenId) external view isValidToken(_tokenId) returns(NFT memory nft) {
         nft = nftArray[_tokenId]; 
    }

    /// 获取持有列表
    function getOwnNFTIds(address _owner) external view returns(uint256[] memory tokenIds) {
        require(_owner != address(0),"");
        uint256[] storage fsArray = ownerToNFTArray[_owner];
        uint256 length = fsArray.length;
        tokenIds = new uint256[](length);
      
        for (uint256 i = 0; i < length; ++i) {
            tokenIds[i] = fsArray[i];
        }
    }

    ///批量获取信息
    function getNFTs(uint256[] memory _tokenIds) public view returns(NFT[] memory nfts) {
        uint256 length = _tokenIds.length;
        require(length <= 64,"");
        nfts = new NFT[](length);
        uint256 tokenId;
        for (uint256 i = 0; i < length; ++i) {
            tokenId = _tokenIds[i];
            if (tokenIdToOwner[tokenId] != address(0)) {
               
                NFT storage fs = nftArray[tokenId];
                nfts[i] = fs;
  
            }
        }
    }
    
}
