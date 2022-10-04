// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "./Ownable.sol";
import "./SafeMath.sol";

uint8 constant MAX_BREEDING_POINTS = 8;
uint8 constant LVL_CAN_BREED = 10;
uint8 constant LVL_MAX = 20;
uint16 constant ATTACK_COUNT_DEFAULT = 10;
uint constant BASE_EXP = 100;
uint constant AMOUNT_REWARD = 10;

contract ZombieBase is Ownable {
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
        uint16 attackCount;
        string rarity;
        uint exp;
    }
    uint randNonce = 0;
    uint16[] public EXP_UP_LEVEL = [
        100,
        205,
        315,
        536,
        878,
        1237,
        1835,
        2463,
        3122,
        4156,
        5601,
        7118,
        8711,
        10982,
        13366,
        15869,
        19125,
        22544,
        26793,
        32289
    ];

    Zombie[] public zombies;

    mapping(uint => address) public zombieToOwner; 
    mapping(address => uint) ownerZombieCount;
    mapping(string => uint) rarityToGrowStat; // Mapping rarity to grow stat ('A' -> 9, 'S' -> 11)


    enum Sex {
        Male,
        Female
    }

    constructor(address _token) Ownable(_token) {
        rarityToGrowStat['C'] = 6;
        rarityToGrowStat['B'] = 8;
        rarityToGrowStat['A'] = 9;
        rarityToGrowStat['S'] = 11;
        rarityToGrowStat['SS'] = 15;
        rarityToGrowStat['SSS'] = 20;
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

    function randomSex() internal view returns (Sex) {
        uint rand = uint(keccak256(abi.encodePacked(block.timestamp)));
        return Sex(rand % 2);
    }

    function randomAttack() internal returns (uint) {
        // Random from 0 -> 200
        uint rand = randMod(200);
        // Random Attack from 1000 -> 1200
        rand = rand.add(1000);
        return rand;
    }

    function randomZombie(uint _zombieId) internal view returns (uint) {
        uint counter = 0;
        uint[] memory result = new uint[](zombies.length);
        address _owner = zombieToOwner[_zombieId];

        // Get all possible zombies to battle (zombie not of the current owner and can attack)
        for (uint i = 0; i < zombies.length; i++) {
            if (_owner != zombieToOwner[i] && _isCanAttack(i)) {
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

    function _isCanAttack(uint _zombieId) internal view returns (bool) {
        Zombie memory _zombie = zombies[_zombieId];
        return (_zombie.attackCount > 0);
    }

    function internalLevelUp(uint _zombieId) internal {
        while (
            zombies[_zombieId].level < LVL_MAX &&
            zombies[_zombieId].exp >= EXP_UP_LEVEL[zombies[_zombieId].level - 1]
        ) {
            // Add 1 level
            zombies[_zombieId].level = zombies[_zombieId].level.add(1);
            // Increase attack by 1 -> 3
            zombies[_zombieId].attack = zombies[_zombieId].attack.add(1); 
        }
    }

    // Reset attack count of all zombies into full
    function resetAttackCount() external onlyOwner {
        for (uint i = 0; i < zombies.length; i++) {
            zombies[i].attackCount = ATTACK_COUNT_DEFAULT;
        }
    }
}
