// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    constructor(address _token) ZombieFeeding(_token) {}

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function getZombiesByOwner(address _owner)
        external
        view
        returns (uint[] memory)
    {
        uint[] memory result = new uint[](_getNumberZombiesOfOwner(_owner));
        uint counter = 0;
        for (uint i = 0; i < zombieCount; i += 1) {
            if (ownerOf(zombies[i].id) == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
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
