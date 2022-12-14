// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./UserBase.sol";
import "./SafeMath.sol";

uint8 constant MAX_BREEDING_POINTS = 8;
uint8 constant LVL_CAN_BREED = 10;
uint8 constant LVL_MAX = 20;
uint constant BASE_EXP = 100;
uint constant AMOUNT_REWARD = 10;

contract ZombieBase is UserBase, ERC721 {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    uint dnaDigits = 16;
    uint dnaModulus = 10**dnaDigits;
    uint cooldownTime = 1 days;

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
    uint randNonce = 0;
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

    Zombie[] public zombies;

    mapping(string => uint) rarityToGrowStat; // Mapping rarity to grow stat ('A' -> 9, 'S' -> 11)

    enum Sex {
        Male,
        Female
    }

    constructor(address _token) UserBase(_token) ERC721("BTCZombieNFT", "CZB") {
        rarityToGrowStat["C"] = 6;
        rarityToGrowStat["B"] = 8;
        rarityToGrowStat["A"] = 9;
        rarityToGrowStat["S"] = 11;
        rarityToGrowStat["SS"] = 15;
        rarityToGrowStat["SSS"] = 20;
    }

    function randMod(uint _modulus) internal returns (uint) {
        randNonce = randNonce.add(1);
        return
            uint(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, randNonce)
                )
            ) % _modulus;
    }

    function randomSex() internal returns (Sex) {
        return Sex(randMod(2));
    }

    function randomAttack() internal returns (uint) {
        // Random from 0 -> 199
        uint rand = randMod(200);
        // Random Attack from 1000 -> 1199
        rand = rand.add(1000);
        return rand;
    }

    function randomZombie(uint _zombieId) internal view returns (uint) {
        uint counter = 0;
        uint[] memory result = new uint[](zombies.length);
        address _owner = ownerOf(_zombieId);

        // Get all possible zombies to battle (zombie not of the current owner and can attack)
        for (uint i = 0; i < zombies.length; i++) {
            if (_owner != ownerOf(zombies[i].id)) {
                result[counter] = i;
                counter++;
            }
        }

        uint rand = 0;
        // Return the random zombie to battle with
        if (counter > 0) {
            rand = uint(keccak256(abi.encodePacked(block.timestamp))) % counter;
            return result[rand];
        }

        return zombies.length;
    }

    function internalLevelUp(uint _zombieId) internal {
        while (
            zombies[_zombieId - 1].level < LVL_MAX &&
            zombies[_zombieId - 1].exp >=
            EXP_UP_LEVEL[zombies[_zombieId - 1].level - 1]
        ) {
            // Add 1 level
            zombies[_zombieId - 1].level = zombies[_zombieId - 1].level.add(1);

            // Increase random stats with random amount
            uint totalGrowPoint = rarityToGrowStat[
                zombies[_zombieId - 1].rarity
            ];
            zombies[_zombieId - 1].combatPower = zombies[_zombieId - 1]
                .combatPower
                .add(uint32(totalGrowPoint));

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
                        zombies[_zombieId - 1].healthPoint = zombies[
                            _zombieId - 1
                        ].healthPoint.add(uint32(randomStatAmount));
                    } else if (
                        keccak256(abi.encodePacked(randomStat)) ==
                        keccak256(abi.encodePacked("attack"))
                    ) {
                        zombies[_zombieId - 1].attack = zombies[_zombieId - 1]
                            .attack
                            .add(uint32(randomStatAmount));
                    } else if (
                        keccak256(abi.encodePacked(randomStat)) ==
                        keccak256(abi.encodePacked("defense"))
                    ) {
                        zombies[_zombieId - 1].defense = zombies[_zombieId - 1]
                            .defense
                            .add(uint32(randomStatAmount));
                    } else if (
                        keccak256(abi.encodePacked(randomStat)) ==
                        keccak256(abi.encodePacked("criticalRate"))
                    ) {
                        zombies[_zombieId - 1].criticalRate = zombies[
                            _zombieId - 1
                        ].criticalRate.add(uint32(randomStatAmount));
                    } else if (
                        keccak256(abi.encodePacked(randomStat)) ==
                        keccak256(abi.encodePacked("criticalDamage"))
                    ) {
                        zombies[_zombieId - 1].criticalDamage = zombies[
                            _zombieId - 1
                        ].criticalDamage.add(uint32(randomStatAmount));
                    } else if (
                        keccak256(abi.encodePacked(randomStat)) ==
                        keccak256(abi.encodePacked("speed"))
                    ) {
                        zombies[_zombieId - 1].speed = zombies[_zombieId - 1]
                            .speed
                            .add(uint32(randomStatAmount));
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
