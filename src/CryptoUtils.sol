// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./BigNumbers/BigNumbers.sol";
import "./TexasHoldemRoom.sol";
/**
 * @title CryptoUtils
 * @dev Implements cryptographic utilities for mental poker
 */

contract CryptoUtils {
    using BigNumbers for BigNumber;

    // 2048-bit prime number
    BigNumber private P_2048;
    uint256 constant G_2048 = 2;
    uint256 public constant MAX_PLAYERS = 10;
    uint8 public constant EMPTY_SEAT = 255;

    event CULog(string message);

    constructor() {
        // Initialize P_2048
        // bytes memory p2048Bytes =
        //     hex"FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B1FE649286651ECE45B3DC2007CB8A163BF0598DA48361C55D39A69163FA8FD24CF5F83655D23DCA3AD961C62F356208552BB9ED529077096966D670C354E4ABC9804F1746C08CA18217C32905E462E36CE3BE39E772C180E86039B2783A2EC07A28FB5C55DF06F4C52C9DE2BCBF695581718399549CCEA956AE515D2261898FA051015728E5A8AACAA68FFFFFFFFFFFFFFFF";
        bytes memory p2048Bytes =
            hex"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD1";
        P_2048 = BigNumbers.init(p2048Bytes, false, 256);
    }

    struct EncryptedCard {
        BigNumber c1; // 2048-bit number
        BigNumber c2; // 2048-bit number
    }

    // May no longer be accurate
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
    function verifyDecryptCard(
        EncryptedCard memory encryptedCard,
        BigNumber memory privateKey,
        BigNumber memory c1InversePowPrivateKey
    ) public returns (BigNumber memory) {
        BigNumber memory c1PowPrivateKey = BigNumbers.modexp(encryptedCard.c1, privateKey, P_2048);
        emit CULog("c1PowPrivateKey");
        bool verifyResult = BigNumbers.modinvVerify(c1PowPrivateKey, P_2048, c1InversePowPrivateKey);
        emit CULog("verifyResult");
        require(verifyResult, "Invalid modular inverse");
        emit CULog("modmul");
        return BigNumbers.modmul(encryptedCard.c2, c1InversePowPrivateKey, P_2048);
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
            bytes32 entropy = keccak256(abi.encodePacked(block.timestamp, block.prevrandao));
            bytes memory randomBytes = new bytes(32); // 2048 bits = 256 bytes, 256 bits = 32 bytes
            for (uint256 i = 0; i < 32; i += 32) {
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
        BigNumber memory c2 =
            BigNumbers.modmul(BigNumbers.modexp(pubKey, rToUse, P_2048), message, P_2048);

        return EncryptedCard(c1, c2);
    }

    function decodeBigintMessage(BigNumber memory message) public pure returns (string memory) {
        // possibly put this in decryptCard(), but don't want extra gas cost for all intermediate decryptions
        // Extract the actual value from BigNumber, ignoring leading zeros
        bytes memory decryptedBytes = message.val;
        uint256 startIndex = 0;

        // Find the first non-zero byte
        for (uint256 i = 0; i < decryptedBytes.length; i++) {
            if (decryptedBytes[i] != 0) {
                startIndex = i;
                break;
            }
        }

        // Create a new bytes array with only the significant bytes
        bytes memory trimmedBytes = new bytes(decryptedBytes.length - startIndex);
        for (uint256 i = 0; i < trimmedBytes.length; i++) {
            trimmedBytes[i] = decryptedBytes[i + startIndex];
        }

        string memory decryptedCardString = string(trimmedBytes);
        return decryptedCardString;
    }

    // string equality check
    function strEq(string memory a, string memory b) public pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}
