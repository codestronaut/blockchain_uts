# UTS Blockchain

## Lab 1: Deposit & Withdraw Ether

Source code lab 1 terletak pada direktori `artifacts/lab-1` di repository ini

### Deposit Ether

Untuk melakukan depositor Ether (1 Ether = 10^8 Wei) membutuhkan sebuah storage variable bertipe uint.

```solidity
// create public storage variable
// this variable will automatically create getter function
uint public balanceReceived;
```

Blok kode untuk menerima ether (deposit):

Pada fungsi ini, balanceReceived ditambahkan dengan msg.value. 
Object msg ini mengandung informasi tentang transaksi yang sedang berlangsung.
Kemudian object msg memiliki properti .value yang bisa digunakan untuk mendapatkan informasi
tentang banyak Wei yang sudah dikirimkan ke Smart Contract

```solidity
function receiveMoney() public payable {
    // msg is global always-existing object
    // msg object containing information about ongoing transaction
    // .value properties of msg object contains the amount of Wei that was sent to smart contract
    // .sender properties of msg object contains the address that called the smart contract
    balanceReceived += msg.value;
}
```

Fungsi ini untuk mendapatkan informasi saldo yang tersedia.



```solidity
function getBalance() public view returns(uint) {
    // address(this) converts smart contract instance to an address
    // .balance properties contains the amount of ether stored on the address (just amount, not exactly access the ether)
    return address(this).balance;
}
```

Figure 1: Melakukan deposit 1 Ether (10^8 Wei)

![Screenshot](https://raw.githubusercontent.com/codestronaut/blockchain_uts/main/screenshots/figure_1.png)

### Withdraw Ether

Untuk bisa melakukan penarikan Ether dari Smart Contract, dibutuhkan informasi address tujuan.
Berikut fungsi untuk withdraw:

```solidity
function withdrawMoney() public {
    // get the address that capable to receive ether
    address payable to = payable(msg.sender);
    // transfer all balance to the address
    to.transfer(getBalance());
}
```

Dan berikut fungsi yang dikembangkan dari fungsi withdraw sebelumnya.
Pada fungsi ini memungkinkan untuk withdraw Ether ke address tertentu.

```solidity
// function to send money to a specific smart contract address
// the result is the target smart contract address will receive full 1 ether
// because gas fee will be paid by the sender

function withdrawMoneyTo(address payable _to) public {
    _to.transfer(getBalance());
}
```

### Menambah Time Block

Kita dapat memblokir transaksi selama waktu tertentu dengan menambahkan block.timestamp.
Dengan begitu kita akan dapat melakukan withdraw 1 menit setelah melakukan deposit.

```solidity
uint public lockedUntil;
```

```solidity
function receiveMoney() public payable {
    ...

    // add 1 minutes to lockedUntil
    lockedUntil = block.timestamp + 1 minutes;
}
```

```solidity
function withdrawMoney() public {
    // withdraw can be done after 1 minutes passed since receiveMoney() called
    if (lockedUntil < block.timestamp) {
        // get the address that capable to receive ether
        address payable to = payable(msg.sender);
        // transfer all balance to the address
        to.transfer(getBalance());
    }
}
```

```solidity
function withdrawMoneyTo(address payable _to) public {
    // withdraw can be done after 1 minutes passed since receiveMoney() called
    if (lockedUntil < block.timestamp) {
        _to.transfer(getBalance());
    }
}
```

Figure 2a: Memilih sebuah address untuk melakukan widthdraw

![Screenshot](https://raw.githubusercontent.com/codestronaut/blockchain_uts/main/screenshots/figure_2a.png)

Figure 2b: Melakukan withdraw ke address terpilih (transaksi akan terblock selama 1 menit dari waktu deposit) karena ditambahkan `block.timestamp`. Setelah 1 menit, target address menerima 1 Ether

![Screenshot](https://raw.githubusercontent.com/codestronaut/blockchain_uts/main/screenshots/figure_2b.png)

## Lab 2: Shared Wallet

Source code lab 1 terletak pada direktori `artifacts/lab-2` di repository ini

Goals utama dari lab ini adalah membuat sebuah Smart Contract wallet dimana sudah diterapkan aturan kepemilikan (ownership) dan allowance untuk dapat melakukan transaksi withdraw money (Ether).

### Allowance

Pada `Allowance.sol` kita menggunakan re-usable Smart Contract dari OpenZeppelin untuk membuat aturan ownership

```solidity
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
```

### SharedWallet

Pada `SharedWallet.sol` ada fungsi withdrawMoney dengan menggunakan aturan yang telah dibuat di `Allowance.sol` dimana yang dapa melakukan withdraw hanya owner dan allowance yang sudah menjadi owner.

```solidity
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
    function renounceOwnership() public override onlyOwner {
        revert("Can't renounceOwnership here");
    }

    receive() external payable {
        emit MoneyReceived(msg.sender, msg.value);
    }
}
```

Figure 3: SharedWallet berhasil dideploy

![Screenshot](https://raw.githubusercontent.com/codestronaut/blockchain_uts/main/screenshots/figure_3.png)

## Lab 3: Supply Chain

Source code lab 3 terletak pada direktori `artifacts/lab-3` di repository ini. Pada direktori tersebut hanya terdapat contract.

[Done]: Membuat smart contract dengan solidity di remix IDE dan berhasil deployed
[Blocker]: Development lanjutan dengan Truffle masih belum berhasil

Figure 4: ItemManager berhasil dideploy

![Screenshot](https://raw.githubusercontent.com/codestronaut/blockchain_uts/main/screenshots/figure_4.png)
