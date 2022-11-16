// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding {
    using SafeMath16 for uint16;

    constructor(address _token) ZombieFeeding(_token) {}

    event ZombieNameChanged(uint _zombieId, string newName);

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
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

    function changeZombieName(uint _zombieId, string memory _name) external {
        require(ownerOf(_zombieId) == msg.sender, "OW_ZB");
        require(checkAlphanumeric(_name), "STR_ALPHANUMERIC");
        require(checkMaxLengthASCII(_name, 16), "STR_MAX");
        require(checkMinLengthASCII(_name, 1), "STR_MIN");

        zombies[_zombieId].name = _name;

        emit ZombieNameChanged(_zombieId, _name);
    }

    // private method
    function _checkCrit(uint16 _criticalRate) internal returns (uint16) {
        uint16 randomSeed = uint16(randMod(10001));
        if (randomSeed <= _criticalRate.mul(100).div(10)) {
            return 1;
        } else {
            return 0;
        }
    }

    function checkAlphanumeric(string memory str) internal pure returns (bool) {
        bytes memory b = bytes(str);

        if (b.length > 0) {
            if (b[0] == 0x20 || b[b.length - 1] == 0x20) {
                return false;
            }
        }

        for (uint i; i < b.length; i++) {
            bytes1 char = b[i];

            if (
                !(char >= 0x30 && char <= 0x39) && //9-0
                !(char >= 0x41 && char <= 0x5A) && //A-Z
                !(char >= 0x61 && char <= 0x7A) && //a-z
                !(char == 0x20) //<space>
            ) {
                return false;
            }
        }

        return true;
    }

    function checkMinLengthASCII(string memory str, uint8 minLength)
        internal
        pure
        returns (bool)
    {
        bytes memory b = bytes(str);
        if (b.length < minLength) {
            return false;
        }

        return true;
    }

    function checkMaxLengthASCII(string memory str, uint8 maxLength)
        internal
        pure
        returns (bool)
    {
        bytes memory b = bytes(str);
        if (b.length > maxLength) {
            return false;
        }

        return true;
    }
}
