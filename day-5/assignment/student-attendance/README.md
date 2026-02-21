## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

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

### Contract Address - Foundry

| Contract | Address |
|----------|---------|
| ERC20 | 0xF93844A5e83123e3152584231C9C3C1a39c591f5 |
| SaveEther | 0xCfEc8589578d1b5dB8B32DF7D311dD0fE63c62d7 |
| SaveAsset | 0xce5B6D2aFF2d46e7156da0BA570Fa09E16905717 |
| SchoolManagement | 0x2DfC1a971BeEf73da37C6B72708E8f9f1453EeC2 |
| Todo | 0x1e13aD3Fb83E761e194E34BfF68208d606be85d4 |
