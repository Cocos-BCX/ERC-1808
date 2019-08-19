[中文](https://github.com/Cocos-BCX/ERC-1808/blob/master/README_cn.md)

# ERC-1808
Full spec: https://github.com/ethereum/EIPs/issues/2246  
develop document: [1808 Standard & Multiverse System](https://github.com/Cocos-BCX/1808/blob/master/README.md)

# ERC-1808
ERC (Ethereum Request for Comments) is a proposal submitted by the Ethereum developer, and the number after it is the proposal number.

ERC-1808 is a proposal of Cocos-BCX 1808 on Ethereum. It a Demo implementation proposed based on the design concept of COCOS 1808, which falls into the following four parts:
* Blockchain
* ERC-1808 Interface
* NFT Nested Assets
* Demo games

The contract interfaces that developers can call are as follows:

* Blockchain
  * transferSystemAdmin(address _newSystemAdmin) Authority: System Administrator
  * setBusinessAdmin(address _businessAdmin, bool _changeType)  Authority: System Administrator
  * isBusinessAdmin(address _businessAdmin)
  * addChain(string memory _chainName) Add a blockchain (contract) supporting the contract Authority: Business Administrator
  * setChainState(uint256 _chainId, bool _state)  Change the state of blockhcain (contract) supporting the contract Authority: Business Administrator
  * getChains()  Change the state of blockhcain (contract) supporting the contract Authority: Business Administrator
  * getChainsCount()  Get the total number of supporting blockchains
  * getChain(uint256 _chainId)   Get the information of the blockchain based on its ID
  * isEnableChain(uint256 _chainId) Whether the blockchain is enabled
 
* ERC-1808 Interface
  * ownerOf(uint256 _tokenId) Find the owner of an NFT  
  Transfer the ownership of the NFT from one address to another, allowing additional data to be attached; Need to verify whether it is a nested NFT. If it is, it cannot be traded
    
  * safeTransferFromWithExtData(address _from, address _to, uint256 _tokenId, string calldata data) 
    
  * safeTransferFrom(address _from, address _to, uint256 _tokenId)  
    Transfer the ownership of the NFT from one address to another without any additional data; need to verify whether it is a nested NFT. If it is, it cannot be traded.
      
  * transferFrom(address _from, address _to, uint256 _tokenId)  
    Transfer the ownership of the NFT: The caller is responsible for confirming that the “recipient” can receive the NFT or other assets that may be permanently lost otherwise, so it is necessary to implement call permission judgment to prevent abuse. 
    It is necessary to verify whether it is a nested NFT. If it is, it cannot be traded
      
  * balanceOf(address _owner)  Return the number of NFTs owned by the specified address account. _account cannot be zero address or empty. The return value may be 0
    
  * authorize(address _authorized, uint256 _tokenId) Change or reset the NFT's authorized address. Zero address means no authorized address.
    
  * setAuthorizedForAll(address _operator, bool _authorized) Enable or disable assets authorizing all sources that are managed by third-party ("Operation Authorization")
    
  * getAuthorized(uint256 _tokenId) Get an authorized address for a single NFT
    
  * isAuthorizedForAll(address _owner, address _operator) Query whether the address is an authorized operation of another address
  
## Unit Tests
Run `npm install -g truffle` to install [Truffle framework](http://truffleframework.com/docs/getting_started/installation)

Run `truffle test` to run the unit tests.

