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
  * setBusinessAdmin(address _businessAdmin, bool _changeType)  权限:系统管理员
  * isBusinessAdmin(address _businessAdmin)
  * function addChain(string memory _chainName) 新增本合约的支持的链（合约） 权限: 业务管理员
  * setChainState(uint256 _chainId, bool _state)  修改合约的支持链（合约）状态  权限: 业务管理员
  * getChains() public view returns(uint256[] memory chainId,string[] memory chainName, bool[] memory flags)  获取本合约支持的链（合约）
  * getChainsCount()  获取支持链的总数
  * getChain(uint256 _chainId)  根据链ID获取链信息
  * isEnableChain(uint256 _chainId) 是否启用了链
  * 

  
