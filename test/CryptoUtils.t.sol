// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import {CryptoUtils} from "../src/CryptoUtils.sol";
import "../src/BigNumbers/BigNumbers.sol";

contract CryptoUtilsTest is Test {
    using BigNumbers for BigNumber;

    CryptoUtils public cryptoUtils;
    BigNumber public testMessage;
    uint256 public testPrivateKey;
    uint256 public testPublicKey;

    function setUp() public {
        cryptoUtils = new CryptoUtils();

        // Initialize test message (a small number for testing)
        testMessage = BigNumbers.init(42, false);
        console.log("Test message value:");
        console.logBytes(testMessage.val);

        // Initialize test keys
        testPrivateKey = 12345;
        testPublicKey = 67890;
        console.log("Test private key:", testPrivateKey);
        console.log("Test public key:", testPublicKey);
    }

    function testModInverse() public view {
        // Test with small numbers for verification
        BigNumber memory a = BigNumbers.init(3, false);
        BigNumber memory m = BigNumbers.init(11, false);

        console.log("Testing modInverse with a =");
        console.logBytes(a.val);
        console.log("m =");
        console.logBytes(m.val);

        BigNumber memory inverse = cryptoUtils.modInverse(a, m);
        console.log("Inverse result =");
        console.logBytes(inverse.val);

        // Verify: (a * inverse) mod m should be 1
        BigNumber memory product = BigNumbers.modmul(a, inverse, m);
        console.log("Product (should be 1) =");
        console.logBytes(product.val);
        assertTrue(BigNumbers.eq(product, BigNumbers.init(1, false)));
    }

    function testElGamalEncryptionDecryption() public view {
        console.log("\nTesting ElGamal encryption/decryption");
        console.log("Original message:");
        console.logBytes(testMessage.val);

        // Encrypt the message
        CryptoUtils.EncryptedCard memory encryptedCard = cryptoUtils.encryptMessageBigint(
            testMessage,
            testPublicKey,
            50 // Use random r
        );
        console.log("Encrypted card c1:");
        console.logBytes(encryptedCard.c1.val);
        console.log("Encrypted card c2:");
        console.logBytes(encryptedCard.c2.val);

        // Decrypt the message
        BigNumber memory decryptedMessage = cryptoUtils.decryptCard(encryptedCard, testPrivateKey);
        console.log("Decrypted message:");
        console.logBytes(decryptedMessage.val);

        // Verify the decrypted message matches the original
        assertTrue(BigNumbers.eq(decryptedMessage, testMessage));
    }

    function testElGamalEncryptionDecryptionWithFixedR() public view {
        console.log("\nTesting ElGamal encryption/decryption with fixed R");
        console.log("Original message:");
        console.logBytes(testMessage.val);

        // Use a fixed random value for deterministic testing
        uint256 fixedR = 54321;
        console.log("Using fixed R value:", fixedR);

        // Encrypt the message
        CryptoUtils.EncryptedCard memory encryptedCard =
            cryptoUtils.encryptMessageBigint(testMessage, testPublicKey, fixedR);
        console.log("Encrypted card c1:");
        console.logBytes(encryptedCard.c1.val);
        console.log("Encrypted card c2:");
        console.logBytes(encryptedCard.c2.val);

        // Decrypt the message
        BigNumber memory decryptedMessage = cryptoUtils.decryptCard(encryptedCard, testPrivateKey);
        console.log("Decrypted message:");
        console.logBytes(decryptedMessage.val);

        // Verify the decrypted message matches the original
        assertTrue(BigNumbers.eq(decryptedMessage, testMessage));
    }

    function testElGamalEncryptionDecryptionWithLargeNumbers() public view {
        console.log("\nTesting ElGamal encryption/decryption with large numbers");

        // Test with a larger message
        bytes memory largeMessageBytes = new bytes(256); // 2048 bits
        for (uint256 i = 0; i < 256; i++) {
            largeMessageBytes[i] = bytes1(uint8(i % 256));
        }
        BigNumber memory largeMessage = BigNumbers.init(largeMessageBytes, false);
        console.log("Large message:");
        console.logBytes(largeMessage.val);

        // Encrypt the message
        CryptoUtils.EncryptedCard memory encryptedCard = cryptoUtils.encryptMessageBigint(
            largeMessage,
            testPublicKey,
            0 // Use random r
        );
        console.log("Encrypted card c1:");
        console.logBytes(encryptedCard.c1.val);
        console.log("Encrypted card c2:");
        console.logBytes(encryptedCard.c2.val);

        // Decrypt the message
        BigNumber memory decryptedMessage = cryptoUtils.decryptCard(encryptedCard, testPrivateKey);
        console.log("Decrypted message:");
        console.logBytes(decryptedMessage.val);

        // Verify the decrypted message matches the original
        assertTrue(BigNumbers.eq(decryptedMessage, largeMessage));
    }

    function testElGamalEncryptionDecryptionWithZeroMessage() public view {
        console.log("\nTesting ElGamal encryption/decryption with zero message");

        // Test with zero message
        BigNumber memory zeroMessage = BigNumbers.init(0, false);
        console.log("Zero message:");
        console.logBytes(zeroMessage.val);

        // Encrypt the message
        CryptoUtils.EncryptedCard memory encryptedCard = cryptoUtils.encryptMessageBigint(
            zeroMessage,
            testPublicKey,
            0 // Use random r
        );
        console.log("Encrypted card c1:");
        console.logBytes(encryptedCard.c1.val);
        console.log("Encrypted card c2:");
        console.logBytes(encryptedCard.c2.val);

        // Decrypt the message
        BigNumber memory decryptedMessage = cryptoUtils.decryptCard(encryptedCard, testPrivateKey);
        console.log("Decrypted message:");
        console.logBytes(decryptedMessage.val);

        // Verify the decrypted message matches the original
        assertTrue(BigNumbers.eq(decryptedMessage, zeroMessage));
    }

    function testElGamalEncryptionDecryptionWithNegativeMessage() public view {
        console.log("\nTesting ElGamal encryption/decryption with negative message");

        // Test with negative message
        BigNumber memory negativeMessage = BigNumbers.init(42, true);
        console.log("Negative message:");
        console.logBytes(negativeMessage.val);

        // Encrypt the message
        CryptoUtils.EncryptedCard memory encryptedCard = cryptoUtils.encryptMessageBigint(
            negativeMessage,
            testPublicKey,
            0 // Use random r
        );
        console.log("Encrypted card c1:");
        console.logBytes(encryptedCard.c1.val);
        console.log("Encrypted card c2:");
        console.logBytes(encryptedCard.c2.val);

        // Decrypt the message
        BigNumber memory decryptedMessage = cryptoUtils.decryptCard(encryptedCard, testPrivateKey);
        console.log("Decrypted message:");
        console.logBytes(decryptedMessage.val);

        // Verify the decrypted message matches the original
        assertTrue(BigNumbers.eq(decryptedMessage, negativeMessage));
    }
}
