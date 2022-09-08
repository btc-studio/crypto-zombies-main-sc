// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ZombieHelper.sol";
import "./SafeMath.sol";

contract ZombieAttack is ZombieHelper {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    event Battle(uint _zombieId, uint amout, uint exp);

    function findBattle(uint _zombieId)
        external
        onlyOwnerOf(_zombieId)
        returns (Zombie memory)
    {
        // Kiểm tra Zombie còn lượt tấn công hay không?
        require(_isCanAttack(_zombieId));

        // Kiểm tra nếu chỉ có 1 ví sở hữu Zombie thì sẽ trả về lỗi
        require(_isNotOnlyOwner());

        // Tìm kiếm Zombie
        int _targetId = randomZombie(_zombieId);
        require(_targetId >= 0);
        return zombies[uint(_targetId)];
    }

    function attack(uint _zombieId, uint _targetId)
        external
        onlyOwnerOf(_zombieId)
    {
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];
        // Kiểm tra Zombie còn lượt tấn công hay không?
        require(_isCanAttack(_zombieId));
        require(_isCanAttack(_targetId));

        // Kiểm tra xem Zombie nào chiến thắng
        uint16 my_zombie_battle_times = ATTACK_COUNT_DEFAULT -
            myZombie.attack_count;
        uint16 enemy_zombie_battle_times = ATTACK_COUNT_DEFAULT -
            enemyZombie.attack_count;
        myZombie.attack = myZombie.attack.sub(
            myZombie.attack.mul(5).div(100).mul(my_zombie_battle_times)
        );
        enemyZombie.attack = enemyZombie.attack.sub(
            enemyZombie.attack.mul(5).div(100).mul(enemy_zombie_battle_times)
        );
        uint winnerZombieId = _targetId;
        if (myZombie.attack > enemyZombie.attack) {
            winnerZombieId = _zombieId;
        } else if (myZombie.attack == enemyZombie.attack) {
            if (my_zombie_battle_times >= enemy_zombie_battle_times) {
                winnerZombieId = _zombieId;
            }
        }

        // Tính toán số exp nhận được
        uint winner_level = 1;
        if (winnerZombieId == _targetId) {
            winner_level = enemyZombie.level;
        } else {
            winner_level = myZombie.level;
        }
        uint exp = calculate_exp(winner_level);

        // Tăng điểm kinh nghiệm cho Zombie
        // Exp Zombie thua sẽ = 30% Zombie thắng
        if (winnerZombieId == _targetId) {
            enemyZombie.exp = enemyZombie.exp.add(exp);
            myZombie.exp = myZombie.exp.add(exp.mul(30).div(100));
            enemyZombie.winCount = enemyZombie.winCount.add(1);
            myZombie.lossCount = myZombie.lossCount.add(1);
            // TODO thưởng BTCS Token
        } else {
            myZombie.exp = myZombie.exp.add(exp);
            enemyZombie.exp = enemyZombie.exp.add(exp.mul(30).div(100));
            myZombie.winCount = myZombie.winCount.add(1);
            enemyZombie.lossCount = enemyZombie.lossCount.add(1);
            // TODO thưởng BTCS Token
        }

        // Giảm lượt tấn công
        myZombie.attack_count = myZombie.attack_count.sub(1);
        enemyZombie.attack_count = enemyZombie.attack_count.sub(1);

        // Kiểm tra nếu Zombie đủ exp sẽ UpLevel + Attack
        internalLevelUp(_zombieId);
        internalLevelUp(_targetId);

        emit Battle(winnerZombieId, AMOUNT_REWARD, exp);
    }

    function calculate_exp(uint level) private pure returns (uint) {
        uint exp_cal = BASE_EXP;
        for (uint i = 2; i <= level; i++) {
            exp_cal = exp_cal.mul(105).div(100);
        }
        return exp_cal;
    }

    // Lỗi update 
    function updateZombie(
        Zombie storage winZombie,
        Zombie storage lossZombie,
        uint exp
    ) internal {
        winZombie.exp = winZombie.exp.add(exp);
        lossZombie.exp = lossZombie.exp.add(exp.mul(30).div(100));
        winZombie.winCount = winZombie.winCount.add(1);
        lossZombie.lossCount = lossZombie.lossCount.add(1);
        winZombie.attack_count = winZombie.attack_count.sub(1);
        lossZombie.attack_count = lossZombie.attack_count.sub(1);
    }
}
