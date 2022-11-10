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

  describe("Zombie Helper", function () {
    beforeEach(async function () {
      // addr1 creates 3 random DNAs
      await nft.connect(addr1).openStarterPack();
      // addr2 creates 3 random DNAs
      await nft.connect(addr2).openStarterPack();
    });

    it("Should change name of the Zombie", async function () {
      await nft.connect(addr1).changeZombieName(4, "Zuong");

      const zombie = await nft.zombies(4);
      // Owner of the DNA should be addr1
      expect(zombie.name).to.equal("Zuong");
    });

    it("Should fail if the account change the Zombie name is not the owner of the Zombie", async function () {
      await expect(
        nft.connect(addr2).changeZombieName(4, "Zuong Fail")
      ).to.be.revertedWith("Only owner of the Zombie can change it's name");
    });

    it("Should fail if the new name of the Zombie is empty", async function () {
        await expect(
          nft.connect(addr1).changeZombieName(4, "")
        ).to.be.revertedWith("Zombie name cannot be empty");
      });
  });
});
