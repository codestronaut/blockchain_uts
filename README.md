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

![Screenshot](https://lh3.googleusercontent.com/drgXWKeBe0rl94b3RgKn67xiMIxZpsHYEFh8t6kVArh6_UCdHfl7WkL6YnVZ4VHtVTtkutqBmL3JoFjAAlkmPhQBuTTGyFdMqkViEv18JYR-KmDrzflgtQ0HtKmmgbs3a-p9hocKdPy4-H1A15-hf8UgvjD8D4DnBzP_gi-U9CBUOF-c-Pg8bXfD7wlDuau1iLFKu-kUXFyxMddbnBsMEMru-uSR5C5TWa-A8zbq9FPEMXG6a57NCuyM5Rh2Yj8G-7pHHvbZsdUCbK9yuCo_VEPAs9eobUkABM35KV_1E5c-RnDqD6LeKdlL2rBvH3_fg11XrejgaOcrfAJ-zlk2Zg_q0uPKu-ycX_Gk5ATuWtXTUzxbous8TloR_3HbrhYfo0YIDLZEmlhPHB1ZiFbzLwDgwcoaFA4-b36MPvbof8eDw6SEQbH3m3BoGaZqmcd76lEBcP4gK0BD3AX02LakP8L5z5c4n4sYGBclKlvfBCbNp-a0LAjGgFVLEH_D1jmClYf_Yt82qko9AfNKSI-McguypeeR0N_J4eKn-nfU9Sd9n3v5-1ZoOJzngx1Ipvq_-KyqEvGGTC9yNFqbso_DXd7olzLP-v9E5CPu9GnyXZCPWRKTsUA_em7QPXCtV6nNhGDZ1R1EernYJh1QeYq2qzL0BcjwwPj6rW1t1aOB0kDJMIop3uL68bfvkIdP4mJYlyE-vwo5YLuFSNJUm5eFupG_wI03pjVdLQznANB4jNDtrUaUu70KQIusS2daIx4-v7u-83Bykx7nfIPy5FieefbMoWkuikmVga9vvgf25gixsGnB5DNtY5W8Zb_tcy23L9WNCv0jU1WDeqxwPfUy47chSkLY7x4svxgBpftQBsFFLjC7AmpL4b0fh5zrVKIAMKEQfIJYQbZnyh4-HScueH8cdJwMAMTegDbj8kKBm71BdvKLvA=w1166-h893-no?authuser=0)

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

Figure 2: Memilih sebuah address untuk melakukan widthdraw

![Screenshot](https://lh3.googleusercontent.com/7rd8OKHHkql_1EbYkLWdp0mrx6m818iD8CHdBmMN3uJ5BG5QS-mrkLs3zdOBftSwkMOWLwiy3MBEOm1yiMB4oyMH0ZooS2rwIYOdo__tt3ApKwny83xhyYyr3IUsypF4Lp4hMiWclRT4GnWHE3RebGnRC17N8G__teIQ71ZwGbeN78DvivjUy261gZTRIW2QW5-VD2EfsNl4IYQ8QNUKiB3VBerm0H4lDCnmxh9TDeoWX2eoF7edjrrCtOjFLXHeTUX5JeVtGKIwNPnpIpBaOcUs-KT9DjLCMsCas8EfV7qFk1HIhsYjByI5Bar93UIgEkHD6ekTHK-51dWElif_yGRedFrceAkqJF3zVODWD_nXEFZ2JG6wC2RkZu6MuQWttkox3CAt94CskOFft7gFrrWQynRNpJhhHoqEzcauvUVAwoYptaYUuIMDHirlalMi2prhrcxYth1R4-ccxy6vfElwK4EnzfxgybOLL3RX9Wv0u-480AOyRAo-juKhjTALKdX1QVSKvaSeC3wmcokOzENj0FzXhQX_tjJEDSylAiK57e77aHcd-466ZxRUDtWR1pDng-9fLfE_imbr6OtK99o34wfpk4AubAenqMiym6c5hTizn999tFp4ufjj3l7UW-JjQLUlgRznf3PRg1G1wikhGBobmWWuEJQieqn9I2NSVb-F4nthCKjZN9xLKeM-Hv6gatlkYCWVi8caT3X2yc7rKyb8vzMeqIxdtWPChW0C68wJWAXTkZyYyDU_K3FXDilVUUT8zYdL8gUToN6G97ZJgSeaDSjC2xk4Clk7eLBXf1IPApZbvH4-gB0dNmJ5SDLbZFODqN4mrc0iKm7wHV4AXtD9J8jnlF0_Lyd6RcnUHyTgg2QzPgZK9eqPyp3Tpr3COLFOlUdoehsxtX1TJ0Uwgml2bwv_v6lqChSP7QHsZfpEhA=w1166-h893-no?authuser=0)

Figure 3: Melakukan withdraw ke address terpilih (transaksi akan terblock selama 1 menit dari waktu deposit) karena ditambahkan `block.timestamp`. Setelah 1 menit, target address menerima 1 Ether

![Screenshot](https://lh3.googleusercontent.com/7rd8OKHHkql_1EbYkLWdp0mrx6m818iD8CHdBmMN3uJ5BG5QS-mrkLs3zdOBftSwkMOWLwiy3MBEOm1yiMB4oyMH0ZooS2rwIYOdo__tt3ApKwny83xhyYyr3IUsypF4Lp4hMiWclRT4GnWHE3RebGnRC17N8G__teIQ71ZwGbeN78DvivjUy261gZTRIW2QW5-VD2EfsNl4IYQ8QNUKiB3VBerm0H4lDCnmxh9TDeoWX2eoF7edjrrCtOjFLXHeTUX5JeVtGKIwNPnpIpBaOcUs-KT9DjLCMsCas8EfV7qFk1HIhsYjByI5Bar93UIgEkHD6ekTHK-51dWElif_yGRedFrceAkqJF3zVODWD_nXEFZ2JG6wC2RkZu6MuQWttkox3CAt94CskOFft7gFrrWQynRNpJhhHoqEzcauvUVAwoYptaYUuIMDHirlalMi2prhrcxYth1R4-ccxy6vfElwK4EnzfxgybOLL3RX9Wv0u-480AOyRAo-juKhjTALKdX1QVSKvaSeC3wmcokOzENj0FzXhQX_tjJEDSylAiK57e77aHcd-466ZxRUDtWR1pDng-9fLfE_imbr6OtK99o34wfpk4AubAenqMiym6c5hTizn999tFp4ufjj3l7UW-JjQLUlgRznf3PRg1G1wikhGBobmWWuEJQieqn9I2NSVb-F4nthCKjZN9xLKeM-Hv6gatlkYCWVi8caT3X2yc7rKyb8vzMeqIxdtWPChW0C68wJWAXTkZyYyDU_K3FXDilVUUT8zYdL8gUToN6G97ZJgSeaDSjC2xk4Clk7eLBXf1IPApZbvH4-gB0dNmJ5SDLbZFODqN4mrc0iKm7wHV4AXtD9J8jnlF0_Lyd6RcnUHyTgg2QzPgZK9eqPyp3Tpr3COLFOlUdoehsxtX1TJ0Uwgml2bwv_v6lqChSP7QHsZfpEhA=w1166-h893-no?authuser=0)

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

![Screenshot](https://lh3.googleusercontent.com/_PE8sSGV5HePCQlj0WCHnfg_A9Ucvw55wOwKRLurxowXqAK2nUz-bAMs11mQ2M_MHg4W-FU366Cvrsujiz9r9mP-ByZXaeJV6LcIiO9shVQI6oi8VP2yhPZiD2x4B1pffFlRLj_3oLgT3E1UaB6xwUQG-vXHU0oGB_Yg69rQvYN51K-MLhDZZkv3frz3J03MA6aeFNEf1olW9qAv-8fPjOjyiZBPT8xmpW4SHZ0f7bxpUmrMmdW0EPABh7JOSYpLyAD7ggkyHoXGG7oWf_EJxlLnPaBVTg11_koHG2f3pzxeb0aMWy2tJBjGt-JD8ches5JGKgLw2g4BU6yyaWgC3TNY26t4_fceG0KXxJOWmNGfClEaf9U0GjlIkgmKb32DKSArUK8zmsc9ntFWTbUsgFIj3pQVICd6Trne8yue6x5S8wFSbiKNbTSdk-thWAhJDda8fjHqzWpc6NNXeBUvLfS6Z5GVTiI2CV9cX4aqIZ8dpwlpn9PAO60z3wkEfRGjicL8oKsp_WCn3Ab7RV7vHWGsdD0TOnuCi6WSonaz4co2-IkAqZaGjHTOnXqqZwXQIKDKLTHPPph9PtI2QZJ0nlvdxyReBTityKOIWXp0uO6aimmBNXiWhUud0NgbppEXqFp3qZ4tKJ-LI2Y77PypQw2SjHBVV6qNrATNPwMw-wP7elOu8Z0kLFo3ZbXHU1y2btf4l7pZKgb7B6G1RjQYfIU5-dmDN9U2BSJerKZ2IKlY2a9XOWh9IlNelKqJkh3MsO2K7uD4FQvLGTCGLlSRiqdr2FCnvrtdwh0bCa9X8qouVpmV789B17W5QqtQ3GGjfs5gwVbLiXf8HSGtTQt-COscN4S-Xm-TQqPV3TSQpDiM1bdDfPCz2CvmOgu746NNAXmXa6P6Wbmswz2eI_2trK4GwSsIQsVv-xJwsbU5yjwI8TvikA=w1166-h893-no?authuser=0)

## Lab 3: Supply Chain

Source code lab 3 terletak pada direktori `artifacts/lab-3` di repository ini. Pada direktori tersebut hanya terdapat contract.

[Done]: Membuat smart contract dengan solidity di remix IDE dan berhasil deployed
[Blocker]: Development lanjutan dengan Truffle masih belum berhasil

Figure 3: ItemManager berhasil dideploy

![Screenshot](https://lh3.googleusercontent.com/2YcE7xUK6odcqVr6Sv2h8Ytsf_d0EBgOqr4j0quzvRuNDWFYc6coBNpsqlT9Zg5DhuGYX8yaVH-lANT7keB4IeKGxRWoY1QvcLW17H8oKn_5zzHHFXa-twOARRdxH3dU4UPgeg7GuyVO1aMioF66-hq9PB9lkshNF5kXlVBsKXN0KlNoj2n1ABL1e36qaHG5ZCacBSUiEZWTF7oquD46e1OpqLVF1zQI6tc_vNjMPx3JrqFIpa0rEGivc7b_G-RQmBVTa6UdYdbMtO9IqYIH-yi5_yIL0nLLieDoASEiJOc8vMXGAcC1ajSfZRczAdJmJ1PQ1j5fNHFOQ6iz6FgVYtroyXLryZavWf7n7w4OM14F8LsY6X9oghOKykYug48r0ortj2He9QCYiC5QMBW9K0FblXG-pMNYzlQjf0tQxDRmHovFmR8_hr5-V5D1rpDbogoZmDJhPq37-aA1pNmXN0oujOcRgyjsEWMp6PAGVxXNcyu_Hgvd_2gb9fOEFmkiOswKffnNjUdy0CMfa4GJeJ8NdwKZgsYIJmYOsWSphCD8v11NvPReta9U139TsMBVkF0ItNaa448ftqasKGgUpv8CIiWzZSk0Qw5cy25jJza5GIz-BcfUXosDOyGxXKxmICbzOEuRZFapBCC4sMGkkV9zR2V_Vtqxm_Z9n9LcpEZMo0kf6jZwAwmoRV1dNPeXT_zOIO5XU7TtYIL2Zj5t2b8mXdS1uQj4M0-I285p3sfO0TaXhOjYI1UUa0aujIUVx_YRT8QCCh77WlZhsHf7anEdz8OckREuwIpBAzVx-l4EXGhY0Mh5i3t9ikVCoBgSRRBjKjGJS1Fl70ROZ8qhIG4OkUpwAqaIx31X3vBSNHVvBfGUN5VSEnL4rLTlPefjJZwNveBS5o2JL7JwNphpd6LtMSzw0CLFvGwsSDSYAwDzNljZXA=w1166-h893-no?authuser=0&authuser=0)
