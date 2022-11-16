const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("GiftPack", () => {
  let mainSmartContract, btcsContract;
  let deployer, addr1, addr2;

  beforeEach(async () => {
    const btcsTokenContractFactory = await ethers.getContractFactory(
      "BTCSToken"
    );
    const mainSmartContractFactory = await ethers.getContractFactory(
      "GiftPack"
    );
    [deployer, addr1, addr2] = await ethers.getSigners();

    btcsContract = await btcsTokenContractFactory.deploy();
    mainSmartContract = await mainSmartContractFactory.deploy(
      btcsContract.address
    );
  });

  describe("openStarterPack", async () => {
    it("Should return false if new wallet checkOpenStarterPack", async () => {
      const isOpenStarterPack = await mainSmartContract.checkOpenStarterPack(
        addr1.address
      );
      expect(isOpenStarterPack).to.be.false;
    });

    it("Should openStarterPack without error", async () => {
      expect(await mainSmartContract.connect(addr1).openStarterPack("user")).to
        .not.be.undefined;
    });

    it("Should return true if wallet already opened starter pack", async () => {
      await mainSmartContract.connect(addr1).openStarterPack("user");
      await mainSmartContract.connect(addr2).openStarterPack("user");
      const isOpenStarterPack = await mainSmartContract.checkOpenStarterPack(
        addr1.address
      );
      expect(isOpenStarterPack).to.be.true;
    });

    it("Should throw error openStarterPack if wallet already opened starter pack", async () => {
      await mainSmartContract.connect(addr1).openStarterPack("user");
      try {
        await mainSmartContract.connect(addr1).openStarterPack("user");
      } catch (err) {
        expect(err).to.not.be.undefined;
      }
    });

    it("Should create new user", async () => {
      await mainSmartContract.connect(addr1).openStarterPack("user");
      const user = await mainSmartContract.users(1);
      expect(user.name).to.equal("user");
      expect(user.walletAddress).to.equal(addr1.address);
    });
  });
});
