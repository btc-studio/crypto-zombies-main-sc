pragma solidity ^0.8.16;

import "./ZombieAttack.sol";

contract GiftPack is ZombieAttack {
    uint public constant STATER_ZOMBIE_COUNT = 3;

    constructor(address _token) ZombieAttack(_token) {}

    function openStaterPack() public returns (Zombie[] memory) {
        // require number zombies < STATER_ZOMBIE_COUNT
        require(_getNumberZombies() < STATER_ZOMBIE_COUNT);

        // create zombies
        return createManyZombie(STATER_ZOMBIE_COUNT);
    }
}
