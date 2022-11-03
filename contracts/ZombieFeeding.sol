// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ZombieFactory.sol";

abstract contract KittyInterface {
    function getKitty(uint256 _id)
        external
        view
        virtual
        returns (
            bool isGestating,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 siringWithId,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 generation,
            uint256 genes
        );
}

contract ZombieFeeding is ZombieFactory {
    KittyInterface kittyContract;

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    modifier onlyOwnerOf(uint _zombieId) {
        require(msg.sender == ownerOf(_zombieId));
        _;
    }

    constructor(address _token) ZombieFactory(_token) {}

    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(block.timestamp + cooldownTime);
    }

    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.readyTime <= block.timestamp);
    }

    function _isCanBreed(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.level >= LVL_CAN_BREED &&
            _zombie.breedCount < MAX_BREEDING_POINTS);
    }

    function _stringNotEmptyOrNull(string memory input)
        internal
        pure
        returns (bool)
    {
        return bytes(input).length > 0;
    }

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
    ) public onlyOwnerOf(_fatherId) onlyOwnerOf(_motherId) {
        Zombie storage father = zombies[_fatherId];
        Zombie storage mother = zombies[_motherId];

        uint dnaRarity = _randomDnaRarity();

        string memory zombieRarity = _randomZombieRarity(dnaRarity);

        // Check conditions
        require(_isCanBreed(father));
        require(_isCanBreed(mother));
        require(_stringNotEmptyOrNull(_name));
        require(father.sex != mother.sex);

        // Increase breed Count
        father.breedCount = father.breedCount.add(1);
        mother.breedCount = mother.breedCount.add(1);
        // Tinh toán DNA Zombie con từ DNA của bố mẹ
        uint newKittyDna = _generateDna(father.dna, mother.dna, _name);
        _createZombie(_name, newKittyDna, zombieRarity);
    }
}
