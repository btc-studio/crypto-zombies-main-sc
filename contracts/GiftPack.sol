// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ZombieAttack.sol";

contract GiftPack is ZombieAttack {
    uint public constant STATER_ZOMBIE_COUNT = 3;
    mapping(address => bool) seenWalletOpenStaterPack;

    event OpenStaterPack(address indexed owner, Zombie[] zombies);

    constructor(address _token) ZombieAttack(_token) {}

    function checkOpenStarterPack() public view returns (bool) {
        return seenWalletOpenStaterPack[msg.sender];
    }

    function openStaterPack() public {
        require(!checkOpenStarterPack());
        seenWalletOpenStaterPack[msg.sender] = true;

        emit OpenStaterPack(msg.sender, createManyZombie(STATER_ZOMBIE_COUNT));
    }
}
