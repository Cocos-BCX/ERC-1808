/* global artifacts, contract, it, assert */
/* eslint-disable prefer-reflect */

import expectThrow from './helpers/expectThrow';

const MyChain = artifacts.require("MyChain");
const ERC1808Mintable = artifacts.require('MyERC1808Mintable');
const BigNumber = require('bignumber.js');

let user1;
let user2;
let chainContract;
let mainContract;
let tx;
let owner;
let worldView;
let baseData;

let gasUsedRecords = [];
let gasUsedTotal = 0;

function recordGasUsed(_tx, _label) {
  gasUsedTotal += _tx.receipt.gasUsed;
  gasUsedRecords.push(String(_label + ' \| GasUsed: ' + _tx.receipt.gasUsed).padStart(60));
}

function printGasUsed() {
  console.log('------------------------------------------------------------');
  for (let i = 0; i < gasUsedRecords.length; ++i) {
    console.log(gasUsedRecords[i]);
  }
  console.log(String("Total: " + gasUsedTotal).padStart(60));
  console.log('------------------------------------------------------------');
}

async function testCreateNFT(_owner, _worldView, _baseData, gasMessage='testCreateNFT') {

  let  ll = await mainContract.balanceOf(_owner);
  assert(ll == 0, 'Unexpected number of nft asset, it should be 0');

  await mainContract.setBusinessAdmin(_owner, true);
  let tt = await mainContract.isBusinessAdmin(_owner);
  assert(tt, 'it should be Business Admin');

  tx = await mainContract.createNFT(_owner, _worldView, _baseData);
  recordGasUsed(tx, gasMessage);
  ll = await mainContract.balanceOf(_owner);
  assert(ll == 1, 'Unexpected number  of nft asset, it should be 1');

  ll = await mainContract.ownerOf(1);
  assert(ll == user1, 'Unexpected owner of nft asset, it should be user1');

  ll = await mainContract.balanceOf(_owner);
  assert(ll == 1, 'Unexpected balance of owner');

  ll = await mainContract.totalSupply();
  assert(ll == 1, 'Unexpected total Supply');

  ll = await mainContract.getNFTArrayLength();
  assert(ll == 2, 'Unexpected NFT Array Length');

  ll = await mainContract.getNFT(1);
  assert(ll.creator == user1, 'Unexpected NFT creator');
  assert(ll.worldView == _worldView, 'Unexpected NFT worldView');
  assert(ll.baseData == _baseData, 'Unexpected NFT baseData');

  ll = await mainContract.getOwnNFTIds(_owner);
  assert(ll[0] == 1, 'Unexpected NFT Id');

  ll = await mainContract.getNFTs(ll);
  assert(ll[0][0] == _owner, 'Unexpected NFT owner');
  assert(ll[0][2] == _worldView, 'Unexpected NFT worldView');
  assert(ll[0][3] == _baseData, 'Unexpected NFT baseData');

  ll = await mainContract.getAuthorized(1);
  assert(ll != _owner, 'Unexpected NFT owner');

  await mainContract.authorize(_owner, 1);
  ll = await mainContract.getAuthorized(1);
  assert(ll == _owner, 'Unexpected NFT owner');

  await mainContract.authorize(user2, 1);
  ll = await mainContract.getAuthorized(1);
  assert(ll == user2, 'Unexpected NFT authorize');

  ll = await mainContract.isAuthorizedForAll(_owner, user1);
  assert(!ll, 'Unexpected NFT is Authorized For All');

  ll = await mainContract.isAuthorizedForAll(_owner, user2);
  assert(!ll, 'Unexpected NFT is Authorized For All');

  mainContract.setAuthorizedForAll(_owner, true)
  ll = await mainContract.isAuthorizedForAll(_owner, user1);
  assert(ll, 'Unexpected NFT is Authorized For All');

  mainContract.setAuthorizedForAll(user2, true)
  ll = await mainContract.isAuthorizedForAll(_owner, user2);
  assert(ll, 'Unexpected NFT is Authorized For All');
}

async function testDestroyNFT(_owner, _worldView, _baseData, gasMessage='testDestroyNFT') {

  let  ll = await mainContract.balanceOf(_owner);
  assert(ll == 1, 'Unexpected number of nft asset, it should be 1');

  tx = await mainContract.destroyNFT(1);
  recordGasUsed(tx, gasMessage);
  ll = await mainContract.balanceOf(_owner);
  assert(ll == 0, 'Unexpected number  of nft asset, it should be 0');

  ll = await mainContract.balanceOf(_owner);
  assert(ll == 0, 'Unexpected balance of owner');

  ll = await mainContract.totalSupply();
  assert(ll == 0, 'Unexpected total Supply');

  ll = await mainContract.getNFTArrayLength();
  assert(ll == 2, 'Unexpected NFT Array Length');

  ll = await mainContract.getOwnNFTIds(_owner);
  assert(ll != [], 'Unexpected NFT Id');

  ll = await mainContract.getNFTs(ll);
  assert(ll != [], 'Unexpected NFT infos');

  tx = await mainContract.setBusinessAdmin(_owner, false);
  recordGasUsed(tx, gasMessage);
  let tt = await mainContract.isBusinessAdmin(_owner);
  assert(!tt, 'it should not be Business Admin');
}

async function testCreateNFTLinkTwoChainId(_owner, _worldView, _baseData, gasMessage='testCreateNFTLinkTwoChainId') {

  let ll = await mainContract.balanceOf(_owner);
  assert(ll == 0, 'Unexpected number of nft asset, it should be 0');

  tx = await mainContract.setBusinessAdmin(user1, true);
  recordGasUsed(tx, 'testCreateNFTLinkTwoChainId setBusinessAdmin');
  let tt = await mainContract.isBusinessAdmin(user1);
  assert(tt, 'it should be Business Admin');

  //--------------------
  tx = await chainContract.setBusinessAdmin(user1, true);
  recordGasUsed(tx, 'testCreateNFTLinkTwoChainId chainContract setBusinessAdmin');
  tt = await chainContract.isBusinessAdmin(user1);
  assert(tt, 'it should be Business Admin');

  tx = await chainContract.addChain("COCOS-TEST");
  recordGasUsed(tx, 'testCreateNFTLinkTwoChainId addChain');
  tt = await chainContract.getChainsCount();
  assert(tt == 1, 'chains count should equal 1');

  tx = await mainContract.createNFT(_owner, _worldView, _baseData, 1, "COCOS-TEST");
  recordGasUsed(tx, gasMessage);

  ll = await mainContract.balanceOf(_owner);
  assert(ll == 1, 'Unexpected number  of nft asset, it should be 1');

  ll = await mainContract.ownerOf(2);
  assert(ll == _owner, 'Unexpected owner of nft asset, it should be user1');

  ll = await mainContract.totalSupply();
  assert(ll == 1, 'Unexpected total Supply');

  ll = await mainContract.getNFTArrayLength();
  assert(ll == 3, 'Unexpected NFT Array Length');

  ll = await mainContract.getNFT(2);
  assert(ll.creator == user1, 'Unexpected NFT creator');
  assert(ll.worldView == _worldView, 'Unexpected NFT worldView');
  assert(ll.baseData == _baseData, 'Unexpected NFT baseData');

  ll = await mainContract.getOwnNFTIds(_owner);
  assert(ll[0] == 2, 'Unexpected NFT Id');

  ll = await mainContract.getNFTs(ll);
  assert(ll[0][0] == user1, 'Unexpected NFT owner');
  assert(ll[0][2] == _worldView, 'Unexpected NFT worldView');
  assert(ll[0][3] == _baseData, 'Unexpected NFT baseData');

  ll = await mainContract.getAuthorized(2);
  assert(ll != _owner, 'Unexpected NFT owner');

  tx = await mainContract.authorize(_owner, 2);
  recordGasUsed(tx, 'testCreateNFTLinkTwoChainId authorize');
  ll = await mainContract.getAuthorized(2);
  assert(ll == _owner, 'Unexpected NFT owner');

  tx = await mainContract.authorize(user2, 2);
  recordGasUsed(tx, 'testCreateNFTLinkTwoChainId authorize');
  ll = await mainContract.getAuthorized(2);
  assert(ll == user2, 'Unexpected NFT owner');

  ll = await mainContract.isAuthorizedForAll(_owner, user2);
  assert(ll, 'Unexpected NFT is Authorized For All');

  mainContract.setAuthorizedForAll(user2, false)
  ll = await mainContract.isAuthorizedForAll(_owner, user2);
  assert(!ll, 'Unexpected NFT is Authorized For All');

  ll = await mainContract.isAuthorizedForAll(_owner, user1);
  assert(ll, 'Unexpected NFT is Authorized For All');

  mainContract.setAuthorizedForAll(user1, false)
  ll = await mainContract.isAuthorizedForAll(_owner, user1);
  assert(!ll, 'Unexpected NFT is Authorized For All');

  ll = await mainContract.isExistTokenId(1, "COCOS-TEST");
  assert(ll, 'Unexpected NFT should be exist');

  ll = await mainContract.getTokenId(1, "COCOS-TEST");
  assert(ll == 2, 'Unexpected NFT Token Id');

  tx = await chainContract.addChain("COCOS-TEST2");
  recordGasUsed(tx, 'testCreateNFTLinkTwoChainId addChain');
  tt = await chainContract.getChainsCount();
  assert(tt == 2, 'chains count should equal 1');
}

async function testSafeTransferFromWithExtData(_from, _to, _tokenId, _data, gasMessage='testSafeTransferFromWithExtData') {

  ll = await mainContract.totalSupply();
  assert(ll == 1, 'Unexpected total Supply');

  ll = await mainContract.ownerOf(_tokenId);
  assert(ll == _from, 'Unexpected owner of nft asset, it should be user1');

  let  ll = await mainContract.balanceOf(_from);
  assert(ll == 1, 'Unexpected number of nft asset, it should be 1');

  tx = await mainContract.safeTransferFromWithExtData(_from, _to, _tokenId, _data);
  recordGasUsed(tx, gasMessage);

  ll = await mainContract.balanceOf(_from);
  assert(ll == 0, 'Unexpected number  of nft asset, it should be 0');

  ll = await mainContract.balanceOf(_to);
  assert(ll == 1, 'Unexpected number  of nft asset, it should be 1');

  ll = await mainContract.ownerOf(_tokenId);
  assert(ll == _to, 'Unexpected owner of nft asset, it should be user1');

  ll = await mainContract.totalSupply();
  assert(ll == 1, 'Unexpected total Supply');

  ll = await mainContract.getNFTArrayLength();
  assert(ll == 3, 'Unexpected NFT Array Length');

  ll = await mainContract.getNFT(2);
  assert(ll.creator == _from, 'Unexpected NFT creator');

  ll = await mainContract.getOwnNFTIds(_to);
  assert(ll[0] == 2, 'Unexpected NFT Id');

  ll = await mainContract.isAuthorizedForAll(_from, user1);
  assert(!ll, 'Unexpected NFT is Authorized For All');

  ll = await mainContract.isAuthorizedForAll(_from, user2);
  assert(!ll, 'Unexpected NFT is Authorized For All');

  mainContract.setAuthorizedForAll(_to, true)
  ll = await mainContract.isAuthorizedForAll(_from, user2);
  assert(ll, 'Unexpected NFT is Authorized For All');

  mainContract.setAuthorizedForAll(_from, true)
  ll = await mainContract.isAuthorizedForAll(_from, user1);
  assert(ll, 'Unexpected NFT is Authorized For All');

  ll = await mainContract.getAuthorized(2);
  assert(ll != _from, 'Unexpected NFT owner');

}

async function testSafeTransferByContract(_to, _tokenId, gasMessage='testSafeTransferByContract') {

  ll = await mainContract.balanceOf(_to);
  assert(ll == 1, 'Unexpected number  of nft asset, it should be 1');

  ll = await mainContract.totalSupply();
  assert(ll == 2, 'Unexpected total Supply');

  ll = await mainContract.ownerOf(_tokenId);
  assert(ll == owner, 'Unexpected owner of nft asset, it should be user1');

  let  ll = await mainContract.balanceOf(owner);
  assert(ll == 1, 'Unexpected number of nft asset, it should be 1');

  tx = await mainContract.safeTransferByContract(_tokenId, _to);
  recordGasUsed(tx, gasMessage);

  ll = await mainContract.balanceOf(owner);
  assert(ll == 0, 'Unexpected number  of nft asset, it should be 0');

  ll = await mainContract.balanceOf(_to);
  assert(ll == 2, 'Unexpected number  of nft asset, it should be 2');

  ll = await mainContract.ownerOf(_tokenId);
  assert(ll == _to, 'Unexpected owner of nft asset, it should be user2');

  ll = await mainContract.totalSupply();
  assert(ll == 2, 'Unexpected total Supply');

}

contract('ERC1808 - tests core 1808 functionality.', (accounts) => {
  before(async () => {
    user1 = accounts[0];
    user2 = accounts[1];

    worldView = "TEST";
    baseData = "TEST";
    owner = user1
    chainContract = await MyChain.deployed();
    mainContract = await ERC1808Mintable.deployed();
  });

  after(async() => {
    printGasUsed();
  });

  it('createNFT to create one nft asset', async () => {
    await testCreateNFT(owner, worldView, baseData,'testCreateNFT')
  });

  it('testDestroyNFT to destroy one nft asset', async () => {
    await testDestroyNFT(owner, worldView, baseData, 'testDestroyNFT')
  });

  it('createNFT to create one nft asset, and link to a chain Id', async () => {
    await testCreateNFTLinkTwoChainId(user1, worldView, baseData, 'testCreateNFTLinkTwoChainId')
  });

  it('createNFT to create one nft asset, and link to a chain Id', async () => {
    await testSafeTransferFromWithExtData(user1, user2, 2, '', 'testSafeTransferFromWithExtData')
  });

  it('createNFT to create one nft asset', async () => {
    worldView = "TEST2";
    baseData = "TEST2";
    await expectThrow(mainContract.createNFT(owner, worldView, baseData))
  });

  it('transferByContract to transfer one nft asset', async () => {
    await testSafeTransferByContract(user2, 3)
  });
});
