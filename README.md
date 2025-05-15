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
# to get the contract byte sizes (evm limitation at 25KB currently, soon 256KB), run
$ forge build --sizes
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

#### Local
```shell
anvil --block-time 2 --port 8545
# chainId = 31337
# Deploy to a local anvil network
forge script script/DeployAll.s.sol:DeployAll --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

# Base Sepolia
forge script script/DeployProd.s.sol:DeployProd --rpc-url https://sepolia.base.org --private-key $PRIVATE_KEY --chain base-sepolia --verifier-url https://api-sepolia.basescan.org/api --broadcast --verify

# Base
forge script script/DeployProd.s.sol:DeployProd --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY --chain base --verifier-url https://api.basescan.org/api --broadcast --verify

# Optimism
forge script script/DeployProd.s.sol:DeployProd --rpc-url https://mainnet.optimism.io --private-key $PRIVATE_KEY --chain optimism --verifier-url https://api-optimistic.etherscan.io/api --broadcast --verify --verifier-api-key $OP_ETHERSCAN_API_KEY

# Arbitrum
forge script script/DeployProd.s.sol:DeployProd --rpc-url https://arb1.arbitrum.io/rpc --private-key $PRIVATE_KEY --chain arbitrum --verifier-url https://api.arbiscan.io/api --broadcast --verify --verifier-api-key $ARBISCAN_API_KEY

```

## Verify if it fails after deploy

```shell
forge verify-contract <deployed-contract-address> src/TexasHoldemRoom.sol:TexasHoldemRoom --chain base-sepolia --etherscan-api-key $ETHERSCAN_API_KEY --verifier-url https://sepolia.base.org --watch

forge verify-contract 0xBABEc5F06672aB06113BEC7532397bEb6a1702bc src/TexasHoldemRoom.sol:TexasHoldemRoom --chain base-sepolia --etherscan-api-key $ETHERSCAN_API_KEY --verifier-url https://api-sepolia.basescan.org/api --watch

forge verify-contract 0xF2635f00300F16D9acA57F955091Cc24DD01F7d1 src/BigNumbers/BigNumbers.sol:BigNumbers --chain base-sepolia --etherscan-api-key $ETHERSCAN_API_KEY --verifier-url https://api-sepolia.basescan.org/api --watch --flatten
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


## Deploys
Mon, Apr 28th 2025
```
== Logs ==
  Contract TexasHoldemRoom deployed at: 0xf34890f942220f48391BA33Ff053f64Aa8979956
  Contract DeckHandler deployed at: 0x8ad3D9cf837117d44Ec08e77a3C38420f92243E9

## Setting up 1 EVM.

==========================

Chain 8453

Estimated gas price: 0.007277138 gwei

Estimated total gas used for script: 27820265

Estimated amount required: 0.00020245190760157 ETH
```