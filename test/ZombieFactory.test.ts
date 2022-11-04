import { expect } from "chai";
import { loadFixture } from "ethereum-waffle";
import { ethers } from "hardhat";

describe("ZombieFactory", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, addr1, addr2] = await ethers.getSigners();

    const tokenContract = "0x5C04B8257C62B77165Ff8025e285B0D2a2cf42Be";
    const ZombieFactory = await ethers.getContractFactory("GiftPack");
    const zombieFactory = await ZombieFactory.deploy(tokenContract);
    await zombieFactory.deployed();

    return { zombieFactory, owner, addr1, addr2 };
  }

  describe("Create Zombie", function () {
    it("Should create zombies with full stats", async function () {
      const { zombieFactory, owner, addr1, addr2 } = await loadFixture(
        deployOneYearLockFixture
      );

      await zombieFactory.connect(addr1).openStarterPack();
      const zombie = await zombieFactory.zombies(4);

      // 1, 2, 3: Dnas
      // 4, 5, 6: Zombies
      expect(zombie.id).to.equal(4);
      expect(zombie.level).to.equal(1);
      expect(zombie.winCount).to.equal(0);
      expect(zombie.lossCount).to.equal(0);
      expect(zombie.breedCount).to.equal(0);
      expect(zombie.healthPoint).to.equal(10);
      expect(zombie.attack).to.equal(10);
      expect(zombie.defense).to.equal(10);
      expect(zombie.criticalRate).to.equal(10);
      expect(zombie.criticalDamage).to.equal(10);
      expect(zombie.speed).to.equal(10);
      expect(zombie.combatPower).to.equal(60);
      expect(zombie.exp).to.equal(0);
    });
  });
});
