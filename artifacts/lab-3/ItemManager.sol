// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;

// reusable smart contract from OpenZeppelin
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

import "./Item.sol";

contract ItemManager is Ownable {
    // define an enum for the supply chain process
    enum SupplyChainSteps {Created, Paid, Delivered}

    // define struct of item
    struct S_Item {
        Item _item;
        ItemManager.SupplyChainSteps _step;
        string _identifier;
    }

    // define array of items
    mapping(uint => S_Item) public items;
    uint index;

    // define event of a supply chain process
    event SupplyChainStep(uint _itemIndex, uint _step, address _address);

    // function for creating a new item
    function createItem(string memory _identifier, uint _priceInWei) public onlyOwner {
        Item item = new Item(this, _priceInWei, index);
        items[index]._item = item;
        items[index]._step = SupplyChainSteps.Created;
        items[index]._identifier = _identifier;
        
        // emit a supply chain process event
        emit SupplyChainStep(index, uint(items[index]._step), address(item));
        index++;
    }

    // function for payment
    function triggerPayment(uint _index) public payable onlyOwner {
        Item item = items[_index]._item;
        require(address(item) == msg.sender, "Only items are allowed to update themselves");
        require(item.priceInWei() == msg.value, "Not fully paid yet");
        require(items[_index]._step == SupplyChainSteps.Created, "Item is further in the supply chain");
        items[_index]._step = SupplyChainSteps.Paid;

        // emit a supply chain process event
        emit SupplyChainStep(_index, uint(items[_index]._step), address(item));
    }

    // function for delivery
    function triggerDelivery(uint _index) public {
        require(items[_index]._step == SupplyChainSteps.Paid, "Item is further in the supply chain");
        items[_index]._step = SupplyChainSteps.Delivered;
        
        // emit a supply chain process event
        emit SupplyChainStep(_index, uint(items[_index]._step), address(items[_index]._item));
    }
}