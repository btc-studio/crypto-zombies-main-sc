// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    uint levelUpFee = 0.001 ether;

    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }

    constructor(address _token) ZombieFeeding(_token) {}

    // external method: order: view -> pure
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }

    function levelUp(uint _zombieId) external payable {
        require(msg.value == levelUpFee);
        zombies[_zombieId].level++;
    }

    function changeName(uint _zombieId, string memory _newName)
        external
        aboveLevel(2, _zombieId)
        onlyOwnerOf(_zombieId)
    {
        zombies[_zombieId].name = _newName;
    }

    function changeDna(uint _zombieId, uint _newDna)
        external
        aboveLevel(20, _zombieId)
        onlyOwnerOf(_zombieId)
    {
        zombies[_zombieId].dna = _newDna;
    }

    function getZombiesByOwner(address _owner)
        external
        view
        returns (uint[] memory)
    {
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < zombies.length; i++) {
            if (zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    // public method
    function _isNotOnlyOwner() public view returns (bool) {
        return ownerZombieCount[msg.sender] != zombies.length;
    }

    // internal method
    function _getNumberZombiesOfOwner(address _owner)
        internal
        view
        returns (uint)
    {
        return ownerZombieCount[_owner];
    }

    // private method
    function _checkCrit(uint32 _criticalRate) internal returns (uint32) {
        uint32 randomSeed = uint32(randMod(10001));
        if(randomSeed <= _criticalRate.mul(100).div(10)) {
            return 1;
        } else {
            return 0;
        }
    }
}
