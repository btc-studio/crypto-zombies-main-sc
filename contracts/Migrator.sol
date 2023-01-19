// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./GiftPack.sol";
import "./ZombieBase.sol";

contract Migrator is GiftPack {
    ERC20 public oldFtContract;
    ERC20 public newFtContract;
    GiftPack public oldNftContract;
    address oldFtContractAddress;
    address newFtContractAddress;
    address oldNftContractAddress;
    bool public isMigrated;

    // ======================== Implement ========================
    constructor(address _token) GiftPack(_token) {}

    function setFtContract(address _oldFt, address _newFt) public onlyOwner {
        oldFtContract = ERC20(_oldFt);
        newFtContract = ERC20(_newFt);
        oldFtContractAddress = _oldFt;
        newFtContractAddress = _newFt;
    }

    function setNftContract(address _oldNft) public onlyOwner {
        oldNftContract = GiftPack(_oldNft);
    }

    function migrateData() public onlyOwner {
        require(isMigrated == false, "Already migrated");
        require(msg.sender == oldNftContract.owner(), "OW_SC");

        isMigrated = true;

        // Owner
        owner = oldNftContract.owner();

        // --- User ---
        userCount = oldNftContract.userCount();
        for (uint i = 1; i <= userCount; i++) {
            (
                uint id,
                address walletAddress,
                uint16 level,
                uint256 exp
            ) = oldNftContract.users(i);
            users[i] = User(id, walletAddress, level, exp);
        }

        // --- Token ---
        tokenCount = oldNftContract.tokenCount();

        // --- Dna ---
        dnaCount = oldNftContract.dnaCount();

        for (uint i = 0; i < dnaCount; i++) {
            dnasKeys.push(oldNftContract.dnasKeys(i));
            (uint id, uint dna, uint rarity, bool isOpened) = oldNftContract
                .dnas(dnasKeys[i]);
            dnas[dnasKeys[i]] = Dna(id, dna, rarity, isOpened);
        }

        // --- Zombie ---
        zombieCount = oldNftContract.zombieCount();

        for (uint i = 0; i < zombieCount; i++) {
            zombiesKeys.push(oldNftContract.zombiesKeys(i));
            (
                uint id,
                string memory name,
                uint dna,
                uint16 level,
                uint16 winCount,
                uint16 lossCount,
                uint16 breedCount,
                ZombieBase.Sex sex,
                uint16 healthPoint,
                uint16 attack,
                uint16 defense,
                uint16 criticalRate,
                uint16 criticalDamage,
                uint16 speed,
                uint16 combatPower,
                string memory rarity,
                uint exp
            ) = oldNftContract.zombies(zombiesKeys[i]);
            zombies[zombiesKeys[i]] = Zombie(
                id,
                name,
                dna,
                level,
                winCount,
                lossCount,
                breedCount,
                sex,
                healthPoint,
                attack,
                defense,
                criticalRate,
                criticalDamage,
                speed,
                combatPower,
                rarity,
                exp
            );
        }

        // --- seenWalletOpenStarterPack() ---
        for (uint i = 1; i <= userCount; i++) {
            seenWalletOpenStarterPack[users[i].walletAddress] = oldNftContract
                .checkOpenStarterPack(users[i].walletAddress);
        }

        // Migrate ERC-721 data
        for (uint i = 1; i <= tokenCount; i++) {
            _safeMint(oldNftContract.ownerOf(i), i);
        }

        // Migrate ERC-20 data if BTCS Smart Contract changed
        if (oldFtContractAddress != newFtContractAddress) {
            for (uint i = 1; i <= userCount; i++) {
                newFtContract.transfer(
                    users[i].walletAddress,
                    oldFtContract.balanceOf(users[i].walletAddress)
                );
            }
        }
    }
}
