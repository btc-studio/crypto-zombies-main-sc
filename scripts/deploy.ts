import { ethers, hardhatArguments } from "hardhat";
import * as Config from "./config";

async function main() {
  await Config.initConfig();
  const network = hardhatArguments.network ? hardhatArguments.network : "dev";
  const [deployer] = await ethers.getSigners();
  console.log("deploy from address: ", deployer.address);

  const tokenContract = "0x3986C657C4597064825b4eaeC2FFac4fc501644f";

  console.log("BTCS token contract address: ", tokenContract);

  // Set BTCS token contract address to config.json
  Config.setConfig(network + ".btcs", tokenContract);

  // --------------------------------------------------------------------
  // Migrator is the leaf in Smart Contract's hierarchical
  const CryptoZombie = await ethers.getContractFactory("Migrator");
  const cryptoZombie = await CryptoZombie.deploy(tokenContract);
  await cryptoZombie.deployed();
  console.log("CryptoZombie contract address: ", cryptoZombie.address);

  // Set CryptoZombie contract address to config.json
  Config.setConfig(network + ".cryptoZombie", cryptoZombie.address);

  await Config.updateConfig();
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
