// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ZombieAttack.sol";

uint constant STARTER_ZOMBIE_COUNT = 3;

contract GiftPack is ZombieAttack {
    mapping(address => bool) seenWalletOpenStarterPack;

    event OpenStarterPack(address indexed owner, Zombie[] zombies);

    constructor(address _token) ZombieAttack(_token) {}

    function checkOpenStarterPack(address _address) public view returns (bool) {
        return seenWalletOpenStarterPack[_address];
    }

    function openStarterPack(string memory _name) external {
        require(!checkOpenStarterPack(msg.sender));
        seenWalletOpenStarterPack[msg.sender] = true;

        // TODO: openStarterPack -> Create user: Ask users to input name
        // Validate _name
        require(checkAlphanumeric(_name), "STR_ALPHANUMERIC");
        require(checkMaxLengthASCII(_name, 16), "STR_MAX");
        require(checkMinLengthASCII(_name, 1), "STR_MIN");
        _createUser(msg.sender, _name);

        emit OpenStarterPack(msg.sender, _createManyDnas(STARTER_ZOMBIE_COUNT));
    }
}
