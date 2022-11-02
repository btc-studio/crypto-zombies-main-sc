// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ZombieAttack.sol";

contract GiftPack is ZombieAttack {
    uint public constant STATER_ZOMBIE_COUNT = 3;
    mapping(address => bool) public seenWalletOpenStaterPack;

    event OpenStarterPack(address indexed owner, Zombie[] zombies);

    constructor(address _token) ZombieAttack(_token) {}

    function checkOpenStarterPack(address _address) public view returns (bool) {
        return seenWalletOpenStaterPack[_address];
    }

    function openStaterPack() public {
        require(!checkOpenStarterPack(msg.sender));
        seenWalletOpenStaterPack[msg.sender] = true;

        emit OpenStarterPack(msg.sender, createManyZombie(STATER_ZOMBIE_COUNT));
    }
}
