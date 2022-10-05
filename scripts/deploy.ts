import { ethers, hardhatArguments } from 'hardhat';
import * as Config from './config';

async function main() {
  await Config.initConfig();
  const network = hardhatArguments.network ? hardhatArguments.network : 'dev';
  const [deployer] = await ethers.getSigners();
  console.log('deploy from address: ', deployer.address);

  const tokenContract = '0xEcF3F554f58e9eF274aa3DF60f9c9ca3Ba156073';
  // GiftPack is the leaf in Smart Contract's hierarchical
  const CryptoZombie = await ethers.getContractFactory('GiftPack');
  const cryptoZombie = await CryptoZombie.deploy(tokenContract);
  await cryptoZombie.deployed();
  console.log('Zombie address: ', cryptoZombie.address);
  Config.setConfig(network + '.btcs', cryptoZombie.address);
  await Config.updateConfig();
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
