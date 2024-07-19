MockUSD deployed at: 0x3F938e3c05D975D9E075DC09Bcc61AcA7eD5d95B 
(https://holesky.etherscan.io/address/0x3F938e3c05D975D9E075DC09Bcc61AcA7eD5d95B)

CommodityMarket deployed at: 0x7a706d8c4e258C6f098288F93787a9604DEFfb0a
(https://holesky.etherscan.io/address/0x7a706d8c4e258C6f098288F93787a9604DEFfb0a)

Oil Token created with symbol OIL
Gold Token created with symbol GLD
Silver Token created with symbol SLV
Platinum Token created with symbol PLT
Palladium Token created with symbol PLD
Copper Token created with symbol CPR
Rbob Gas Token created with symbol RBOB
Natural Gas Token created with symbol NG
Brent Crude Oil Token created with symbol BRNT
Corn Token created with symbol CRN
Soybean Token created with symbol SBN
Rough Rice Token created with symbol RR
Cocoa Token created with symbol CCA
Lumber Token created with symbol LMBR

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
