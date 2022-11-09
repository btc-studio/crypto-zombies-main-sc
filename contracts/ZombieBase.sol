// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./DnaBase.sol";
import "./SafeMath.sol";

uint8 constant MAX_BREEDING_POINTS = 8;
uint8 constant LVL_CAN_BREED = 10;
uint8 constant LVL_MAX = 20;
uint constant BASE_EXP = 100;
uint constant AMOUNT_REWARD = 10;

contract ZombieBase is DnaBase {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    uint public tokenCount;
    uint public zombieCount;
    uint[] public zombiesKeys; // Contain keys of the zombies mapping (for iterating)
    mapping(uint => Zombie) public zombies;
    uint public dnaCount;
    uint[] public dnasKeys; // Contain keys of the dnas mapping (for iterating)
    mapping(string => uint) rarityToGrowStat; // Mapping rarity to grow stat ('A' -> 9, 'S' -> 11)

    struct Zombie {
        uint id;
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
        uint16 breedCount;
        Sex sex;
        uint32 healthPoint;
        uint32 attack;
        uint32 defense;
        uint32 criticalRate;
        uint32 criticalDamage;
        uint32 speed;
        uint32 combatPower;
        string rarity;
        uint exp;
    }

    uint32[] public EXP_UP_LEVEL = [
        8,
        280,
        742,
        1444,
        2434,
        3760,
        5451,
        7651,
        10291,
        13411,
        17051,
        21251,
        26051,
        31457,
        37541,
        39296,
        43806,
        50944,
        60709
    ];

    enum Sex {
        Male,
        Female
    }

    constructor(address _token) DnaBase(_token) {
        rarityToGrowStat["C"] = 6;
        rarityToGrowStat["B"] = 8;
        rarityToGrowStat["A"] = 9;
        rarityToGrowStat["S"] = 11;
        rarityToGrowStat["SS"] = 15;
        rarityToGrowStat["SSS"] = 20;
    }

    function getZombieOf(address _owner) public view returns (Zombie[] memory) {
        uint ownerZombieCount = 0;
        for (uint i = 0; i < zombieCount; i += 1) {
            if (ownerOf(zombiesKeys[i]) == _owner) {
                ownerZombieCount += 1;
            }
        }

        Zombie[] memory ownerZombies = new Zombie[](ownerZombieCount);
        uint ownerZombieIndex = 0;
        for (uint i = 0; i < zombieCount; i += 1) {
            if (ownerOf(zombiesKeys[i]) == _owner) {
                ownerZombies[ownerZombieIndex] = zombies[zombiesKeys[i]];
                ownerZombieIndex += 1;
            }
        }

        return ownerZombies;
    }

    function randomSex() internal returns (Sex) {
        return Sex(randMod(2));
    }

    function findRandomZombie(uint _zombieId) internal view returns (uint) {
        uint counter = 0;
        uint[] memory result = new uint[](zombieCount);
        address _owner = ownerOf(_zombieId);

        // Get all possible zombies to battle (zombie not of the current owner and not dnas)
        for (uint i = 0; i < zombieCount; i++) {
            if (_owner != ownerOf(zombies[zombiesKeys[i]].id)) {
                result[counter] = zombies[zombiesKeys[i]].id;
                counter++;
            }
        }

        uint rand = 0;
        // Return the random zombie to battle with
        if (counter > 0) {
            rand = uint(keccak256(abi.encodePacked(block.timestamp))) % counter;
            return result[rand];
        }

        return zombies[zombiesKeys[zombieCount - 1]].id;
    }

    function internalLevelUp(uint _zombieId) internal {
        while (
            zombies[_zombieId].level < LVL_MAX &&
            zombies[_zombieId].exp >= EXP_UP_LEVEL[zombies[_zombieId].level - 1]
        ) {
            // Add 1 level
            zombies[_zombieId].level = zombies[_zombieId].level.add(1);

            // Increase random stats with random amount
            uint totalGrowPoint = rarityToGrowStat[zombies[_zombieId].rarity];
            zombies[_zombieId].combatPower = zombies[_zombieId].combatPower.add(
                uint32(totalGrowPoint)
            );

            uint8 loopCount = 0;
            string[6] memory statsArray = [
                "healthPoint",
                "attack",
                "defense",
                "criticalRate",
                "criticalDamage",
                "speed"
            ];

            while (true) {
                loopCount = 0;
                statsArray[0] = "healthPoint";
                statsArray[1] = "attack";
                statsArray[2] = "defense";
                statsArray[3] = "criticalRate";
                statsArray[4] = "criticalDamage";
                statsArray[5] = "speed";

                while (totalGrowPoint > 0) {
                    // Check if after loop through all of the array but still has remaining grow point
                    if (loopCount == statsArray.length) {
                        break;
                    }

                    // Random the stat to increase and the increase amount
                    uint randomStatNumber = randMod(
                        statsArray.length - loopCount
                    );
                    string memory randomStat = statsArray[randomStatNumber];
                    uint randomStatAmount = randMod(totalGrowPoint.add(1));

                    // Increase stat
                    if (
                        keccak256(abi.encodePacked(randomStat)) ==
                        keccak256(abi.encodePacked("healthPoint"))
                    ) {
                        zombies[_zombieId].healthPoint = zombies[_zombieId]
                            .healthPoint
                            .add(uint32(randomStatAmount));
                    } else if (
                        keccak256(abi.encodePacked(randomStat)) ==
                        keccak256(abi.encodePacked("attack"))
                    ) {
                        zombies[_zombieId].attack = zombies[_zombieId]
                            .attack
                            .add(uint32(randomStatAmount));
                    } else if (
                        keccak256(abi.encodePacked(randomStat)) ==
                        keccak256(abi.encodePacked("defense"))
                    ) {
                        zombies[_zombieId].defense = zombies[_zombieId]
                            .defense
                            .add(uint32(randomStatAmount));
                    } else if (
                        keccak256(abi.encodePacked(randomStat)) ==
                        keccak256(abi.encodePacked("criticalRate"))
                    ) {
                        zombies[_zombieId].criticalRate = zombies[_zombieId]
                            .criticalRate
                            .add(uint32(randomStatAmount));
                    } else if (
                        keccak256(abi.encodePacked(randomStat)) ==
                        keccak256(abi.encodePacked("criticalDamage"))
                    ) {
                        zombies[_zombieId].criticalDamage = zombies[_zombieId]
                            .criticalDamage
                            .add(uint32(randomStatAmount));
                    } else if (
                        keccak256(abi.encodePacked(randomStat)) ==
                        keccak256(abi.encodePacked("speed"))
                    ) {
                        zombies[_zombieId].speed = zombies[_zombieId].speed.add(
                            uint32(randomStatAmount)
                        );
                    }

                    totalGrowPoint = totalGrowPoint.sub(randomStatAmount);

                    // Remove the statsArray[randomStatNumber]
                    // Move the last element to the deleted spot.
                    // Remove the last element
                    statsArray[randomStatNumber] = statsArray[
                        statsArray.length - 1
                    ];
                    delete statsArray[statsArray.length - 1];

                    loopCount++;
                }

                if (totalGrowPoint == 0) break;
            }
        }
    }
}
