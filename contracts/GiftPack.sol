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

    function openStarterPack(address senderAddress) external onlyOperator {
        require(!checkOpenStarterPack(senderAddress));
        seenWalletOpenStarterPack[senderAddress] = true;

        _createUser(senderAddress);

        emit OpenStarterPack(
            senderAddress,
            _createManyDnas(STARTER_ZOMBIE_COUNT, senderAddress)
        );
    }
}
