import { ethers, hardhatArguments } from 'hardhat';
import * as Config from "./config";

async function main() {
    await Config.initConfig();
    const network = hardhatArguments.network ? hardhatArguments.network : "dev";
    const [deployer] = await ethers.getSigners();
    console.log("deploy from address: ", deployer.address);

    const tokenContract = "0x83B5a8807FAede3De5b51a3096ac2C14d55e3cB5";
    const ZombieHelper = await ethers.getContractFactory("ZombieAttack");
    const zombieHelper = await ZombieHelper.deploy(tokenContract);
    await zombieHelper.deployed();
    console.log("Zombie address: ", zombieHelper.address);
    Config.setConfig(network + '.btcs', zombieHelper.address);
    await Config.updateConfig();
}

main()
    .then(() => process.exit(0))
    .catch((err) => {
        console.error(err);
        process.exit(1);
    });
