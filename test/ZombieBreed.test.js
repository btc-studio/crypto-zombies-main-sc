const { expect } = require("chai");
const { ethers } = require("hardhat");

const toWei = (num) => ethers.utils.parseEther(num.toString()); // 1 ether = 10**18 wei (wei is the smallest unit of ether)
const fromWei = (num) => ethers.utils.formatEther(num);

describe("ZombieBreed", function () {
  let deployer, addr1, addr2, ft, nft;
  beforeEach(async function () {
    // Get contract factories
    const BTCS = await ethers.getContractFactory("BTCSToken");
    const ZombieNFT = await ethers.getContractFactory("GiftPack");
    // Get signers
    [deployer, addr1, addr2] = await ethers.getSigners();

    ft = await BTCS.deploy();
    nft = await ZombieNFT.deploy(ft.address);

    // Send BTCS to Crypto Zombies Smart Contract (to be able to Attack)
    ft.transfer(nft.address, toWei(1000));
  });

  describe("Breed", function () {
    beforeEach(async function () {
      // addr1 creates 3 random DNAs
      await nft.connect(addr1).openStarterPack("user");
    });

    it("Should fail because of not enough level", async function () {
      // Find opponent
      await expect(
        nft.connect(addr1).breedZombie(4, 5, "Zng")
      ).to.be.revertedWith("");
    });
  });
});
