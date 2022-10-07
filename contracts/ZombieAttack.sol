// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ZombieHelper.sol";
import "./SafeMath.sol";

contract ZombieAttack is ZombieHelper {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    struct FightScriptStruct {
        uint attackerId;
        uint isCrit;
        uint damage;
        uint enemyZombieCurrentHP;
    }

    event FindBattle(uint _zombieId);
    event FightScript(uint _zombieId, uint _targetId, FightScriptStruct[] fightScript);
    event RewardUser(uint _zombieId, uint amount, uint winnerExp, uint loserExp);

    constructor(address _token) ZombieHelper(_token) {}

    function findBattle(uint _zombieId) public view returns (uint) {
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

        uint winnerZombieId = _targetId;

        uint myZombieCurrentHP = myZombie.healthPoint;
        uint enemyZombieCurrentHP = enemyZombie.healthPoint;

        uint isMyZombieTurn = 0;
        uint isEnemyZombieTurn = 0;
        uint isCrit = 0;

        // -------------------------------------------------------------------
        // Count number of fighting turns -> To initiate a static array
        if (myZombie.speed >= enemyZombie.speed) {
            if ((myZombie.attack / enemyZombie.defense + 2) * (1 + (myZombie.criticalDamage * 15 / 100 - 1) * _isCrit(myZombie.criticalRate)) >= enemyZombieCurrentHP) {
                enemyZombieCurrentHP = 0;
            } else {
                enemyZombieCurrentHP = enemyZombieCurrentHP - (myZombie.attack / enemyZombie.defense + 2) * (1 + (myZombie.criticalDamage * 15 / 100 - 1) * _isCrit(myZombie.criticalRate));
            }

            isEnemyZombieTurn = 1; // Next: Enemy's Zombie turn
        } else {
            if ((enemyZombie.attack / myZombie.defense + 2) * (1 + (enemyZombie.criticalDamage * 15 / 100 - 1) * _isCrit(enemyZombie.criticalRate)) >= myZombieCurrentHP) {
                myZombieCurrentHP = 0;
            } else {
                myZombieCurrentHP = myZombieCurrentHP - (enemyZombie.attack / myZombie.defense + 2) * (1 + (enemyZombie.criticalDamage * 15 / 100 - 1) * _isCrit(enemyZombie.criticalRate));
            }

            isMyZombieTurn = 1; // Next: My Zombie turn
        }

        uint fightTurn = 1;
        while (myZombieCurrentHP > 0 && enemyZombieCurrentHP > 0) {
            if (isMyZombieTurn == 1) {
                if ((myZombie.attack / enemyZombie.defense + 2) * (1 + (myZombie.criticalDamage * 15 / 100 - 1) * _isCrit(myZombie.criticalRate)) >= enemyZombieCurrentHP) {
                    enemyZombieCurrentHP = 0;
                } else {
                    enemyZombieCurrentHP = enemyZombieCurrentHP - (myZombie.attack / enemyZombie.defense + 2) * (1 + (myZombie.criticalDamage * 15 / 100 - 1) * _isCrit(myZombie.criticalRate));
                }

                isEnemyZombieTurn = 1; // Next: Enemy's Zombie turn
                isMyZombieTurn = 0;
            } else {
                if ((enemyZombie.attack / myZombie.defense + 2) * (1 + (enemyZombie.criticalDamage * 15 / 100 - 1) * _isCrit(enemyZombie.criticalRate)) >= myZombieCurrentHP) {
                    myZombieCurrentHP = 0;
                } else {
                    myZombieCurrentHP = myZombieCurrentHP - (enemyZombie.attack / myZombie.defense + 2) * (1 + (enemyZombie.criticalDamage * 15 / 100 - 1) * _isCrit(enemyZombie.criticalRate));
                }
                isMyZombieTurn = 1; // Next: My Zombie turn
                isEnemyZombieTurn = 0;
            }

            fightTurn = fightTurn.add(1);
        }
        // -------------------------------------------------------------------
        // Actual fight

        FightScriptStruct[] memory fightScript = new FightScriptStruct[](fightTurn);

        myZombieCurrentHP = myZombie.healthPoint;
        enemyZombieCurrentHP = enemyZombie.healthPoint;

        isMyZombieTurn = 0;
        isEnemyZombieTurn = 0;
        // The zombie has more speed attack first
        // HP = HP_o -(ATK / DEF_e + 2) * (1 + (CD * 15% - 1) * (rand(CR))
        if (myZombie.speed >= enemyZombie.speed) {
            if ((myZombie.attack / enemyZombie.defense + 2) * (1 + (myZombie.criticalDamage * 15 / 100 - 1) * _isCrit(myZombie.criticalRate)) >= enemyZombieCurrentHP) {
                enemyZombieCurrentHP = 0;
            } else {
                enemyZombieCurrentHP = enemyZombieCurrentHP - (myZombie.attack / enemyZombie.defense + 2) * (1 + (myZombie.criticalDamage * 15 / 100 - 1) * _isCrit(myZombie.criticalRate));
            }

            // Update fightScript
            isCrit = _isCrit(myZombie.criticalRate);
            fightScript[0] = FightScriptStruct(
                _zombieId,
                isCrit,
                (myZombie.attack / enemyZombie.defense + 2) * (1 + (myZombie.criticalDamage * 15 / 100 - 1) * isCrit),
                enemyZombieCurrentHP
            );

            isEnemyZombieTurn = 1; // Next: Enemy's Zombie turn
        } else {
            if ((enemyZombie.attack / myZombie.defense + 2) * (1 + (enemyZombie.criticalDamage * 15 / 100 - 1) * _isCrit(enemyZombie.criticalRate)) >= myZombieCurrentHP) {
                myZombieCurrentHP = 0;
            } else {
                myZombieCurrentHP = myZombieCurrentHP - (enemyZombie.attack / myZombie.defense + 2) * (1 + (enemyZombie.criticalDamage * 15 / 100 - 1) * _isCrit(enemyZombie.criticalRate));
            }

            // Update fightScript
            isCrit = _isCrit(myZombie.criticalRate);
            fightScript[0] = FightScriptStruct(
                _targetId,
                isCrit,
                (enemyZombie.attack / myZombie.defense + 2) * (1 + (enemyZombie.criticalDamage * 15 / 100 - 1) * isCrit),
                enemyZombieCurrentHP
            );

            isMyZombieTurn = 1; // Next: My Zombie turn
        }

        // Fight until 1 zombie die
        fightTurn = 1;
        while (myZombieCurrentHP > 0 && enemyZombieCurrentHP > 0) {
            if (isMyZombieTurn == 1) {
                if ((myZombie.attack / enemyZombie.defense + 2) * (1 + (myZombie.criticalDamage * 15 / 100 - 1) * _isCrit(myZombie.criticalRate)) >= enemyZombieCurrentHP) {
                    enemyZombieCurrentHP = 0;
                } else {
                    enemyZombieCurrentHP = enemyZombieCurrentHP - (myZombie.attack / enemyZombie.defense + 2) * (1 + (myZombie.criticalDamage * 15 / 100 - 1) * _isCrit(myZombie.criticalRate));
                }

                // Update fightScript
                isCrit = _isCrit(myZombie.criticalRate);
                fightScript[fightTurn] = FightScriptStruct(
                    _zombieId,
                    isCrit,
                    (myZombie.attack / enemyZombie.defense + 2) * (1 + (myZombie.criticalDamage * 15 / 100 - 1) * isCrit),
                    enemyZombieCurrentHP
                );

                isEnemyZombieTurn = 1; // Next: Enemy's Zombie turn
                isMyZombieTurn = 0;
            } else {
                if ((enemyZombie.attack / myZombie.defense + 2) * (1 + (enemyZombie.criticalDamage * 15 / 100 - 1) * _isCrit(enemyZombie.criticalRate)) >= myZombieCurrentHP) {
                    myZombieCurrentHP = 0;
                } else {
                    myZombieCurrentHP = myZombieCurrentHP - (enemyZombie.attack / myZombie.defense + 2) * (1 + (enemyZombie.criticalDamage * 15 / 100 - 1) * _isCrit(enemyZombie.criticalRate));
                }

                // Update fightScript
                isCrit = _isCrit(myZombie.criticalRate);
                fightScript[fightTurn] = FightScriptStruct(
                    _targetId,
                    isCrit,
                    (enemyZombie.attack / myZombie.defense + 2) * (1 + (enemyZombie.criticalDamage * 15 / 100 - 1) * isCrit),
                    enemyZombieCurrentHP
                );

                isMyZombieTurn = 1; // Next: My Zombie turn
                isEnemyZombieTurn = 0;
            }

            fightTurn = fightTurn.add(1);
        }

        // Emit FightScript event
        emit FightScript(_zombieId, _targetId, fightScript);

        // Check who wins
        if (myZombieCurrentHP == 0) {
            winnerZombieId = _targetId;
        } else {
            winnerZombieId = _zombieId;
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
            _updateZombie(enemyZombie, myZombie, winnerExp, loserExp);
        } else {
            _updateZombie(myZombie, enemyZombie, winnerExp, loserExp);
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
    function _updateZombie(
        Zombie storage winZombie,
        Zombie storage lossZombie,
        uint winnerExp,
        uint loserExp
    ) internal {
        // If exp reaches max -> don't increase exp anymore
        if(winZombie.exp <= EXP_UP_LEVEL[LVL_MAX - 2]) {
            winZombie.exp = winZombie.exp.add(winnerExp);
        }
        if(lossZombie.exp <= EXP_UP_LEVEL[LVL_MAX - 2]) {
            lossZombie.exp = lossZombie.exp.add(loserExp);
        }
        winZombie.winCount = winZombie.winCount.add(1);
        lossZombie.lossCount = lossZombie.lossCount.add(1);
    }
}
