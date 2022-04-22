// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;

// reusable smart contract from OpenZeppelin
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

// allowance contract
contract Allowance is Ownable {
    // onAllowChanged event
    event AllowanceChanged(address indexed _forWho, address indexed _byWhom, uint _oldAmount, uint _newAmount);
    // create map of allowance (address: key, amount: value)
    mapping(address => uint) public allowance;

    // detect owner role from OpenZeppelin
    function isOwner() internal view returns(bool) {
        // owner() is part of Ownable.sol contract
        return owner() == msg.sender;
    }

    // function to add some allowance with amount they want to withdraw
    function addAllowance(address _who, uint _amount) public onlyOwner {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], _amount);
        allowance[_who] = _amount;
    }

    modifier ownerOrAllowed(uint _amount) {
        require(isOwner() || allowance[msg.sender] >= _amount, "You are not allowed!");
        _;
    }

    // reduce allowance
    function reduceAllowance(address _who, uint _amount) internal ownerOrAllowed(_amount) {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who] - _amount);
        allowance[_who] -= _amount;
    }
}