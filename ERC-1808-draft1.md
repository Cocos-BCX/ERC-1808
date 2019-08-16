---
eip: 1808
title: ERC-1808 Token Standard
author: Ypenghui<ypenghui6@163.com>
status: Draft
type: Standards Track
category: ERC
created: 2019-08-14
requires: 165
---

## Simple Summary

A non-homogeneous digital assets standard, and the multiverse system.

## Abstract

   ERC-1808 Standard (hereinafter referred to as "1808 Standard") is a non-homogeneous digital assets standard that applied to decentralized distributed ledger network. As the perfect way to represent various non-fungible items, non-homogeneous digital assets can cover the field of game items, gears, characters, map data, and even expansion pack in the game industry. This manual also focus on the multiverse system based on 1808 Standard, such as universe traveling, multiverse, and etc.  
   
## Motivation

  Combining the needs of gaming industry, we reviewed a number of existing non-homogeneous digital asset standards and defined ERC1808 to be the one to standardize all non-homogeneous digital assets.  
  At present, ERC-721, ERC-1155, and ERC-998 of Ethereum network are the popular non-homogeneous digital asset standards, which are used in different scenarios and for different needs on the Ethereum network:
  * ERC-721  
    It is an officially accepted non-homogeneous digital asset standard defined by smart contracts in the Ethereum network. It has a customizable data zone, which makes it possible to digitize items or records.  
    Typical applications are: Crypto Kitties, Crypto Celebrities, etc   
  * ERC-1155  
    It is a standard interface proposed by Enjin to define multiple non-homogenous assets in Ethereum's single smart contract, serving mainly the virtual props in blockchain games.   
    Typical application: War of Crypto.  
  * ERC-998  
    It is a combination of non-homologous tokens (CNFT, Composable NFTs) defined in Ethereum's smart contracts proposed by Matt Lockyer.   
      
    ![P3](https://github.com/Cocos-BCX/1808/blob/master/readmeimg/3_en.png)
        
    
  The figure shows the comparison of the above three non-homogeneous asset standards with COCOS 1808, which briefly compares the essentials that may be involved in blockchain and gaming. The differences marked in red are the features of the 1808 Standard designed by Cocos-BCX for the game running on-chain. These features are related to the data structure design of the 1808 standard assets in addition to the characteristics of the BCX chain network itself.  
  
## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in RFC 2119.

Smart contracts implementing the ERC-1808 standard MUST implement all of the functions in the ERC1808 and ERC165 interface.

```solidity
pragma solidity ^0.5.0;

/// @title ERC-1808 Non homogeneous assets standard 
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1808.md
interface ERC1808 /* is ERC165 */  {

    /// @dev This emits when the ownership of any NFT is changed by any mechanism.
    /// This event is raised when (from == 0) and destroyed (to == 0).
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    
    /// @dev This emits when the NFT's approved address is changed or reconfirmed.
    event Authorized(address indexed owner, address indexed authorized, uint256 indexed tokenId);
    
    /// @dev This emits when the operator is enabled or disabled for the owner.
    /// The operator can manage all of the owner's NFT.
    event AuthorizedForAll(address indexed owner, address indexed operator, bool authorized);
  
    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address);
	
    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev  Throws if `_from` isnot the current owner.
    ///  Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. 
    /// If the NFT is combined, the transaction is not possible.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFromWithExtData(address _from, address _to, uint256 _tokenId, string calldata data) external payable;
	
    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function without an extra data parameter,
    ///  except this function just sets data to "".
    /// If the NFT is combined, the transaction is not possible.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
	
    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws if `_from` is not the current owner.
    /// Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// If the NFT is combined, the transaction is not possible.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
	
    /// @notice Get the balance of an account's NFT.
    /// @dev Throws if `_owner` is the zero address.
    /// @param _owner  The address of the token holder
    /// @return        The _owner's balance of the token type requested
	function balanceOf(address _owner) external view returns (uint256);
	
    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _authorized The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function authorize(address _authorized, uint256 _tokenId) external payable;
	
    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setAuthorizedForAll(address _operator, bool _authorized) external;
	
    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getAuthorized(uint256 _tokenId) external view returns (address);
	
    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isAuthorizedForAll(address _owner, address _operator) external view returns (bool);
 
}

interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
```

## Rationale

**NFT Identifiers**

Every NFT is identified by a struct of `address` creator, `uint` timestamp, `string` worldView and `string`baseData; inside the ERC-721 smart contract.

### Features
#### Universally Used Unique Value Expression

  The non-homogeneous digital assets defined by the 1808 Standard support a variety of data customizing and scaling approaches. They are compatible with different asset types in various games, and can be used as a general expression for various game data.   

#### Cross Use Cases without Affecting Each Other (Universe Wall)

  The extended data area is combined in the unit of zone. Each zone is bound to one or several contracts that are only responsible for itself. It represents a data area that is unique to the use case (game universe). The key-value pair information after the zone is unfolded represents a series of game business related data. Data between different zones can be read but not written mutually, that is, data changes in different use cases do not affect each other. The "universe wall" of the game will prevent these properties from affecting other universes, which will not result in the situation of "equipment downgraded in game A is also downgraded in game B".   

#### Multiverse Compatible Design

  The non-homogeneous digital assets defined by the 1808 Standard allow digital assets under the same universe to be used in different business scenarios. Therefore, there requires certain rules to balance the asset value (capability value) among different business entities.  
  
As for the 1808 Standard, when an asset instance is referenced in a new business scenario, a relative attribute is determined, which takes a certain other zone data as references, representing the basic value of the asset. The data can be identified in other business entities under the same universe. When the asset instance enters different business entities, the value in the business entity is determined according to this attribute, and other attributes such as equipment skills are supplemented by the zone data form of the business entity.   

#### Cross-Network and Cross-Standard Compatible Design

  The digital assets defined in this standard are designed to be compatible with other network non-homogeneous digital asset standards, including ERC-721, ERC-1155, ERC-998, etc. For a single non-homogeneous digital asset type defined by contracts (ERC-721, etc.), the asset instance can be compatible by defining an asset type with the same custom data structure. For nested/combined asset types defined by contracts (ERC-998, etc.), compatibility can be achieved by adding portfolio relationship data to the extended data area.   

#### Asset Owners are Allowed to Discard Specific Zone Data

  The zone data of the 1808 standard digital assets will be left with a record of the game as the number of games experienced increases. When the owner no longer needs the data generated in a certain game because of props reinforcement errors, being given negative attributes or wishing to re-challenge the game, etc., the owner can choose to delete the zone data corresponding to the game, allowing the assets to reenter the game in the initial state.   
  
  The asset owner's control over the asset zone data is limited to the complete deletion of the specified zone data, rather than the change of zone data to prevent the owner from cheating. In addition, the deletion of zone data can also effectively prevent malicious contracts from writing large amounts of junk data to specific assets, resulting in data redundancy.   

#### Assets Used as an Embedded or Combined Module on the Blockchain

  Game props and equipment may be composed of multiple components and items. Therefore, the non-homogeneous digital assets of blockchain games should also be able to be nested and contained. In this case, each non-homogeneous asset can be composed of multiple non-homogeneous assets. The main asset can contain one or more sub-assets, and the sub-assets can further contain other sub-assets.   
  
  For game scenarios with equipment construction or combination, the 1808 Standard provides a design that supports asset portfolios. The extended data contains the zone that records the combination relationship. The zone data records the information of the nested relationship when the asset is combined. Before the relationship is terminated, the ownership of nested sub-assets will not be able to be transferred.   

#### Support Complex Design of Circulation Model

  In the future, the market behavior of assets in the chain will be far beyond the traditional trading and circulation, so it is nesssary to lay a good foundation for a richer business type. Cocos-BCX refined the rights system of the assets and divided the rights of use and ownership of the assets.   
    
  1808 Standard’s design of separating the assets ownership from the right to use specifies existing permission system of the assets. The use right determines whether the user has the permission on most operations, while the ownership determines whether the user has the actual ownership and key rights to operate the assets. Certain operations are required to be co-signed by the owner and user.   
Based on BCX contract system, 1808 Standard can easily deliver the business logic unable to be implemented with traditional blockchain/contract system, such as asset lease, pledges, and pawn.   


## Backwards Compatibility

We have adopted balanceOf, totalSupply, name and symbol semantics from the ERC-20 specification. An implementation may also include a function decimals that returns uint8(0) if its goal is to be more compatible with ERC-20 while supporting this standard. However, we find it contrived to require all ERC-721 implementations to support the decimals function.

## Test Cases

ERC-1808 Token includes test cases written using Truffle.

## Implementations

An implementation can be found here: https://github.com/Cocos-BCX/ERC-1808

## References

**Standards**

1. ERC-20 Token Standard. https://eips.ethereum.org/EIPS/eip-20
1. ERC-165 Standard Interface Detection. https://eips.ethereum.org/EIPS/eip-165
1. ERC-721 Non-Fungible Token Standard. https://eips.ethereum.org/EIPS/eip-721
1. ERC-998 Composable Non-Fungible Token Standard. https://eips.ethereum.org/EIPS/eip-998
1. ERC-1155 Multi Token Standard. https://eips.ethereum.org/EIPS/eip-1155

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
