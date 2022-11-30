import { ethers, hardhatArguments } from "hardhat";
import * as Config from "./config";

async function main() {
  await Config.initConfig();
  const network = hardhatArguments.network ? hardhatArguments.network : "dev";
  const [deployer] = await ethers.getSigners();
  console.log("deploy from address: ", deployer.address);

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
