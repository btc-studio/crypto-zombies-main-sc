import { ethers, hardhatArguments } from "hardhat";
import * as Config from "./config";

async function main() {
  await Config.initConfig();
  const network = hardhatArguments.network ? hardhatArguments.network : "dev";
  const [deployer] = await ethers.getSigners();
  console.log("deploy from address: ", deployer.address);

  const oldTokenContract = "0x3986C657C4597064825b4eaeC2FFac4fc501644f";
  const newTokenContract = "0x3986C657C4597064825b4eaeC2FFac4fc501644f";
  const oldCryptoZombieContract = "0xf509F36574B0Fc25f8D855d97685B3D5D8419a22";

  console.log("Old BTCS token contract address: ", oldTokenContract);
  console.log("New BTCS token contract address: ", newTokenContract);
  // Set BTCS token contract address to config.json
  Config.setConfig(network + ".btcs", newTokenContract);

  // --------------------------------------------------------------------
  // GiftPack is the leaf in Smart Contract's hierarchical
  const CryptoZombie = await ethers.getContractFactory("Migrator");
  const cryptoZombie = await CryptoZombie.deploy(
    oldTokenContract,
    newTokenContract,
    oldCryptoZombieContract
  );
  await cryptoZombie.deployed();
  console.log("CryptoZombie contract address: ", cryptoZombie.address);
  // Set CryptoZombie contract address to config.json
  Config.setConfig(network + ".cryptoZombie", cryptoZombie.address);

  // --------------------------------------------------------------------
  const marketFeePercent = 10;
  const Marketplace = await ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy(marketFeePercent);
  await marketplace.deployed();
  console.log("Marketplace contract address: ", marketplace.address);
  // Set Marketplace contract address to config.json
  Config.setConfig(network + ".marketplace", marketplace.address);

  await Config.updateConfig();
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
