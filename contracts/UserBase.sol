// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract UserBase is Ownable {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;
    using SafeMath8 for uint8;

    uint8 constant USER_START_LEVEL = 1;
    uint8 constant USER_START_EXP = 0;
    uint8 constant USER_MAX_LEVEL_CAP = 20;

    struct User {
        string name;
        uint8 level;
        uint256 exp;
    }

    uint32[] USER_EXP_TO_LEVEL_UP = [
        8,
        280,
        742,
        1444,
        2434,
        3760,
        5451,
        7651,
        10291,
        13411,
        17051,
        21251,
        26051,
        31457,
        37541,
        39296,
        43806,
        50944,
        60709
    ];

    User[] public users;

    mapping(address => User) ownerInfos;

    event UserCreated(address sender, string name, uint8 level);
    event UserLevelUp(address sender, uint8 oldLevel, uint8 newLevel);

    constructor(address _token) Ownable(_token) {}

    /**
     *  @dev create new user
     *  @param _creater creater's address of the user
     *  @param _name name of the user
     *  @return user
     */
    function createUser(address _creater, string memory _name)
        external
        returns (User memory)
    {
        User memory user = User(_name, USER_START_LEVEL, USER_START_EXP);

        users.push(user);
        ownerInfos[_creater] = user;

        emit UserCreated(_creater, _name, USER_START_LEVEL);

        return user;
    }

    /**
     *  @dev update user's exp and level
     *  @param _userAddress address of the user to be updated
     *  @param _exp exp amount to be added up with current exp
     */
    function _updateUserExp(address _userAddress, uint256 _exp) internal {
        User storage _user = ownerInfos[_userAddress];
        bool isUserLevelUp = false;
        uint8 userCurrentLevel = _user.level;
        uint8 userNextLevel = _user.level;
        // Add exp to the current user
        _user.exp = _user.exp.add(_exp);
        // Update user current level if exp is bypassing the next level cap.

        while (
            _user.level < USER_MAX_LEVEL_CAP &&
            _user.exp >= USER_EXP_TO_LEVEL_UP[_user.level - 1]
        ) {
            _user.level = _user.level.add(1);
            isUserLevelUp = true;
            userNextLevel = _user.level;
        }
        if (isUserLevelUp) {
            emit UserLevelUp(_userAddress, userCurrentLevel, userNextLevel);
        }
    }
}
