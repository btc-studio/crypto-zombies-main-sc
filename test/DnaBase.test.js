const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DnaBase", function () {
  let deployer, addr1, addr2, ft, nft;
  beforeEach(async function () {
    // Get contract factories
    const BTCS = await ethers.getContractFactory("BTCSToken");
    const ZombieNFT = await ethers.getContractFactory("GiftPack");
    // Get signers
    [deployer, addr1, addr2] = await ethers.getSigners();

    ft = await BTCS.deploy();
    nft = await ZombieNFT.deploy(ft.address);
  });

  describe("DNA Sample", function () {
    beforeEach(async function () {
      // addr1 creates 3 random DNAs
      await nft.connect(addr1).openStarterPack();
      // addr2 creates 3 random DNAs
      await nft.connect(addr2).openStarterPack();
    });

    it("Should create 3 new DNA and instantly open it for user", async function () {
      expect(await nft.tokenCount()).to.equal(12);
      expect(await nft.dnaCount()).to.equal(6);
      expect(await nft.zombieCount()).to.equal(6);

      // Owner of the DNA should be addr1
      expect(await nft.ownerOf(1)).to.equal(addr1.address);

      // After open DNA Sample -> dna should be removed from mapping (which mean everything turns to 0)
      const openedDna = await nft.dnas(1);
      expect(openedDna.id).to.equal(0);
    });
  });
});
