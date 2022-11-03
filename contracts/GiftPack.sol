// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ZombieAttack.sol";

contract GiftPack is ZombieAttack {
    uint public constant STARTER_ZOMBIE_COUNT = 3;
    mapping(address => bool) public seenWalletOpenStarterPack;

    event OpenStarterPack(address indexed owner, Zombie[] zombies);

    constructor(address _token) ZombieAttack(_token) {}

    function checkOpenStarterPack(address _address) public view returns (bool) {
        return seenWalletOpenStarterPack[_address];
    }

    function openStarterPack() public {
        require(!checkOpenStarterPack(msg.sender));
        seenWalletOpenStarterPack[msg.sender] = true;

        emit OpenStarterPack(msg.sender, createManyZombie(STARTER_ZOMBIE_COUNT));
    }
}
