// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./ZombieBase.sol";

contract ZombieFactory is ZombieBase {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    uint8 public constant BASE_HEALTH_POINT = 10;
    uint8 public constant BASE_ATTACK = 10;
    uint8 public constant BASE_DEFENSE = 10;
    uint8 public constant BASE_CRIT_RATE = 10;
    uint8 public constant BASE_CRIT_DAMAGE = 10;
    uint8 public constant BASE_SPEED = 10;
    uint8 public constant BASE_COMBAT_POWER = 60;
    string public constant BASE_RARITY = "A";
    uint public constant BASE_NAME = 1000000;

    event NewZombie(
        address sender,
        uint zombieId,
        string name,
        uint dna,
        Sex sex,
        uint32 level
    );

    constructor(address _token) ZombieBase(_token) {}

    // external method: order view -> pure

    // public method
    function createRandomZombie(string memory _name)
        public
        returns (Zombie memory)
    {
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - (randDna % 100);
        return _createZombie(_name, randDna);
    }

    function createManyZombie(uint count) public returns (Zombie[] memory) {
        uint i;
        Zombie[] memory zombies = new Zombie[](count);
        for (i = 0; i < count; i += 1) {
            zombies[i] = createRandomZombie("");
        }

        return zombies;
    }

    // internal method
    function _createZombie(string memory _name, uint _dna)
        internal
        returns (Zombie memory)
    {
        Sex sex = randomSex();
        uint id = zombies.length;
        string memory _realName = _name;

        // If zombie's name is null then set name = BASE_NAME + id
        if (bytes(_realName).length == 0) {
            _realName = Strings.toString(BASE_NAME + id);
        }

        Zombie memory zombie = Zombie(
            id,
            _realName,
            _dna,
            1,
            uint32(block.timestamp + cooldownTime),
            0,
            0,
            0,
            sex,
            BASE_HEALTH_POINT,
            BASE_ATTACK,
            BASE_DEFENSE,
            BASE_CRIT_RATE,
            BASE_CRIT_DAMAGE,
            BASE_SPEED,
            BASE_COMBAT_POWER,
            BASE_RARITY,
            0
        );

        zombies.push(zombie);
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
        emit NewZombie(msg.sender, id, _name, _dna, sex, 1);

        return zombie;
    }

    // private method
    function _generateRandomDna(string memory _str) private returns (uint) {
        randNonce = randNonce.add(1);
        uint rand = uint(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, randNonce, _str)
            )
        );
        return rand % dnaModulus;
    }
}
