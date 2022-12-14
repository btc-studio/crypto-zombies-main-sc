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
    ERC20 public token;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

     // Modifier to check _token allowance
    modifier checkAllowance(uint amount) {
        require(token.allowance(msg.sender, address(this)) >= amount, "Error");
        _;
    }

    function getName() external view returns (string memory){
        return token.name();
    }

    function getTotalSupply() external view returns (uint256){
        return token.totalSupply();
    }
    
    function getBalanceOf(address _owner) external view returns (uint256){
        return token.balanceOf(_owner);
    }

    function getBalance() external view returns (uint256){
        return token.balanceOf(address(this));
    }

    function sendReward(address _to, uint256 _value) internal {
        token.transfer(_to, _value);
    }
}
