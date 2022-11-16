// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./ZombieBase.sol";

uint8 constant BASE_HEALTH_POINT = 10;
uint8 constant BASE_ATTACK = 10;
uint8 constant BASE_DEFENSE = 10;
uint8 constant BASE_CRIT_RATE = 10;
uint8 constant BASE_CRIT_DAMAGE = 10;
uint8 constant BASE_SPEED = 10;
uint8 constant BASE_COMBAT_POWER = 60;
string constant BASE_RARITY = "A";
uint constant BASE_NAME = 1000000;

contract ZombieFactory is ZombieBase {
    using SafeMath for uint256;
    using SafeMath16 for uint16;

    event NewZombie(
        address sender,
        uint zombieId,
        string name,
        uint dna,
        Sex sex,
        uint16 level
    );

    event NewDna(uint dnaId, uint dna, uint rarity, address sender);

    constructor(address _token) ZombieBase(_token) {}

    function _createZombie(
        string memory _name,
        uint _dna,
        string memory _zombieRarity
    ) internal returns (Zombie memory) {
        tokenCount++;
        zombieCount++;
        Sex sex = randomSex();
        uint id = tokenCount;
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
            _zombieRarity,
            0
        );

        zombies[id] = zombie;
        // Update zombies keys array to track zombies's ids
        zombiesKeys.push(id);

        _safeMint(msg.sender, tokenCount);
        emit NewZombie(msg.sender, id, _name, _dna, sex, 1);

        return zombie;
    }

    /**
     * Get random DNA Sample's rarity
     * 1 star: 50%
     * 2 star: 40%
     * 3 star: 10%
     */
    function _randomDnaRarity() internal returns (uint) {
        // Random from 0 -> 99
        uint rand = randMod(100);
        if (rand < 50) {
            return 1;
        } else if (rand < 90) {
            return 2;
        } else {
            return 3;
        }
    }

    /**
     * Get random Zombie's rarity
     * DNA 1 star: C-50%, B-30%, A-15%, S-4%, SS-1%, SSS-0%
     * DNA 2 star: C-20%, B-35%, A-35%, S-7%, SS-2%, SSS-1%
     * DNA 3 star: C-5%, B-10%, A-20%, S-35%, SS-20%, SSS-10%
     */
    function _randomZombieRarity(uint _dnaRarity)
        internal
        returns (string memory)
    {
        // Random from 0 -> 99
        uint rand = randMod(100);

        if (_dnaRarity == 1) {
            if (rand < 50) return "C";
            else if (rand < 80) return "B";
            else if (rand < 95) return "A";
            else if (rand < 99) return "S";
            else return "SS";
        } else if (_dnaRarity == 2) {
            if (rand < 20) return "C";
            else if (rand < 55) return "B";
            else if (rand < 90) return "A";
            else if (rand < 97) return "S";
            else if (rand < 99) return "SS";
            else return "SSS";
        } else {
            if (rand < 5) return "C";
            else if (rand < 15) return "B";
            else if (rand < 35) return "A";
            else if (rand < 70) return "S";
            else if (rand < 90) return "SS";
            else return "SSS";
        }
    }

    // Only used for openStarterPack()
    function _createManyDnas(uint count) internal returns (Zombie[] memory) {
        uint i;
        Dna[] memory dnas = new Dna[](count);
        Zombie[] memory zombies = new Zombie[](count);
        for (i = 0; i < count; i += 1) {
            dnas[i] = _generateDnaSample(msg.sender);
        }

        // Open 3 new generated dnas
        for (i = 0; i < count; i += 1) {
            zombies[i] = openDna(dnas[i].id);
        }

        return zombies;
    }

    // Generate random DNA Sample
    function _generateDnaSample(address _owner) internal returns (Dna memory) {
        tokenCount++;
        dnaCount++;
        uint id = tokenCount;
        uint rarity = _randomDnaRarity();

        randNonce = randNonce.add(1);
        uint rand = uint(
            keccak256(abi.encodePacked(block.timestamp, _owner, randNonce))
        );

        // Insert new DNA Sample to dnas mapping
        Dna memory dna = Dna(id, rand % dnaModulus, rarity, false);

        dnas[id] = dna;
        // Update dnas keys array to track zombies's ids
        dnasKeys.push(id);

        _safeMint(_owner, tokenCount);

        // Emit New DnaCreated event
        emit NewDna(tokenCount, rand % dnaModulus, rarity, _owner);

        return dna;
    }

    // Open Dna to create zombie
    function openDna(uint _dnaId) public returns (Zombie memory) {
        require(
            msg.sender == ownerOf(_dnaId),
            "OW_DNA"
        );

        Dna storage dna = dnas[_dnaId];
        require(dna.isOpened == false, "DNA_OPENED");

        string memory zombieRarity = _randomZombieRarity(dna.rarity);
        Zombie memory zombie = _createZombie("", dna.dna, zombieRarity);

        dnas[_dnaId].isOpened = true;
        delete dnas[_dnaId];

        return zombie;
    }
}
