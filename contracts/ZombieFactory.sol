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

    event NewDna(uint dnaId, uint dna, uint rarity, address sender);

    constructor(address _token) ZombieBase(_token) {}

    // external method: order view -> pure

    // public method
    // Create zombie directly
    function createRandomZombie(string memory _name)
        public
        returns (Zombie memory)
    {
        uint randDna = _generateRandomDna(_name);
        uint dnaRarity = _randomDnaRarity();
        string memory zombieRarity = _randomZombieRarity(dnaRarity);

        randDna = randDna - (randDna % 100);
        return _createZombie(_name, randDna, zombieRarity);
    }

    function createManyZombie(uint count) internal returns (Zombie[] memory) {
        uint i;
        Zombie[] memory zombies = new Zombie[](count);
        for (i = 0; i < count; i += 1) {
            zombies[i] = createRandomZombie("");
        }

        return zombies;
    }

    // internal method
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
            _zombieRarity,
            0
        );

        zombies[id] = zombie;
        zombiesKeys.push(id); // Update zombies keys array to track zombies's ids

        _safeMint(msg.sender, tokenCount);
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

    function createManyDnas(uint count) public returns (Dna[] memory) {
        uint i;
        Dna[] memory dnas = new Dna[](count);
        for (i = 0; i < count; i += 1) {
            dnas[i] = generateDnaSample(msg.sender);
        }

        // Open 3 new generated dnas
        for (i = 0; i < count; i += 1) {
            openDna(dnas[i].id);
        }

        return dnas;
    }

    // Generate random DNA Sample
    function generateDnaSample(address _owner) public returns (Dna memory) {
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
        dnasKeys.push(id); // Update dnas keys array to track zombies's ids

        _safeMint(_owner, tokenCount);

        // Emit New DnaCreated event
        emit NewDna(tokenCount, rand % dnaModulus, rarity, _owner);

        return dna;
    }

    // Open Dna to create zombie
    function openDna(uint _dnaId) public returns (Zombie memory) {
        require(
            msg.sender == ownerOf(_dnaId),
            "Only owner of the DNA can open it"
        );

        Dna storage dna = dnas[_dnaId];
        require(dna.isOpened == false, "This DNA Sample has been opened");

        string memory zombieRarity = _randomZombieRarity(dna.rarity);
        Zombie memory zombie = _createZombie("", dna.dna, zombieRarity);

        dnas[_dnaId].isOpened = true;
        delete dnas[_dnaId];

        return zombie;
    }
}
