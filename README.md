# Crypto Zombies Project

## Useful Links

---

1. [Crypto Zombies Domain](http://dev.crypto-zombie.ai-studio-work.net/)
2. [Crypto Zombies Repository](https://github.com/btc-studio/crypto-zombies-main-sc)

## What is Crypto Zombies?

---

A solidity smart contract for the Ethereum based zombie game.

- Main attraction is the random traits for every new Zombie created via random DNA generation. surprise element when Zombies feeded with cryptokitties.
- Ownership of zombie and quantity is stored in Contract as permanent storage in Blockchain. Ownership is mapped through the identity ethereum 16 Bit hexadecimal address.
- Public function in contract for the zombie creation and couples of private method defined.
- Contract safe from overflow situations.
- Zombies can attack, can be level up.
- Higher the level, higher will be the fee.
- Can be easily pluggable to any standard Crypto Platform as it the Contract works on the ERC721 Standards.

## Built with

- [Solidity is an object-oriented, high-level language for implementing smart contracts.](https://docs.soliditylang.org/en/v0.8.16/)
- [Hardhat is a development environment for Ethereum software](https://hardhat.org/)

## Prerequisites

---

1. ### [Download Metamask](https://metamask.io/)

2. ### [How to get BNB Testnet faucet](https://btc-studio.larksuite.com/wiki/wikusFiRaJa6cfEcDf9EqBnERWy#doxusUiCGCekoGECUiEFRcxfmsg) to sign contract transactions

3. ### Import BTCS Token into Metamask

- Open Metamask
- Click on `Add Token` in tab `Assets`
- Input informations
  - Token contract address: 0xEcF3F554f58e9eF274aa3DF60f9c9ca3Ba156073
  - Symbol: BTCS
  - Decimal: 18
- Click `Add tokens`

## Crypto Zombies Repository

---

### Overview

crypto-zombies-main-sc  
├── LICENSE  
├── README.md  
├── config.json  
├── contracts  
├   ├── Ownable.sol  
├   ├── SafeMath.sol  
├   ├── ZombieAttack.sol  
├   ├── ZombieBase.sol  
├   ├── ZombieFactory.sol  
├   ├── ZombieFeeding.sol  
├   ├── ZombieHelper.sol  
├   └── ZombieOwnership.sol  
├── hardhat.config.ts  
├── note.md  
├── package.json  
├── scripts  
├   ├── config.ts  
├   └── deploy.ts  
├── test  
├   └── ZombieFactory.ts  
├── tsconfig.json  
└── yarn.lock

### Directory Details

- **config.json** - Contains the address where the smart contract is being deployed to
- **contracts** - The folder contains all the logic for Crypto Zombies
- **hardhat.config.ts** - Contains network connections config
- **scripts** - Contains deploy code
- **test** - Contains unit test for the Crypto Zombies code

## Interacting with the Crypto Zombies contracts locally

---

### Install dependencies

```shell
yarn install
```

### Create `.env` file

```js
// Wallet's private Key
// To setup networks to deploy Smart Contract
PRIV_KEY = "";

// Wallet's Seed Phrase
// To setup dev network to deploy Smart Contract
PRIV_KEY = "";
MNEMONIC = "";

// API Key for Verifying Smart Contract
API_KEY = "";
```

- [How to export PRIV_KEY](https://btc-studio.larksuite.com/wiki/wikusWC0RM0J8YikBm1R3hy1Hph)
- [How to export Seed Phrase](https://btc-studio.larksuite.com/wiki/wikusWC0RM0J8YikBm1R3hy1Hph)
- [How to get an API Key](https://docs.bscscan.com/getting-started/viewing-api-usage-statistics)

### Compile

```shell
yarn compile
```

### Deploy to bsctest network

```shell
yarn deploy bsctest
```

### Verify CryptoZombie Contract

```shell
yarn verify bsctest <CRYPTO_ZOMBIE_SMART_CONTRACT_ADDRESS> <TOKEN_CONTRACT_ADDRESS>
```

### Verify NFT Marketplace Contract

```shell
yarn verify bsctest <MARKETPLACE_SMART_CONTRACT_ADDRESS> <MARKET_FEE>
```

## Network

---

development

## BTCS Tokens

---

|  TOKEN   |                  ADDRESS                   |
| :------: | :----------------------------------------: |
| **BTCS** | 0xEcF3F554f58e9eF274aa3DF60f9c9ca3Ba156073 |

## Contracts

---

|      CONTRACT      |                  ADDRESS                   |
| :----------------: | :----------------------------------------: |
| **Crypto Zombies** | 0xa193cd47122bEAE47979ac146Fd04f9f45d33057 |
