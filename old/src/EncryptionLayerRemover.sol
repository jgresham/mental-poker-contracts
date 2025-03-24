// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./BigNumbers/BigNumbers.sol";

contract EncryptionLayerRemover {
    using BigNumbers for *;

    // Event for logging
    event LayerRemoved(string decrypted);

    /**
     * @dev Removes an encryption layer using private key
     * @param c1 The first ciphertext component as a BigNumber string (base 10)
     * @param c2 The second ciphertext component as a BigNumber string (base 10)
     * @param privateKey The private key for decryption as a BigNumber string (base 10)
     * @param p The modulus as a BigNumber string (base 10)
     * @return decrypted The decrypted value as a BigNumber string (base 10)
     */
    function removeEncryptionLayer(string memory c1, string memory c2, string memory privateKey, string memory p)
        public
        returns (string memory)
    {
        // Convert string inputs to BigNumber format
        BigNumber memory bnC1 = c1.fromString();
        BigNumber memory bnC2 = c2.fromString();
        BigNumber memory bnPrivateKey = privateKey.fromString();
        BigNumber memory bnP = p.fromString();

        // Log for debugging in development environments
        emit LogOperation("Removing encryption layer", privateKey, p);

        // Compute c1^privateKey mod p
        BigNumber memory c1PowX = bnC1.modexp(bnPrivateKey, bnP);

        // Compute modular inverse of c1^privateKey
        BigNumber memory c1PowXInverse = c1PowX.modinv(bnP);

        // Compute m = c2 * (c1^x)^-1 mod p
        BigNumber memory bnDecrypted = bnC2.mul(c1PowXInverse);
        bnDecrypted = bnDecrypted.mod(bnP);

        // Convert to string for return value and logging
        string memory decrypted = bnDecrypted.toString();

        // Log the result
        emit LogResult("Removed layer", decrypted);
        emit LayerRemoved(decrypted);

        return decrypted;
    }

    /**
     * @dev Overloaded version that accepts byte arrays for compatibility
     * This allows callers to pass raw byte representations of big numbers
     */
    function removeEncryptionLayer(
        bytes memory c1Bytes,
        bytes memory c2Bytes,
        bytes memory privateKeyBytes,
        bytes memory pBytes
    ) public returns (bytes memory) {
        // Convert bytes to BigNumber format
        BigNumber memory bnC1 = c1Bytes.fromBytes();
        BigNumber memory bnC2 = c2Bytes.fromBytes();
        BigNumber memory bnPrivateKey = privateKeyBytes.fromBytes();
        BigNumber memory bnP = pBytes.fromBytes();

        // Log for debugging
        emit LogOperation("Removing encryption layer (bytes)", bnPrivateKey.toString(), bnP.toString());

        // Compute c1^privateKey mod p
        BigNumber memory c1PowX = bnC1.modexp(bnPrivateKey, bnP);

        // Compute modular inverse of c1^privateKey
        BigNumber memory c1PowXInverse = c1PowX.modinv(bnP);

        // Compute m = c2 * (c1^x)^-1 mod p
        BigNumber memory bnDecrypted = bnC2.mul(c1PowXInverse);
        bnDecrypted = bnDecrypted.mod(bnP);

        // Convert to bytes for return
        bytes memory decryptedBytes = bnDecrypted.toBytes();

        // Log the result
        emit LogResult("Removed layer (bytes)", bnDecrypted.toString());
        emit LayerRemoved(bnDecrypted.toString());

        return decryptedBytes;
    }

    // Events for extended logging
    event LogOperation(string operation, string privateKey, string modulus);
    event LogResult(string message, string result);

    /**
     * @dev Convenience function to convert a hex string to a decimal string
     * @param hexStr The hex string (with or without 0x prefix)
     * @return The decimal string representation
     */
    function hexToDecimal(string memory hexStr) public pure returns (string memory) {
        BigNumber memory bn = hexStr.fromHexString();
        return bn.toString();
    }

    /**
     * @dev Convenience function to convert a decimal string to a hex string
     * @param decStr The decimal string
     * @return The hex string representation (with 0x prefix)
     */
    function decimalToHex(string memory decStr) public pure returns (string memory) {
        BigNumber memory bn = decStr.fromString();
        return bn.toHexString();
    }
}
