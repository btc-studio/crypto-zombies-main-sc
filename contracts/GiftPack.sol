// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ZombieAttack.sol";

contract GiftPack is ZombieAttack {
    uint public constant STATER_ZOMBIE_COUNT = 3;

    event OpenStaterPack(address indexed owner, Zombie[] zombies);

    constructor(address _token) ZombieAttack(_token) {}

    function openStaterPack() public {
        require(_getNumberZombiesOfOwner(msg.sender) < STATER_ZOMBIE_COUNT);

        emit OpenStaterPack(msg.sender, createManyZombie(STATER_ZOMBIE_COUNT));
    }
}
