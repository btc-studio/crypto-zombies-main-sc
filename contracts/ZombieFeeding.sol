// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ZombieFactory.sol";

contract ZombieFeeding is ZombieFactory {
    using SafeMath for uint256;
    using SafeMath16 for uint16;

    modifier onlyOwnerOf(uint _zombieId) {
        require(msg.sender == ownerOf(_zombieId));
        _;
    }

    constructor(address _token) ZombieFactory(_token) {}


    function _generateDna(
        uint dna1,
        uint dna2,
        string memory _name
    ) private returns (uint) {
        randNonce = randNonce.add(1);
        uint rand = uint(
            keccak256(abi.encodePacked(block.timestamp, dna1, dna2, _name))
        );
        return rand % dnaModulus;
    }

    function breedZombie(
        uint _fatherId,
        uint _motherId,
        string memory _name
    ) external onlyOwnerOf(_fatherId) onlyOwnerOf(_motherId) {
        Zombie storage father = zombies[_fatherId];
        Zombie storage mother = zombies[_motherId];

        uint dnaRarity = _randomDnaRarity();

        string memory zombieRarity = _randomZombieRarity(dnaRarity);

        // Check conditions
        require(
            father.level >= LVL_CAN_BREED &&
                father.breedCount < MAX_BREEDING_POINTS
        );
        require(
            mother.level >= LVL_CAN_BREED &&
                mother.breedCount < MAX_BREEDING_POINTS
        );
        require(bytes(_name).length > 0);
        require(father.sex != mother.sex);

        // Increase breed Count
        father.breedCount = father.breedCount.add(1);
        mother.breedCount = mother.breedCount.add(1);
        // Tinh toán DNA Zombie con từ DNA của bố mẹ
        uint newKittyDna = _generateDna(father.dna, mother.dna, _name);
        _createZombie(_name, newKittyDna, zombieRarity);
    }
}
