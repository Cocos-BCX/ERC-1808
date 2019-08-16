pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2; 

interface IRCNFT {
    event AddNFT(address indexed addAddress, uint256 indexed nftId, string nftName);
    event ChangeNFTState(address indexed businessAddress, uint256 indexed nftId, bool indexed state);
    event ChangeNFTExtAttrCount(address indexed businessAddress, uint256 indexed nftId, uint256 indexed extAttrCount);
    event ChangeTokenExtAttr(address indexed businessAddress,uint256 indexed nftId, uint256 indexed tokenId, uint256 index, string extData );
    event ChangeTokenExtAttrs(address indexed businessAddress,uint256 indexed nftId, uint256 indexed tokenId, string[] extDatas );

    /// @notice add new nft.
    /// @dev  Throws if the length of `_nftName` less than zero.
    /// Throws if the length of `_nftName` is greater than 32.
    /// Throws unless an authorized operator of the current owner.
    /// @param _nftName The new nft name.
    /// @param _extAttrCount The NFT extra attribute's count.
    function addNFT(string memory _nftName, uint256 _extAttrCount) public;
    
    /// @notice set nft state.
    /// @dev  Throws if the `_state` equal to the nft state.
    /// Throws if the `_nftId` is valid.
    /// Throws unless an authorized operator of the current owner.
    /// @param `_nftId` The nft id.
    /// @param `_state` The nft state.
    function setNFTState(uint256 _nftId, bool _state) public;

    /// @notice set nft extra attribute's count.
    /// @dev  Throws if the `_extAttrCount` less than the nft extAttrCount.
    /// Throws if the `_nftId` is valid.
    /// Throws unless an authorized operator of the current owner.
    /// @param `_nftId` The nft id.
    /// @param `_extAttrCount` The NFT extra attribute's count.
    function setNFTExtAttrCount(uint256 _nftId, uint256 _extAttrCount) public;

    /// @notice get nfts info.
    /// @return nftIds, nftNames and flags
    function getNFTs() public view returns(uint256[] memory nftId,string[] memory nftName, bool[] memory flags);

    /// @notice get nft counts.
    /// @return the nft counts.
    function getNFTCount() public view returns(uint256);
    
    /// @notice get nft.
    /// @dev  Throws if the `_nftId` - 1 is greater than the nft array length.
    /// Throws if the `_nftId` less than 0.
    /// @param `_nftId` The nft id.
    /// @return the nft name and state.
    function getNFT(uint256 _nftId) public view returns(string memory nftName, bool state);

    /// @notice check the nft state.
    /// @dev  Throws if the `_nftId` - 1 is greater than the nft array length.
    /// Throws if the `_nftId` less than 0.
    /// @param `_nftId` The nft id.
    /// @return the nft state.
    function isEnableNFT(uint256 _nftId) public view returns(bool flag);

    /// @notice set the nft extra data.
    /// @dev  Throws if the `_nftId` - 1 is greater than the nft array length.
    /// Throws if the contract is paused.
    /// Throws if the `_nftId` is valid.
    /// Throws if the `_tokenId` is valid.
    /// Throws if the `_index` is greater than the nft extra attribute count.
    /// Throws if the nft extra data count less than 0.
    /// @param `_nftId` The nft id.
    /// @param `_tokenId` The token id.
    /// @param `_index` The array index.
    /// @param `_extData` The extra data.
    function setExtData(uint256 _nftId, uint256 _tokenId, uint256 _index, string memory _extData) public;

    /// @notice set the nft extra data.
    /// @dev  Throws if the `_nftId` - 1 is greater than the nft array length.
    /// Throws if the contract is paused.
    /// Throws if the `_nftId` is valid.
    /// Throws if the `_tokenId` is valid.
    /// Throws if the lenght of `_extDataArray` is greater than the nft extra attribute count.
    /// Throws if the lenght of `_extDataArray` less than 0.
    /// Throws if the nft extra data count less than 0.
    /// @param `_nftId` The nft id.
    /// @param `_tokenId` The token id.
    /// @param `_extDataArray` The array of extra data.
    function setExtData(uint256 _nftId, uint256 _tokenId, string[] memory _extDataArray) public;

    /// @notice get the nft extra data.
    /// @param `_nftId` The nft id.
    /// @param `_tokenId` The token id.
    /// @param `_index` The array index.
    /// @return the nft tokenAttr.
    function getExtData(uint256 _nftId, uint256 _tokenId, uint256 _index) public view  returns(string memory tokenAttr);

    /// @notice get all nft extra datas
    /// @dev  Throws if the `_nftId` is valid.
    /// Throws if the `_tokenId` is valid.
    /// Throws if the nft extra data count less than 0.
    /// @param `_nftId` The nft id.
    /// @param `_tokenId` The token id.
    /// @return the nft attributes.
    function getExtDatas(uint256 _nftId, uint256 _tokenId) public view isValidToken(_tokenId) isValidNFTId(_nftId) returns(string[] memory attrs);
}
