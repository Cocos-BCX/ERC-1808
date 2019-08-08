pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2; 

interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface ERC1808 /* is ERC165 */  {
    ///当任何NFT的所有权被任何机制更改时，就会发出此消息。
    ///此事件会在创建(from == 0)和销毁（to == 0）时引发。
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    ///当NFT的批准地址被更改或重新确认时，就会发出此消息。
    event Authorized(address indexed owner, address indexed authorized, uint256 indexed tokenId);
    ///当为所有者启用或禁用操作员时，会发出此消息。
    ///运营商可以管理所有者的所有NFT。
    event AuthorizedForAll(address indexed owner, address indexed operator, bool authorized);
  
    ///查找一个NTF的所有者
    function ownerOf(uint256 _tokenId) external view returns (address);
	
    ///将NFT的所有权从一个地址转移到另一个地址，允许附加额外数据
	///需验证是否是组合NFT，若组合则不可进行交易
	
    function safeTransferFromWithExtData(address _from, address _to, uint256 _tokenId, string calldata data) external payable;
	
    // ///将NFT的所有权从一个地址转移到另一个地址，无附加数据
	// ///需验证是否是组合NFT，若组合则不可进行交易
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
	
    ///转移NFT的所有权：调用方负责确认“收件人”能够接收NFT或其他它们可能永久丢失，因此需要实现调用权限判定以防止滥用
	///需验证是否是组合NFT，若组合则不可进行交易
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
	
	///返回指定地址账户拥有的NFT数量
	///_account不可为零地址或者空
	///返回值可能为0
	function balanceOf(address _owner) external view returns (uint256);
	
    ///更改或重设NFT的授权地址 零地址表示没有授权的地址。
    function authorize(address _authorized, uint256 _tokenId) external payable;
	
    ///启用或禁用第三方（“操作授权”）管理的授权所有消息来源的资产
    function setAuthorizedForAll(address _operator, bool _authorized) external;
	
    ///获取单个NFT的授权地址
    function getAuthorized(uint256 _tokenId) external view returns (address);
	
    ///查询地址是否为其他地址的授权操作
    function isAuthorizedForAll(address _owner, address _operator) external view returns (bool);
 
}

/// @dev Note: the ERC-165 identifier for this interface is .
// interface ERC1808TokenReceiver {
//     function onERC1808Received(address _from, uint256 _tokenId, string calldata _data) external returns(bytes4);
// }
