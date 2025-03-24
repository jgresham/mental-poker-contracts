// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "../src/EncryptionLayerRemover.sol";
import "../src/BigNumbers/BigNumbers.sol";

/**
 * @dev Benchmark test for 2048-bit encryption layer removal
 * Can be run with: forge test --match-contract BenchmarkRemoveEncryption -vvv
 */
contract BenchmarkRemoveEncryption is Test {
    using BigNumbers for *;

    EncryptionLayerRemover public remover;

    // Standard 2048-bit prime (MODP Group 14 from RFC 3526)
    string constant PRIME_2048 =
        "32317006071311007300338913926423828248817941241140239112842009751400741706634354222619689417363569347117901737909704191754605873209195028853758986185622153212175412514901774520270235796078236248884246189477587641105928646099411723245426622522193230540919037680524235519125679715870117001058055877651038861847280257976054903569732561526167081339361799541336476559160368317896729073178384589680639671900977202194168647225871031411336429319536193471636533209717077448227988588565369208645296636077250268955505928362751121174096972998068410554359584866583291642136218231078990999448652468262416972035911852507045361090559";

    // Test parameters for a known-valid ElGamal encryption
    // In a real system, these would be calculated using the ElGamal algorithm
    string constant GENERATOR = "2";
    string constant PRIVATE_KEY = "65537"; // Small private key for testing
    string constant MESSAGE = "123456789012345678901234567890"; // Message to encrypt/decrypt

    string public publicKey;
    string public c1;
    string public c2;

    function setUp() public {
        remover = new EncryptionLayerRemover();

        // Generate a valid ElGamal encryption/decryption test case
        BigNumber memory g = GENERATOR.fromString();
        BigNumber memory x = PRIVATE_KEY.fromString();
        BigNumber memory p = PRIME_2048.fromString();
        BigNumber memory m = MESSAGE.fromString();

        // Calculate public key: y = g^x mod p
        BigNumber memory y = g.modexp(x, p);
        publicKey = y.toString();

        // Use a fixed "random" r value for reproducibility
        string memory r = "12345";
        BigNumber memory r_bn = r.fromString();

        // Calculate c1 = g^r mod p
        BigNumber memory c1_bn = g.modexp(r_bn, p);
        c1 = c1_bn.toString();

        // Calculate c2 = m * (y^r) mod p
        BigNumber memory yr = y.modexp(r_bn, p);
        BigNumber memory c2_bn = m.mul(yr).mod(p);
        c2 = c2_bn.toString();

        console.log("Benchmark setup complete with 2048-bit prime");
        console.log("Original message:", MESSAGE);
    }

    /**
     * @dev Main benchmark test for 2048-bit decryption
     */
    function testBenchmark2048BitDecryption() public {
        console.log("Starting 2048-bit decryption benchmark...");

        uint256 gasStart = gasleft();
        string memory decrypted = remover.removeEncryptionLayer(c1, c2, PRIVATE_KEY, PRIME_2048);
        uint256 gasUsed = gasStart - gasleft();

        console.log("Decrypted message:", decrypted);
        console.log("Gas used for 2048-bit decryption:", gasUsed);

        assertEq(decrypted, MESSAGE, "Decryption should recover the original message");
    }

    /**
     * @dev Test the function using byte array inputs
     */
    function testBenchmarkWithByteArrays() public {
        console.log("Starting 2048-bit decryption benchmark with byte arrays...");

        // Convert inputs to byte arrays
        BigNumber memory bnC1 = c1.fromString();
        BigNumber memory bnC2 = c2.fromString();
        BigNumber memory bnPrivateKey = PRIVATE_KEY.fromString();
        BigNumber memory bnP = PRIME_2048.fromString();

        bytes memory c1Bytes = bnC1.toBytes();
        bytes memory c2Bytes = bnC2.toBytes();
        bytes memory privateKeyBytes = bnPrivateKey.toBytes();
        bytes memory pBytes = bnP.toBytes();

        uint256 gasStart = gasleft();
        bytes memory decryptedBytes = remover.removeEncryptionLayer(c1Bytes, c2Bytes, privateKeyBytes, pBytes);
        uint256 gasUsed = gasStart - gasleft();

        // Convert result back to string
        BigNumber memory bnResult = decryptedBytes.fromBytes();
        string memory result = bnResult.toString();

        console.log("Decrypted message (from bytes):", result);
        console.log("Gas used for 2048-bit decryption with byte arrays:", gasUsed);

        assertEq(result, MESSAGE, "Decryption with byte arrays should recover the original message");
    }

    /**
     * @dev Compare gas usage between different input sizes
     */
    function testCompareByteArrayVsString() public {
        // String inputs
        uint256 gasStartString = gasleft();
        remover.removeEncryptionLayer(c1, c2, PRIVATE_KEY, PRIME_2048);
        uint256 gasUsedString = gasStartString - gasleft();

        // Byte array inputs
        BigNumber memory bnC1 = c1.fromString();
        BigNumber memory bnC2 = c2.fromString();
        BigNumber memory bnPrivateKey = PRIVATE_KEY.fromString();
        BigNumber memory bnP = PRIME_2048.fromString();

        bytes memory c1Bytes = bnC1.toBytes();
        bytes memory c2Bytes = bnC2.toBytes();
        bytes memory privateKeyBytes = bnPrivateKey.toBytes();
        bytes memory pBytes = bnP.toBytes();

        uint256 gasStartBytes = gasleft();
        remover.removeEncryptionLayer(c1Bytes, c2Bytes, privateKeyBytes, pBytes);
        uint256 gasUsedBytes = gasStartBytes - gasleft();

        emit log_named_uint("Gas used with string inputs", gasUsedString);
        emit log_named_uint("Gas used with byte array inputs", gasUsedBytes);
        emit log_named_int("Difference (bytes - string)", int256(gasUsedBytes) - int256(gasUsedString));
    }

    /**
     * @dev Test specific components of the big number operations
     * This helps identify which operations are most expensive
     */
    function testComponentOperations() public {
        // Setup common values
        BigNumber memory bnC1 = c1.fromString();
        BigNumber memory bnPrivateKey = PRIVATE_KEY.fromString();
        BigNumber memory bnP = PRIME_2048.fromString();

        // Test modular exponentiation (most expensive operation)
        uint256 gasStartModExp = gasleft();
        BigNumber memory c1PowX = bnC1.modexp(bnPrivateKey, bnP);
        uint256 gasUsedModExp = gasStartModExp - gasleft();

        // Test modular inverse
        uint256 gasStartModInv = gasleft();
        BigNumber memory c1PowXInverse = c1PowX.modinv(bnP);
        uint256 gasUsedModInv = gasStartModInv - gasleft();

        // Test modular multiplication
        BigNumber memory bnC2 = c2.fromString();
        uint256 gasStartMulMod = gasleft();
        BigNumber memory result = bnC2.mul(c1PowXInverse).mod(bnP);
        uint256 gasUsedMulMod = gasStartMulMod - gasleft();

        emit log_named_uint("Gas used for modular exponentiation", gasUsedModExp);
        emit log_named_uint("Gas used for modular inverse", gasUsedModInv);
        emit log_named_uint("Gas used for multiplication and modulo", gasUsedMulMod);

        // Validate result
        string memory decrypted = result.toString();
        assertEq(decrypted, MESSAGE, "Component-wise operation should still produce correct result");
    }
}
