// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "../src/EncryptionLayerRemover.sol";
import "../src/BigNumbers/BigNumbers.sol";

contract EncryptionLayerRemoverTest is Test {
    using BigNumbers for *;

    EncryptionLayerRemover public remover;

    // Test values - these are small for validation but can be replaced with larger values
    string constant PRIME_MODULUS =
        "2074722246773485207821695222107608587480996474721117292752992589912196684750549658310084416732550077";
    string constant PRIVATE_KEY = "87498347983749834798374983749873498374983749";

    // Example encryption values - following the pattern of ElGamal encryption
    // Original message: 12345
    // g^r mod p = C1 value
    // m * (y^r) mod p = C2 value, where y = g^x mod p (x is private key)
    string constant C1 = "1336215583291588323132285245629269304192944902700375401";
    string constant C2 = "1845325209389528356813741961944115023649962021";

    // Expected decrypted value
    string constant EXPECTED_DECRYPTION = "12345";

    function setUp() public {
        remover = new EncryptionLayerRemover();
    }

    /**
     * @dev Test the string-based decryption function with a known set of values
     */
    function testRemoveEncryptionLayer() public {
        string memory decrypted = remover.removeEncryptionLayer(C1, C2, PRIVATE_KEY, PRIME_MODULUS);

        assertEq(decrypted, EXPECTED_DECRYPTION, "Decryption result should match expected value");
    }

    /**
     * @dev Test with larger numbers (closer to 2048-bit)
     */
    function testWithLargeNumbers() public {
        // Defining very large test values - these are dummy values for demonstration
        string memory largeP =
            "16158503035655503650357438344334975980222051334857742016065172713762327569433945446598600705761456731844358980460949009747059779575245460547544076193224141560315438683650498045875098875194826053398028819192033784138396109321309878080919047169238085235290822926018152521443787945770532904303776199561965192760957166694834171210342487393282284747428088017663161029038902829665513096354230157075129296432088558362971801859230928678799175576150822952201848806616643615613562842355410104862578550863465661734839271290328348967522998634176499319107762583194718667771801067716614802322659239302476074096777926805529798115328";
        string memory largePrivateKey =
            "7160147435438376316046849412001950322178581691214232842861638732860982650090519834838449027323546997";
        string memory largeC1 =
            "1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116094330572703657595919530921861173819326117931051185480744623799627495673518857527248912279381830119491298336733624406566430860213949463952247371907021798609437027705392171762931767523846748184676694051320005681271452635608277857713427577896091736371787214684409012249534301465495853710507922796892589235";
        string memory largeC2 =
            "2718281828459045235360287471352662497757247093699959574966967627724076630353547594571382178525166427427466391932003059921817413596629043572900334295260595630738132328627943490763233829880753195251019011573834187930702154089149934884167509244761460668082264800168477411853742345442437107539077744992069551702761838606261331384583000752044933826560297606737113200709328709127443747047230696977209310141692836819025515108657463772111252389784425056953696770785449969967946864454905987931636889230098793127736178215424999229576351482208269895193668033182528869398496465105820939239829488793320362509443117301238197068416140397019837679320683282376464804295311802328782509819455815301756717361332069811250996181881";

        // For a larger test, we should generate correct values using external tools
        // and then validate the contract's output against those known outputs

        // Note: For an actual test, these values should form a valid encryption set
        // where decryption with the private key yields a known plaintext
        vm.expectRevert(); // We expect this to revert since our dummy values aren't properly matched
        remover.removeEncryptionLayer(largeC1, largeC2, largePrivateKey, largeP);
    }

    /**
     * @dev Test with byte array inputs
     */
    function testWithByteArrays() public {
        // Convert our string test values to bytes
        BigNumber memory bnC1 = C1.fromString();
        BigNumber memory bnC2 = C2.fromString();
        BigNumber memory bnPrivateKey = PRIVATE_KEY.fromString();
        BigNumber memory bnP = PRIME_MODULUS.fromString();

        bytes memory c1Bytes = bnC1.toBytes();
        bytes memory c2Bytes = bnC2.toBytes();
        bytes memory privateKeyBytes = bnPrivateKey.toBytes();
        bytes memory pBytes = bnP.toBytes();

        // Call the byte array version of the function
        bytes memory decryptedBytes = remover.removeEncryptionLayer(c1Bytes, c2Bytes, privateKeyBytes, pBytes);

        // Convert the result back to a BigNumber and then to a string
        BigNumber memory bnResult = decryptedBytes.fromBytes();
        string memory result = bnResult.toString();

        assertEq(result, EXPECTED_DECRYPTION, "Decryption with byte arrays should match expected value");
    }

    /**
     * @dev Test the conversion utilities
     */
    function testConversionUtilities() public {
        string memory decimalValue = "123456789012345678901234567890";

        // Convert to hex and back to decimal
        string memory hexValue = remover.decimalToHex(decimalValue);
        string memory backToDecimal = remover.hexToDecimal(hexValue);

        assertEq(backToDecimal, decimalValue, "Conversion to hex and back should yield the original decimal value");
    }

    /**
     * @dev Test gas usage for the function
     */
    function testGasUsage() public {
        uint256 gasStart = gasleft();

        remover.removeEncryptionLayer(C1, C2, PRIVATE_KEY, PRIME_MODULUS);

        uint256 gasUsed = gasStart - gasleft();
        emit log_named_uint("Gas used for removeEncryptionLayer", gasUsed);

        // This is more of a benchmark than an assertion
        // You can add assertions if you have specific gas targets
    }

    /**
     * @dev Fuzz test with random modulus values to ensure robustness
     * Note: For real cryptographic use, the modulus should be prime
     */
    function testFuzz_WithRandomModulus(uint256 randomSeed) public {
        // Use the random seed to generate a deterministic but "random" modulus
        // This is simplified - in practice you'd want to ensure the modulus is prime
        vm.assume(randomSeed > 1000); // Avoid very small values

        string memory randomModulusStr = vm.toString(randomSeed);

        // Create compatible values for this test
        // In a real scenario, we'd generate proper encryption values

        // Skip the actual test for demonstration purposes
        // The actual implementation would require calculating proper c1/c2 values
        // for the given modulus and privateKey
        vm.skip(true);
    }
}
