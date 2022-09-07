// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

// Import this file to use console.log
import "hardhat/console.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

uint8 constant MAX_BREEDING_POINTS = 8;
uint8 constant LVL_CAN_BREED = 10;

contract ZombieFactory is Ownable {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    event NewZombie(address sender, uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10**dnaDigits;
    uint cooldownTime = 1 days;
    uint randNonce = 0;

    enum Sex {
        Male,
        Female
    }

    struct Zombie {
        uint id;
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
        uint16 breeds_points;
        Sex sex;
    }

    Zombie[] public zombies;

    mapping(uint => address) public zombieToOwner;
    mapping(address => uint) ownerZombieCount;

    function _createZombie(string memory _name, uint _dna) internal {
        Sex sex = randomSex();
        uint id = zombies.length;
        zombies.push(
            Zombie(
                id,
                _name,
                _dna,
                1,
                uint32(block.timestamp + cooldownTime),
                0,
                0,
                0,
                sex
            )
        );
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
        emit NewZombie(msg.sender, id, _name, _dna);
    }

    function _generateRandomDna(string memory _str) private returns (uint) {
        randNonce = randNonce.add(1);
        uint rand = uint(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, randNonce, _str)
            )
        );
        return rand % dnaModulus;
    }

    function randomSex() private view returns (Sex) {
        uint rand = uint(keccak256(abi.encodePacked(block.timestamp)));
        return Sex(rand % 2);
    }

    function createRandomZombie(string memory _name) public {
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - (randDna % 100);
        _createZombie(_name, randDna);
    }
}
