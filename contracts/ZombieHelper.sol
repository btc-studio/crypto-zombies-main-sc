// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    constructor(address _token) ZombieFeeding(_token) {}

    event ZombieNameChanged(uint _zombieId, string newName);

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function _isNotOnlyOwner() internal view returns (bool) {
        return _getNumberZombiesOfOwner(msg.sender) != zombieCount;
    }

    function _getNumberZombiesOfOwner(address _owner)
        internal
        view
        returns (uint)
    {
        uint count = 0;

        for (uint index = 0; index < zombieCount; index += 1) {
            if (_owner == ownerOf(zombies[zombiesKeys[index]].id)) {
                count += 1;
            }
        }

        return count;
    }

    function changeZombieName(uint _zombieId, string memory _name) public {
        require(ownerOf(_zombieId) == msg.sender, "Only owner of the Zombie can change it's name");
        require((bytes(_name)).length > 0, "Zombie name cannot be empty");

        zombies[_zombieId].name = _name;

        emit ZombieNameChanged(_zombieId, _name);
    }

    // private method
    function _checkCrit(uint32 _criticalRate) internal returns (uint32) {
        uint32 randomSeed = uint32(randMod(10001));
        if (randomSeed <= _criticalRate.mul(100).div(10)) {
            return 1;
        } else {
            return 0;
        }
    }
}
