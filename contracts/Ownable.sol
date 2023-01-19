// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    address public operator;
    ERC20 public token;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event OperatorSet(address indexed newOperator);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor(address _token) {
        owner = msg.sender;
        token = ERC20(_token);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Throws if called by any account other than the operator or the owner.
     */
    modifier onlyOperator() {
        require(msg.sender == operator || msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Allows the current owner to set an operator of the contract.
     * @param newOperator The address to be the operator of the contract.
     */
    function setOperator(address newOperator) external onlyOwner {
        require(newOperator != address(0));
        emit OperatorSet(newOperator);
        operator = newOperator;
    }

    function sendReward(address _to, uint256 _value) internal {
        token.transfer(_to, _value);
    }
}
