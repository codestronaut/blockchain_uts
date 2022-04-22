// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;

contract SendMoneyExample {
    // create public storage variable
    // this variable will automatically create getter function
    uint public balanceReceived;
    uint public lockedUntil;

    function receiveMoney() public payable {
        // msg is global always-existing object
        // msg object containing information about ongoing transaction
        // .value properties of msg object contains the amount of Wei that was sent to smart contract
        // .sender properties of msg object contains the address that called the smart contract
        balanceReceived += msg.value;

        // add 1 minutes to lockedUntil
        lockedUntil = block.timestamp + 1 minutes;
    }

    function getBalance() public view returns(uint) {
        // address(this) converts smart contract instance to an address
        // .balance properties contains the amount of ether stored on the address (just amount, not exactly access the ether)
        return address(this).balance;
    }

    function withdrawMoney() public {
        // withdraw can be done after 1 minutes passed since receiveMoney() called
        if (lockedUntil < block.timestamp) {
            // get the address that capable to receive ether
            address payable to = payable(msg.sender);
            // transfer all balance to the address
            to.transfer(getBalance());
        }
    }

    // function to send money to a specific smart contract address
    // the result is the target smart contract address will receive full 1 ether
    // because gas fee will be paid by the sender
    function withdrawMoneyTo(address payable _to) public {
        // withdraw can be done after 1 minutes passed since receiveMoney() called
        if (lockedUntil < block.timestamp) {
            _to.transfer(getBalance());
        }
    }
}