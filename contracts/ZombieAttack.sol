// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "hardhat/console.sol";
import "./ZombieHelper.sol";
import "./SafeMath.sol";

contract ZombieAttack is ZombieHelper {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    event FindBattle(uint _zombieId);
    event RewardUser(uint _zombieId, uint amount, uint winnerExp, uint loserExp);

    constructor(address _token) ZombieHelper(_token) {}

    function findBattle(uint _zombieId) public view returns (uint) {
        // Check if the Zombie has enough attack count or not
        require(_isCanAttack(_zombieId));

        // If there is only 1 address has zombie in the SC -> Return error
        require(_isNotOnlyOwner());

        // Find Zombie
        uint _targetId = randomZombie(_zombieId);
        require(_targetId < zombies.length);
        return _targetId;
    }

    function attack(uint _zombieId, uint _targetId)
        external
        onlyOwnerOf(_zombieId)
    {
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];
        // Check if the Zombie has enough attack count or not
        require(_isCanAttack(_zombieId));
        require(_isCanAttack(_targetId));

        // Check what zombie wins
        uint16 myZombieBattleTimes = ATTACK_COUNT_DEFAULT -
            myZombie.attackCount;
        uint16 enemyZombieBattleTimes = ATTACK_COUNT_DEFAULT -
            enemyZombie.attackCount;
        uint32 myZombieAtkCur = myZombie.attack;
        uint32 enemyZombieAtkCur = enemyZombie.attack;
        uint winnerZombieId = _targetId;
        if (myZombieAtkCur > enemyZombieAtkCur) {
            winnerZombieId = _zombieId;
        } else if (myZombieAtkCur == enemyZombieAtkCur) {
            if (myZombieBattleTimes >= enemyZombieBattleTimes) {
                winnerZombieId = _zombieId;
            }
        }

        // Calculate the amount of exp received
        uint winnerLevel = 1;
        uint loserLevel = 1;
        if (winnerZombieId == _targetId) {
            winnerLevel = enemyZombie.level;
            loserLevel = myZombie.level;
        } else {
            winnerLevel = myZombie.level;
            loserLevel = enemyZombie.level;
        }

        uint winnerExp = calculateWinnerExp(winnerLevel);
        uint loserExp = calculateLoserExp(loserLevel);

        // Incease zombie's exp
        if (winnerZombieId == _targetId) {
            updateZombie(enemyZombie, myZombie, winnerExp, loserExp);
        } else {
            updateZombie(myZombie, enemyZombie, winnerExp, loserExp);
        }

        // Reward BTCS Token if the Smart Contract has enough BTCS
        // TODO: Need a mechanism to ensure the reward for user when SC is out of BTCS Token
        sendReward(
            zombieToOwner[winnerZombieId],
            AMOUNT_REWARD * 10**uint256(18)
        );

        // Check if the Zombie has enough exp -> UpLevel + Attack
        internalLevelUp(_zombieId);
        internalLevelUp(_targetId);

        emit RewardUser(winnerZombieId, AMOUNT_REWARD, winnerExp, loserExp);
    }

    // Winner: EXP = 50 + 5*(level-1)
    function calculateWinnerExp(uint level) private pure returns (uint) {
        uint exp = level.sub(1).mul(5).add(50);
        return exp;
    }

    // Loser: EXP = 12 + 5*(level-1)
    function calculateLoserExp(uint level) private pure returns (uint) {
        uint exp = level.sub(1).mul(5).add(12);
        return exp;
    }

    // Update Zombie's information: exp, winCount, lossCount
    function updateZombie(
        Zombie storage winZombie,
        Zombie storage lossZombie,
        uint winnerExp,
        uint loserExp
    ) internal {
        winZombie.exp = winZombie.exp.add(winnerExp);
        lossZombie.exp = lossZombie.exp.add(loserExp);
        winZombie.winCount = winZombie.winCount.add(1);
        lossZombie.lossCount = lossZombie.lossCount.add(1);
        winZombie.attackCount = winZombie.attackCount.sub(1);
        lossZombie.attackCount = lossZombie.attackCount.sub(1);
    }
}