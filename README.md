# Cocos-BCX 1808 概述
[COCOS 1808 非同质数字资产标准和世界观系统](https://github.com/Cocos-BCX/1808/blob/master/README.md)

# ERC-1808
ERC全称Ethereum Request for Comments，即以太坊开发者提交的协议提案，ERC后面的数字是提案编号。

ERC-1808是Cocos-BCX 1808在以太坊上的提案，本项目是基于Cocos-BCX 1808设计理念和提案的一个Demo实现。主要分四个部分：
* 链
* ERC-1808接口
* NFT组合资产
* 游戏示例

开发者可以调用的合约接口如下所示：

* 链
  * transferSystemAdmin(address _newSystemAdmin) 权限:系统管理员
  * setBusinessAdmin(address _businessAdmin, bool _changeType)  权限:系统管理员
  * isBusinessAdmin(address _businessAdmin)
  * addChain(string memory _chainName) 新增本合约的支持的链（合约）  权限: 业务管理员
  * setChainState(uint256 _chainId, bool _state)  修改合约的支持链（合约）状态  权限: 业务管理员
  * getChains()  获取本合约支持的链（合约）
  * getChainsCount()  获取支持链的总数
  * getChain(uint256 _chainId)  根据链ID获取链信息
  * isEnableChain(uint256 _chainId) 是否启用了链
 
* ERC-1808接口
  * ownerOf(uint256 _tokenId) 查找一个NTF的所有者  
  将NFT的所有权从一个地址转移到另一个地址，允许附加额外数据; 需验证是否是组合NFT，若组合则不可进行交易
    
  * safeTransferFromWithExtData(address _from, address _to, uint256 _tokenId, string calldata data) 
    
  * safeTransferFrom(address _from, address _to, uint256 _tokenId)  
    将NFT的所有权从一个地址转移到另一个地址，无附加数据; 需验证是否是组合NFT，若组合则不可进行交易
      
  * transferFrom(address _from, address _to, uint256 _tokenId)  
    转移NFT的所有权：调用方负责确认“收件人”能够接收NFT或其他它们可能永久丢失，因此需要实现调用权限判定以防止滥用
    需验证是否是组合NFT，若组合则不可进行交易
      
  * balanceOf(address _owner)  返回指定地址账户拥有的NFT数量, _account不可为零地址或者空, 返回值可能为0
    
  * authorize(address _authorized, uint256 _tokenId) 更改或重设NFT的授权地址 零地址表示没有授权的地址
    
  * setAuthorizedForAll(address _operator, bool _authorized) 启用或禁用第三方（“操作授权”）管理的授权所有消息来源的资产
    
  * getAuthorized(uint256 _tokenId) 获取单个NFT的授权地址
    
  * isAuthorizedForAll(address _owner, address _operator) 查询地址是否为其他地址的授权操作
  
  


