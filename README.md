# UTS Blockchain

## Lab 1: Deposit & Withdraw Ether

Source code lab 1 terletak pada direktori `artifacts/SendMoneyExample.sol` di repository ini

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

![Screenshot](https://lh3.googleusercontent.com/drgXWKeBe0rl94b3RgKn67xiMIxZpsHYEFh8t6kVArh6_UCdHfl7WkL6YnVZ4VHtVTtkutqBmL3JoFjAAlkmPhQBuTTGyFdMqkViEv18JYR-KmDrzflgtQ0HtKmmgbs3a-p9hocKdPy4-H1A15-hf8UgvjD8D4DnBzP_gi-U9CBUOF-c-Pg8bXfD7wlDuau1iLFKu-kUXFyxMddbnBsMEMru-uSR5C5TWa-A8zbq9FPEMXG6a57NCuyM5Rh2Yj8G-7pHHvbZsdUCbK9yuCo_VEPAs9eobUkABM35KV_1E5c-RnDqD6LeKdlL2rBvH3_fg11XrejgaOcrfAJ-zlk2Zg_q0uPKu-ycX_Gk5ATuWtXTUzxbous8TloR_3HbrhYfo0YIDLZEmlhPHB1ZiFbzLwDgwcoaFA4-b36MPvbof8eDw6SEQbH3m3BoGaZqmcd76lEBcP4gK0BD3AX02LakP8L5z5c4n4sYGBclKlvfBCbNp-a0LAjGgFVLEH_D1jmClYf_Yt82qko9AfNKSI-McguypeeR0N_J4eKn-nfU9Sd9n3v5-1ZoOJzngx1Ipvq_-KyqEvGGTC9yNFqbso_DXd7olzLP-v9E5CPu9GnyXZCPWRKTsUA_em7QPXCtV6nNhGDZ1R1EernYJh1QeYq2qzL0BcjwwPj6rW1t1aOB0kDJMIop3uL68bfvkIdP4mJYlyE-vwo5YLuFSNJUm5eFupG_wI03pjVdLQznANB4jNDtrUaUu70KQIusS2daIx4-v7u-83Bykx7nfIPy5FieefbMoWkuikmVga9vvgf25gixsGnB5DNtY5W8Zb_tcy23L9WNCv0jU1WDeqxwPfUy47chSkLY7x4svxgBpftQBsFFLjC7AmpL4b0fh5zrVKIAMKEQfIJYQbZnyh4-HScueH8cdJwMAMTegDbj8kKBm71BdvKLvA=w1166-h893-no)

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
