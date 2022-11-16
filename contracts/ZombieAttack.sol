// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ZombieHelper.sol";
import "./SafeMath.sol";

contract ZombieAttack is ZombieHelper {
    using SafeMath for uint256;
    using SafeMath16 for uint16;

    struct FightScriptStruct {
        uint attackerId;
        uint isCrit;
        uint damage;
        uint enemyZombieCurrentHP;
    }

    event FindBattle(uint _zombieId);
    event FightScript(
        uint _zombieId,
        uint _targetId,
        FightScriptStruct[] fightScripts
    );
    event RewardUser(
        uint _zombieId,
        uint amount,
        uint winnerExp,
        uint loserExp,
        Dna dnaSample
    );

    constructor(address _token) ZombieHelper(_token) {}

    function findBattle(uint _zombieId) external view returns (uint) {
        // If there is only 1 address has zombie in the SC -> Return error
        require(_getNumberZombiesOfOwner(msg.sender) != zombieCount);

        // Find Zombie
        uint _targetId = findRandomZombie(_zombieId);
        require(_targetId <= tokenCount);
        return _targetId;
    }

    function attack(uint _zombieId, uint _targetId)
        external
        onlyOwnerOf(_zombieId)
    {
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];

        uint winnerZombieId = _targetId;

        uint myZombieCurrentHP = myZombie.healthPoint.mul(100);
        uint enemyZombieCurrentHP = enemyZombie.healthPoint.mul(100);

        uint isMyZombieTurn = 0;
        uint isEnemyZombieTurn = 0;

        // -------------------------------------------------------------------
        // Count number of fighting turns -> To initiate a static array
        if (myZombie.speed >= enemyZombie.speed) {
            enemyZombieCurrentHP = _attackByTurn(
                myZombie,
                enemyZombie,
                enemyZombieCurrentHP
            );
            isEnemyZombieTurn = 1; // Next: Enemy's Zombie turn
        } else {
            myZombieCurrentHP = _attackByTurn(
                enemyZombie,
                myZombie,
                myZombieCurrentHP
            );
            isMyZombieTurn = 1; // Next: My Zombie turn
        }

        uint fightTurn = 1;
        while (myZombieCurrentHP > 0 && enemyZombieCurrentHP > 0) {
            if (isMyZombieTurn == 1) {
                enemyZombieCurrentHP = _attackByTurn(
                    myZombie,
                    enemyZombie,
                    enemyZombieCurrentHP
                );
                isEnemyZombieTurn = 1; // Next: Enemy's Zombie turn
                isMyZombieTurn = 0;
            } else {
                myZombieCurrentHP = _attackByTurn(
                    enemyZombie,
                    myZombie,
                    myZombieCurrentHP
                );
                isMyZombieTurn = 1; // Next: My Zombie turn
                isEnemyZombieTurn = 0;
            }

            fightTurn = fightTurn.add(1);
        }
        // -------------------------------------------------------------------
        // Actual fight

        FightScriptStruct[] memory fightScripts = new FightScriptStruct[](
            fightTurn
        );

        myZombieCurrentHP = myZombie.healthPoint.mul(100);
        enemyZombieCurrentHP = enemyZombie.healthPoint.mul(100);
        FightScriptStruct memory fightScript;

        isMyZombieTurn = 0;
        isEnemyZombieTurn = 0;
        // The zombie has more speed attack first
        // HP = HP_o*100 -(100*ATK / DEF_e + 200) * (100 + 100*(CD * 15% - 1) * (rand(CR))
        if (myZombie.speed >= enemyZombie.speed) {
            (
                enemyZombieCurrentHP,
                fightScript
            ) = _attackByTurnAndUpdateFightScripts(
                myZombie,
                enemyZombie,
                enemyZombieCurrentHP
            );
            fightScripts[0] = fightScript;
            isEnemyZombieTurn = 1; // Next: Enemy's Zombie turn
        } else {
            (
                myZombieCurrentHP,
                fightScript
            ) = _attackByTurnAndUpdateFightScripts(
                enemyZombie,
                myZombie,
                myZombieCurrentHP
            );
            fightScripts[0] = fightScript;
            isMyZombieTurn = 1; // Next: My Zombie turn
        }

        // Fight until 1 zombie die
        fightTurn = 1;
        while (myZombieCurrentHP > 0 && enemyZombieCurrentHP > 0) {
            if (isMyZombieTurn == 1) {
                (
                    enemyZombieCurrentHP,
                    fightScript
                ) = _attackByTurnAndUpdateFightScripts(
                    myZombie,
                    enemyZombie,
                    enemyZombieCurrentHP
                );
                fightScripts[fightTurn] = fightScript;
                isEnemyZombieTurn = 1; // Next: Enemy's Zombie turn
                isMyZombieTurn = 0;
            } else {
                (
                    myZombieCurrentHP,
                    fightScript
                ) = _attackByTurnAndUpdateFightScripts(
                    enemyZombie,
                    myZombie,
                    myZombieCurrentHP
                );
                fightScripts[fightTurn] = fightScript;
                isMyZombieTurn = 1; // Next: My Zombie turn
                isEnemyZombieTurn = 0;
            }

            fightTurn = fightTurn.add(1);
        }

        // Emit FightScript event
        emit FightScript(_zombieId, _targetId, fightScripts);

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

            // Update user's experience
            // _updateUserExp(_userAddress, loserExp);
        } else {
            _updateZombie(myZombie, enemyZombie, winnerExp, loserExp);

            // Update user's experience
            // _updateUserExp(_userAddress, winnerExp);
        }

        // Reward BTCS Token if the Smart Contract has enough BTCS
        // TODO: Need a mechanism to ensure the reward for user when SC is out of BTCS Token
        sendReward(ownerOf(winnerZombieId), AMOUNT_REWARD * 10**uint256(18));

        Dna memory dnaSample;
        // If the user wins -> Have a chance of 0.1% to get a DNA Sample
        if (_zombieId == winnerZombieId) {
            uint rand = randMod(1000);
            // TODO: change 500 to 1
            if (rand < 500) {
                dnaSample = _generateDnaSample(ownerOf(_zombieId));
            }
        }

        // Check if the Zombie has enough exp -> UpLevel + Attack
        internalLevelUp(_zombieId);
        internalLevelUp(_targetId);

        emit RewardUser(
            winnerZombieId,
            AMOUNT_REWARD,
            winnerExp,
            loserExp,
            dnaSample
        );
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

    function _attackByTurn(
        Zombie storage attackZombie,
        Zombie storage defenseZombie,
        uint currentHP
    ) internal returns (uint) {
        if (
            ((100 * attackZombie.attack) / defenseZombie.defense + 200) *
                (1 +
                    ((attackZombie.criticalDamage * 15) / 100 - 1) *
                    _checkCrit(attackZombie.criticalRate)) >=
            currentHP
        ) {
            currentHP = 0;
        } else {
            currentHP =
                currentHP -
                ((100 * attackZombie.attack) / defenseZombie.defense + 200) *
                (1 +
                    ((attackZombie.criticalDamage * 15) / 100 - 1) *
                    _checkCrit(attackZombie.criticalRate));
        }

        return currentHP;
    }

    function _attackByTurnAndUpdateFightScripts(
        Zombie storage attackZombie,
        Zombie storage defenseZombie,
        uint currentHP
    ) internal returns (uint, FightScriptStruct memory) {
        uint isCrit = _checkCrit(attackZombie.criticalRate);
        if (
            ((100 * attackZombie.attack) / defenseZombie.defense + 200) *
                (1 + ((attackZombie.criticalDamage * 15) / 100 - 1) * isCrit) >=
            currentHP
        ) {
            currentHP = 0;
        } else {
            currentHP =
                currentHP -
                ((100 * attackZombie.attack) / defenseZombie.defense + 200) *
                (1 + ((attackZombie.criticalDamage * 15) / 100 - 1) * isCrit);
        }

        // Update fightScripts
        FightScriptStruct memory fightScript = FightScriptStruct(
            attackZombie.id,
            isCrit,
            ((100 * attackZombie.attack) / defenseZombie.defense + 200) *
                (1 + ((attackZombie.criticalDamage * 15) / 100 - 1) * isCrit),
            currentHP
        );

        return (currentHP, fightScript);
    }

    // Update Zombie's information: exp, winCount, lossCount
    function _updateZombie(
        Zombie storage winZombie,
        Zombie storage lossZombie,
        uint winnerExp,
        uint loserExp
    ) internal {
        // If exp reaches max -> don't increase exp anymore
        if (winZombie.exp <= EXP_UP_LEVEL[LVL_MAX - 2]) {
            winZombie.exp = winZombie.exp.add(winnerExp);
        }
        if (lossZombie.exp <= EXP_UP_LEVEL[LVL_MAX - 2]) {
            lossZombie.exp = lossZombie.exp.add(loserExp);
        }
        winZombie.winCount = winZombie.winCount.add(1);
        lossZombie.lossCount = lossZombie.lossCount.add(1);
    }
}
