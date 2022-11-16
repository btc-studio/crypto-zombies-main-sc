const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("Migrator", () => {
  let mainSmartContract,
    btcsContract,
    oldMainSmartContract,
    newMainSmartContract;
  let deployer, addr1, addr2;

  beforeEach(async () => {
    const btcsTokenContractFactory = await ethers.getContractFactory(
      "BTCSToken"
    );
    const mainSmartContractFactory = await ethers.getContractFactory(
      "GiftPack"
    );
    const migratorContractFactory = await ethers.getContractFactory("Migrator");
    [deployer, addr1, addr2] = await ethers.getSigners();

    btcsContract = await btcsTokenContractFactory.deploy();

    // const oldMainSmartContract = "0x42b4985B3191e699Ec4196E2f9C845ee769808a4";
    oldMainSmartContract = await mainSmartContractFactory.deploy(
      btcsContract.address
    );

    newMainSmartContract = await migratorContractFactory.deploy(
      btcsContract.address,
      btcsContract.address,
      oldMainSmartContract.address
    );
  });

  describe("Migrate", function () {
    beforeEach(async function () {
      await newMainSmartContract.connect(deployer).migrateData();
    });

    it("Should fail if the Smart Contract has already been migrated", async function () {
      expect(await newMainSmartContract.isMigrated()).to.equal(true);
    });
  });
});
