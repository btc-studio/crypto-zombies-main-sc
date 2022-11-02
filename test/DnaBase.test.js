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
      await nft.connect(addr1).createManyDnas(3);
      // addr2 creates 3 random DNAs
      await nft.connect(addr2).createManyDnas(3);
    });

    it("Should create 3 new DNA and instantly open it for user", async function () {
      expect(await nft.tokenCount()).to.equal(12);
      expect(await nft.dnaCount()).to.equal(6);
      expect(await nft.zombieCount()).to.equal(6);

      // Owner of the DNA should be addr1
      expect(await nft.ownerOf(1)).to.equal(addr1.address);

      // After open DNA Sample -> dna.isOpened should be 'true'
      const openedDna = await nft.dnas(1);
      expect(openedDna.isOpened).to.equal(true);

      // Get zombie from zombies mapping then check fields to ensure they are correct
      const zombie = await nft.zombies(4);

      expect(zombie.dna).to.equal(openedDna.dna);
    });

    it("Should fail if the account opens the DNA is not the owner", async function () {
      const dna = await nft.dnas(1);
      await expect(nft.connect(addr2).openDna(dna.id)).to.be.revertedWith(
        "Only owner of the DNA can open it"
      );
    });

    it("Should fail if user opens the opened DNA Sample", async function () {
      const dna = await nft.dnas(1);
      await expect(nft.connect(addr1).openDna(dna.id)).to.be.revertedWith(
        "This DNA Sample has been opened"
      );
    });
  });
});
