import { ethers, hardhatArguments } from 'hardhat';
import * as Config from "./config";

async function main() {
    await Config.initConfig();
    const network = hardhatArguments.network ? hardhatArguments.network : "dev";
    const [deployer] = await ethers.getSigners();
    console.log("deploy from address: ", deployer.address);

    const ZombieFactory = await ethers.getContractFactory("ZombieFactory");
    const zombieFactory = await ZombieFactory.deploy();
    console.log("ZombieFactory address: ", zombieFactory.address);
    Config.setConfig(network + '.btcs', zombieFactory.address);
    await Config.updateConfig();
}

main()
    .then(() => process.exit(0))
    .catch((err) => {
        console.error(err);
        process.exit(1);
    });
