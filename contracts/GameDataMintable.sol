pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2; 

contract MyNFT {
    function getAuthorized(uint256 _tokenId) external view returns (address);
    function isAuthorizedForAll(address _owner, address _operator) external view returns (bool);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function isPaused() external view returns (bool); 
    function businessAdmin(address _address ) external view returns (bool);
    function getFashionArrayLength() external view returns (uint256);
    function getBusinessAdmin(address _businessAdmin) external view returns(bool);
}

contract AccessAdmin1 {
     
    address public mynftAddr = 0x74b3926AA4D22247540e5578D15BF221ADdf8B44;
    MyNFT myNFT = MyNFT(mynftAddr);
   
    modifier onlyBusinessAdmin() {
        require(myNFT.getBusinessAdmin(msg.sender), "不是业务管理员");
        _;
    }
    modifier whenNotPaused() {
        require(!myNFT.isPaused(), "合约已经冻结");
        _;
    }

    modifier whenPaused() {
        require(myNFT.isPaused(), "合约没有冻结");
        _;
    }
    
    modifier isValidToken(uint256 _tokenId) {
        require(_tokenId >= 1 && _tokenId <= myNFT.getFashionArrayLength(), "");
        require(myNFT.ownerOf(_tokenId) != address(0), "");
        _;
    }
}

contract MyNFTData1 is AccessAdmin1, ERC1808 {

    struct NFT {
        string nftName;
        uint256 extAttrCount; /// 扩展属性个数
        bool state;
    }
    
    mapping(uint256 => NFT) nftIdToNFT;
    NFT[] public nftArray;
    mapping(uint256 => mapping(uint256 =>string[])) nftIdToTokenAttr;

    event AddNFT(address indexed addAddress, uint256 indexed nftId, string nftName);
    event ChangeNFTState(address indexed businessAddress, uint256 indexed nftId, bool indexed state);
    event ChangeNFTExtAttrCount(address indexed businessAddress, uint256 indexed nftId, uint256 indexed extAttrCount);
    event ChangeTokenExtAttr(address indexed businessAddress,uint256 indexed nftId, uint256 indexed tokenId, uint256 index, string extData );
    event ChangeTokenExtAttrs(address indexed businessAddress,uint256 indexed nftId, uint256 indexed tokenId, string[] extDatas );
   
    modifier isValidNFTId(uint256 _nftId) {
        require(_nftId >= 1 && _nftId <= nftArray.length, "");
        _;
    }

    function addNFT(string memory _nftName, uint256 _extAttrCount) public onlyBusinessAdmin {
        require(bytes(_nftName).length > 0,"");
        require(bytes(_nftName).length <= 32,"");
        uint256 newNFTId = nftArray.length + 1;
        require(newNFTId < 4294967296 && newNFTId > 0, "");
        nftArray.length += 1;
        NFT storage nft = nftArray[newNFTId - 1];
        nft.nftName = _nftName;
        nft.extAttrCount = _extAttrCount;
        nft.state = true;
        nftIdToNFT[newNFTId] = nft;
        emit AddNFT(msg.sender, newNFTId, _nftName);
    }

    function setNFTState(uint256 _nftId, bool _state) public isValidNFTId(_nftId) onlyBusinessAdmin {
        // uint256 length = nftArray.length;
        // require(_nftId - 1 < length && _nftId > 0, "");
        NFT storage _nft = nftArray[_nftId - 1];
        require(_state != _nft.state, "");
        _nft.state = _state;
        emit ChangeNFTState(msg.sender, _nftId, _state);
    }
    
    function setNFTExtAttrCount(uint256 _nftId, uint256 _extAttrCount) public isValidNFTId(_nftId) onlyBusinessAdmin {
        NFT storage _nft = nftArray[_nftId - 1];
        require(_extAttrCount > _nft.extAttrCount, "");
        _nft.extAttrCount = _extAttrCount;
        emit ChangeNFTExtAttrCount(msg.sender, _nftId, _extAttrCount);
    }

    function getNFTs() public view returns(uint256[] memory nftId,string[] memory nftName, bool[] memory flags) {
        uint256 nftLength = nftArray.length;
        nftId = new uint256[](nftLength);
        flags = new bool[](nftLength);
        nftName = new string[](nftLength);
        for (uint256 i = 0; i < nftLength; ++i) {
         
            nftId[i] = i + 1;
            string memory m = nftArray[i].nftName;
            nftName[i] = m;
            flags[i] = nftArray[i].state;
        }
    }

    function getNFTCount() public view returns(uint256) {
        return nftArray.length;
    }
    

    function getNFT(uint256 _nftId) public view returns(string memory nftName, bool state) {
        uint256 length = nftArray.length;
        require(_nftId - 1 < length && _nftId > 0, "");
        nftName = nftIdToNFT[_nftId].nftName;
        state = nftIdToNFT[_nftId].state;
    }

    function isEnableNFT(uint256 _nftId) public view returns(bool flag) {
        uint256 length = nftArray.length;
        require(_nftId - 1 < length && _nftId > 0, "");
        flag = nftIdToNFT[_nftId].state;
    }

    function setExtData(uint256 _nftId, uint256 _tokenId, uint256 _index, string memory _extData)
    public 
    whenNotPaused 
    isValidToken(_tokenId) 
    isValidNFTId(_nftId)
    {
        // require(bytes(_extData).length > 0,"");
        // require(bytes(_extData).length <= 32,"");
        uint256 nftAttrLength = nftIdToTokenAttr[_nftId][_tokenId].length;
        string[] memory attrs;
        NFT storage nft = nftArray[_nftId - 1];
        require(nft.extAttrCount > 0,"");
        require(_index < nft.extAttrCount,"");
        if(nftAttrLength == 0){
            attrs = new string[](nft.extAttrCount);
           
        }else{
            attrs = nftIdToTokenAttr[_nftId][_tokenId];
           
        }
        attrs[_index] = _extData;
        nftIdToTokenAttr[_nftId][_tokenId] = attrs;
        emit ChangeTokenExtAttr(msg.sender,_nftId,_tokenId,_index, _extData);
    } 

    function setExtData(uint256 _nftId, uint256 _tokenId, string[] memory _extDataArray)
    public 
    whenNotPaused 
    isValidToken(_tokenId) 
    isValidNFTId(_nftId)
    {
        NFT storage nft = nftArray[_nftId - 1];
        require(nft.extAttrCount > 0,"");
        require(_extDataArray.length > 0,"");
        require(_extDataArray.length <= nft.extAttrCount, "");

        // require(bytes(_extData).length > 0,"");
        // require(bytes(_extData).length <= 32,"");
        uint256 nftAttrLength = nftIdToTokenAttr[_nftId][_tokenId].length;
        string[] memory attrs;
        
        if(nftAttrLength == 0){
            attrs = new string[](nft.extAttrCount);
           
        }else{
            if( nftAttrLength < nft.extAttrCount )
            {
                nftIdToTokenAttr[_nftId][_tokenId].length = nft.extAttrCount;
            }
            attrs = nftIdToTokenAttr[_nftId][_tokenId];
        }
        for(uint256 i = 0; i < _extDataArray.length; ++i){
            attrs[i] = _extDataArray[i];
        }
        
        nftIdToTokenAttr[_nftId][_tokenId] = attrs;
        emit ChangeTokenExtAttrs(msg.sender,_nftId,_tokenId,_extDataArray);
    } 

    function getExtData(uint256 _nftId, uint256 _tokenId, uint256 _index) public view  returns(string memory tokenAttr)
    {
        return nftIdToTokenAttr[_nftId][_tokenId][_index];
    }
 
    function getExtDatas(uint256 _nftId, uint256 _tokenId) public view isValidToken(_tokenId) isValidNFTId(_nftId) returns(string[] memory attrs) {
        NFT storage nft = nftArray[_nftId - 1];
        require(nft.extAttrCount > 0,"");
        attrs = new string[](nft.extAttrCount);
        for (uint256 i = 0; i < nft.extAttrCount; ++i) {
            string memory m = nftIdToTokenAttr[_nftId][_tokenId][i];
            attrs[i] = m;
        }
    }
}
