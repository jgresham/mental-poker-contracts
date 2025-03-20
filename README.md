# Mental Poker

**Mental Poker is a cryptographic protocol that allows players to play a fair card game without the need for a trusted third party.**

Mental Poker enables:

- **Secure Card Shuffling**: Players can collectively shuffle a deck of cards without any single player knowing the order.
- **Card Dealing**: Cards can be dealt to players without revealing them to others.
- **Card Revelation**: Players can reveal their cards to prove their hand at the end of the game.
- **Cheating Prevention**: The protocol prevents players from cheating by marking cards or stacking the deck.

This implementation uses ElGamal encryption and other cryptographic primitives to enable secure, trustless card games on the Ethereum blockchain.

## How It Works

Mental Poker uses advanced cryptographic techniques like **Commutative Encryption** which allows multiple parties to encrypt and decrypt cards in any order

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
