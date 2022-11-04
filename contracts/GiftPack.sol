// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ZombieAttack.sol";

uint constant STARTER_ZOMBIE_COUNT = 3;

contract GiftPack is ZombieAttack {
    mapping(address => bool) public seenWalletOpenStarterPack;

    event OpenStarterPack(address indexed owner, Zombie[] zombies);

    constructor(address _token) ZombieAttack(_token) {}

    function checkOpenStarterPack(address _address) public view returns (bool) {
        return seenWalletOpenStarterPack[_address];
    }

    function openStarterPack() public {
        require(!checkOpenStarterPack(msg.sender));
        seenWalletOpenStarterPack[msg.sender] = true;

        emit OpenStarterPack(msg.sender, _createManyDnas(STARTER_ZOMBIE_COUNT));
    }
}
