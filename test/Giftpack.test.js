const { expect, assert } = require('chai');
const { ethers } = require('hardhat');

describe('GiftPack', () => {
  let mainSmartContract, btcsContract;
  let deployer, addr1, addr2;

  beforeEach(async () => {
    const btcsTokenContractFactory = await ethers.getContractFactory("BTCSToken");
    const mainSmartContractFactory = await ethers.getContractFactory("GiftPack");
    [deployer, addr1, addr2] = await ethers.getSigners();

    btcsContract = await btcsTokenContractFactory.deploy();
    mainSmartContract = await mainSmartContractFactory.deploy(btcsContract.address);
  });

  describe('openStaterPack', async () => {
    it('Should return false if new wallet checkOpenStarterPack', async () => {
      const isOpenStaterPack = await mainSmartContract.checkOpenStarterPack(addr1.address);
      expect(isOpenStaterPack).to.be.false;
    });

    it('Should openStaterPack without error', async () => {
      expect(await mainSmartContract.connect(addr1).openStaterPack()).to.not.be.undefined;
    });

    it('Should return true if wallet already opened stater pack', async () => {
      await mainSmartContract.connect(addr1).openStaterPack();
      expect(await mainSmartContract.checkOpenStarterPack(addr1.address)).to.be.true;
    });

    it('Should throw error openStaterPack if wallet already opened stater pack', async () => {
      await mainSmartContract.connect(addr1).openStaterPack();
      try {
        await mainSmartContract.connect(addr1).openStaterPack();
      } catch (err) {
        expect(err).to.not.be.undefined;
      }
    });
  });
});
