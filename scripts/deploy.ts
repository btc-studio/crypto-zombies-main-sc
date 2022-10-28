import { ethers, hardhatArguments } from "hardhat";
import * as Config from "./config";

async function main() {
  await Config.initConfig();
  const network = hardhatArguments.network ? hardhatArguments.network : "dev";
  const [deployer] = await ethers.getSigners();
  console.log("deploy from address: ", deployer.address);

  const tokenContract = "0xEcF3F554f58e9eF274aa3DF60f9c9ca3Ba156073";

  console.log("BTCS token contract address: ", tokenContract);
  // Set BTCS token contract address to config.json
  Config.setConfig(network + ".btcs", tokenContract);

  // --------------------------------------------------------------------
  // GiftPack is the leaf in Smart Contract's hierarchical
  const CryptoZombie = await ethers.getContractFactory("GiftPack");
  const cryptoZombie = await CryptoZombie.deploy(tokenContract);
  await cryptoZombie.deployed();
  console.log("CryptoZombie contract address: ", cryptoZombie.address);
  // Set CryptoZombie contract address to config.json
  Config.setConfig(network + ".cryptoZombie", cryptoZombie.address);

  // --------------------------------------------------------------------
  const marketFeePercent = 1;
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
