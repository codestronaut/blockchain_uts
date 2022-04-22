// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;

import "./Allowance.sol";


// shared wallet contract
contract SharedWallet is Allowance {

    event MoneySent(address indexed _beneficiary, uint _amount);
    event MoneyReceived(address indexed _from, uint _amount);

    // functio to withdraw Ether to a specific address with specific amount
    // add onlyOwner modifier to restrict withdraw function just for the owner
    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount) {
        require(_amount <= address(this).balance, "Contract doesn't own enough money!");

        // this condition is for avoid double spending
        // only allowance who is the owner can withdraw
        if (!isOwner()) {
            reduceAllowance(msg.sender, _amount);
        }
        emit MoneySent(_to, _amount);
        _to.transfer(_amount);
    }

    // function to stop remove an owner
    // function renounceOwnership() public override onlyOwner {
    //     revert("Can't renounceOwnership here");
    // }

    receive() external payable {
        emit MoneyReceived(msg.sender, msg.value);
    }
}