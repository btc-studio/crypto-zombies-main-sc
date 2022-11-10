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

    function changeZombieName(uint _zombieId, string memory _name)
        public
        requireAlphanumeric(_name)
        requireMaxLengthASCII(_name, 16)
        requireMinLengthASCII(_name, 1)
    {
        require(
            ownerOf(_zombieId) == msg.sender,
            "Only owner of the Zombie can change it's name"
        );

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

    function checkAlphanumeric(string memory str) private pure returns (bool) {
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
        private
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
        private
        pure
        returns (bool)
    {
        bytes memory b = bytes(str);
        if (b.length > maxLength) {
            return false;
        }

        return true;
    }

    modifier requireAlphanumeric(string memory str) {
        require(checkAlphanumeric(str), "String must be alphanumeric");
        _;
    }

    modifier requireMaxLengthASCII(string memory str, uint8 maxLength) {
        require(
            checkMaxLengthASCII(str, maxLength),
            "String must be has length less than or equal maxLength"
        );
        _;
    }

    modifier requireMinLengthASCII(string memory str, uint8 minLength) {
        require(
            checkMinLengthASCII(str, minLength),
            "String must be has length greater than or equal minLength"
        );
        _;
    }
}
