// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./BigNumbers/BigNumbers.sol";

/**
 * @title CryptoUtils
 * @dev Implements cryptographic utilities for mental poker
 */
contract CryptoUtils {
    using BigNumbers for BigNumber;

    // 2048-bit prime number
    BigNumber private P_2048;
    uint256 constant G_2048 = 2;

    constructor() {
        // Initialize P_2048
        bytes memory p2048Bytes =
            hex"FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B1FE649286651ECE45B3DC2007CB8A163BF0598DA48361C55D39A69163FA8FD24CF5F83655D23DCA3AD961C62F356208552BB9ED529077096966D670C354E4ABC9804F1746C08CA18217C32905E462E36CE3BE39E772C180E86039B2783A2EC07A28FB5C55DF06F4C52C9DE2BCBF695581718399549CCEA956AE515D2261898FA051015728E5A8AACAA68FFFFFFFFFFFFFFFF";
        P_2048 = BigNumbers.init(p2048Bytes, false);
    }

    struct EncryptedCard {
        BigNumber c1; // 2048-bit number
        BigNumber c2; // 2048-bit number
    }

    // /**
    //  * @dev Decrypts a card using ElGamal decryption
    //  * @param encryptedCard The encrypted card (c1, c2)
    //  * @param privateKey The private key of the player decrypting the card
    //  * @return The decrypted card
    //  */
    // function decryptCard(EncryptedCard memory encryptedCard, uint256 privateKey)
    //     public
    //     view
    //     returns (BigNumber memory)
    // {
    //     BigNumber memory c1PowPrivateKey =
    //         BigNumbers.modexp(encryptedCard.c1, BigNumbers.init(privateKey, false), P_2048);
    //     BigNumber memory c1Inverse = modInverse(c1PowPrivateKey, P_2048);
    //     return BigNumbers.modmul(encryptedCard.c2, c1Inverse, P_2048);
    // }

    // TODO: modify this function to just verify the modular inverse and have the user supply the result (c1Inverse)
    /**
     * @dev Decrypts a card using ElGamal decryption
     * @param encryptedCard The encrypted card (c1, c2)
     * @param privateKey The private key of the player decrypting the card
     * @return The decrypted card
     */
    function decryptCard(EncryptedCard memory encryptedCard, uint256 privateKey)
        public
        view
        returns (BigNumber memory)
    {
        BigNumber memory c1PowPrivateKey =
            BigNumbers.modexp(encryptedCard.c1, BigNumbers.init(privateKey, false), P_2048);
        BigNumber memory c1Inverse = modInverse(c1PowPrivateKey, P_2048);
        return BigNumbers.modmul(encryptedCard.c2, c1Inverse, P_2048);
    }

    // This is on chain in case of a dispute and we want to verify that a user correctly encrypted each card
    /**
     * @dev Encrypts a message using ElGamal encryption
     * @param message The message to encrypt (2048-bit)
     * @param publicKey The public key to encrypt with
     * @param r Optional random value (if not provided, will be generated)
     * @return The encrypted message (c1, c2)
     */
    function encryptMessageBigint(BigNumber memory message, uint256 publicKey, uint256 r)
        public
        view
        returns (EncryptedCard memory)
    {
        BigNumber memory rToUse;
        if (r == 0) {
            // Generate random 2048-bit number
            bytes32 entropy = keccak256(abi.encodePacked(block.timestamp, block.difficulty));
            bytes memory randomBytes = new bytes(256); // 2048 bits = 256 bytes
            for (uint256 i = 0; i < 256; i += 32) {
                bytes32 randomWord = keccak256(abi.encodePacked(entropy, i));
                assembly {
                    mstore(add(add(randomBytes, 0x20), i), randomWord)
                }
            }
            rToUse = BigNumbers.init(randomBytes, false);
        } else {
            rToUse = BigNumbers.init(r, false);
        }

        BigNumber memory g = BigNumbers.init(G_2048, false);
        BigNumber memory c1 = BigNumbers.modexp(g, rToUse, P_2048);

        BigNumber memory pubKey = BigNumbers.init(publicKey, false);
        BigNumber memory c2 = BigNumbers.modmul(BigNumbers.modexp(pubKey, rToUse, P_2048), message, P_2048);

        return EncryptedCard(c1, c2);
    }
}
