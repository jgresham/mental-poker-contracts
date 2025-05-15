// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { Test, console } from "forge-std/Test.sol";
import "../src/BigNumbers/BigNumbers.sol";

bytes constant P_2048 =
    hex"FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B1FE649286651ECE45B3DC2007CB8A163BF0598DA48361C55D39A69163FA8FD24CF5F83655D23DCA3AD961C62F356208552BB9ED529077096966D670C354E4ABC9804F1746C08CA18217C32905E462E36CE3BE39E772C180E86039B2783A2EC07A28FB5C55DF06F4C52C9DE2BCBF695581718399549CCEA956AE515D2261898FA051015728E5A8AACAA68FFFFFFFFFFFFFFFF";

contract BigNumbersTest is Test {
    using BigNumbers for BigNumber;

    function testDiv() public view {
        BigNumber memory a = BigNumbers.init(100, false);
        BigNumber memory b = BigNumbers.init(10, false);
        BigNumber memory result = a.div(b);
        // Convert BigNumber to integer for comparison
        bytes memory resultVal = result.val;
        uint256 resultInt;
        assembly {
            resultInt := mload(add(resultVal, 0x20))
        }
        assertEq(resultInt, 10);
    }

    function testDivByZero() public {
        BigNumber memory a = BigNumbers.init(100, false);
        BigNumber memory b = BigNumbers.init(0, false);
        vm.expectRevert("Division by zero");
        a.div(b);
    }

    function testModInverse() public view {
        BigNumber memory a = BigNumbers.init(3, false);
        BigNumber memory m = BigNumbers.init(11, false);
        BigNumber memory result = a.modInverse(m);
        // Convert BigNumber to integer for comparison
        bytes memory resultVal = result.val;
        uint256 resultInt;
        assembly {
            resultInt := mload(add(resultVal, 0x20))
        }
        assertEq(resultInt, 4);
    }

    function testModInverseByZero() public {
        BigNumber memory a = BigNumbers.init(3, false);
        BigNumber memory m = BigNumbers.init(0, false);
        vm.expectRevert("Modulus must be positive");
        a.modInverse(m);
    }

    function testLargeModInverseEqualAandM() public view {
        BigNumber memory a = BigNumbers.init(1000000000000000000, false);
        BigNumber memory m = BigNumbers.init(1000000000000000000, false);
        BigNumber memory result = a.modInverse(m);
        // Convert BigNumber to integer for comparison
        bytes memory resultVal = result.val;
        uint256 resultInt;
        assembly {
            resultInt := mload(add(resultVal, 0x20))
        }
        assertEq(resultInt, 0);
    }

    // too much gas
    // function testLargeModInverseEqualAandMSetBitLen256() public view {
    //     BigNumber memory a = BigNumber({ val: hex"1000", neg: false, bitlen: 256 });
    //     BigNumber memory m = BigNumber({ val: hex"1000", neg: false, bitlen: 256 });
    //     BigNumber memory result = a.modInverse(m);
    //     // Convert BigNumber to integer for comparison
    //     bytes memory resultVal = result.val;
    //     uint256 resultInt;
    //     assembly {
    //         resultInt := mload(add(resultVal, 0x20))
    //     }
    //     assertEq(resultInt, 0);
    // }

    function testLargeModInverseNotEqualAandM() public view {
        BigNumber memory a = BigNumbers.init(1000000000000000000, false);
        BigNumber memory m = BigNumbers.init(1000000000000000001, false);
        BigNumber memory result = a.modInverse(m);
        // Convert BigNumber to integer for comparison
        bytes memory resultVal = result.val;
        uint256 resultInt;
        assembly {
            resultInt := mload(add(resultVal, 0x20))
        }
        assertEq(resultInt, 1000000000000000000);
    }

    // (gas: 1,056,944,259)
    // function testLargeModInverseLargePrimeM() public view {
    //     bytes memory aBytes =
    //         hex"da7e4d189bf12df6315dd6521f0813e8e04455b91bcd528e0802b0cfe1ce07a683bbc2c7da6db2e45b349e9dab3168db736110f1b7a8b98a0b9da8b85f681bde2981aab14f52deca8004b5d299c44e2824556e8ff312d7ece936300ddcbb04ee042e15fe7d68c7f5e43bff43c3367520b459c5cc655a2bc38bde20b27f6ea6914cbfcc91ffaf3e48ca34eb51f1d607d8240c8878a75759b531b3be6b8fd05040215f0dc86529cf6474d45ce8c5c739711c43920e6c149169753dda00dc2fabf0b1636f0534a11b75be6126965a6283a2859544caae3513a604f2d84cf3e698b46e6bc4fce45005e090481220aecd8678a5e1291afe971a5ba09fb7a79c4e5de1";

    //     BigNumber memory a = BigNumbers.init(aBytes, false);
    //     BigNumber memory m = BigNumbers.init(P_2048, false);
    //     BigNumber memory result = BigNumbers.modInverse(a, m);
    //     bytes memory resultVal =
    //         hex"736e39be7447934f7a50d7702d0a3325d42d460dd6628803d614e79bac1def28ee2b5e11afc734107cf50e7c6bd78163288b2b26efbbc2891a5c2e8e418b3a491e7e88f26e2571b312137511f802b8943162e44d2f97ecc919ef4498e13f9dd0cd1d58f24a5367160a2c003a839d54cf8dd5b490a73f65b7d13a1dde6a4ada1f987f9c6a0f5eca1f3e621b1f919456c0eee767f6aa2b03e1d1a47a2075929aed9ccda5ac1a8568e2821ea1b423ea116a6c20d53ccc8bddd6c924ae2c17bddaf86de0243e2c75645d98e805174976700d031688a09c84e598447127805c9a63da87aa97c71c2854d784804ec1c63fc82299c671cb50fe6ccdcb0f03f0c19dac98";
    //     assertEq(result.val, resultVal);
    // }

    // (gas: 72464)
    function testLargeModInverseVerifyLargePrimeM() public view {
        bytes memory aBytes =
            hex"da7e4d189bf12df6315dd6521f0813e8e04455b91bcd528e0802b0cfe1ce07a683bbc2c7da6db2e45b349e9dab3168db736110f1b7a8b98a0b9da8b85f681bde2981aab14f52deca8004b5d299c44e2824556e8ff312d7ece936300ddcbb04ee042e15fe7d68c7f5e43bff43c3367520b459c5cc655a2bc38bde20b27f6ea6914cbfcc91ffaf3e48ca34eb51f1d607d8240c8878a75759b531b3be6b8fd05040215f0dc86529cf6474d45ce8c5c739711c43920e6c149169753dda00dc2fabf0b1636f0534a11b75be6126965a6283a2859544caae3513a604f2d84cf3e698b46e6bc4fce45005e090481220aecd8678a5e1291afe971a5ba09fb7a79c4e5de1";

        BigNumber memory a = BigNumbers.init(aBytes, false);
        BigNumber memory m = BigNumbers.init(P_2048, false);
        bytes memory resultVal =
            hex"736e39be7447934f7a50d7702d0a3325d42d460dd6628803d614e79bac1def28ee2b5e11afc734107cf50e7c6bd78163288b2b26efbbc2891a5c2e8e418b3a491e7e88f26e2571b312137511f802b8943162e44d2f97ecc919ef4498e13f9dd0cd1d58f24a5367160a2c003a839d54cf8dd5b490a73f65b7d13a1dde6a4ada1f987f9c6a0f5eca1f3e621b1f919456c0eee767f6aa2b03e1d1a47a2075929aed9ccda5ac1a8568e2821ea1b423ea116a6c20d53ccc8bddd6c924ae2c17bddaf86de0243e2c75645d98e805174976700d031688a09c84e598447127805c9a63da87aa97c71c2854d784804ec1c63fc82299c671cb50fe6ccdcb0f03f0c19dac98";
        BigNumber memory resultModInv = BigNumbers.init(resultVal, false);
        bool verifyResult = BigNumbers.modinvVerify(a, m, resultModInv);
        assertEq(verifyResult, true);
    }

    // function testVerifyDivision2048BitNumbers() public view {
    //     bytes memory aBytes = hex"32317006071311007300338913926423828248817941241140239112842009751400741706634354222619689417363569347117901737909704191754605873209195028853758986185622153212175412514901774520270235796078236248884246189477587641105928646099411723245426622522193230540919037680524235519125679715870117001058055877651038861847280257976054903569732561526167081339361799541336476559160368317896729073178384589680639671900977202194168647225871031411336429319536193471636533209717077448227988588565369208645296636077250268955505928362751121174096972998068410554359584868740087375508269414652352206410222922153388525839157650995334181027838";
    //     BigNumber memory a = BigNumbers.init(1000000000000000000, false);
    //     BigNumber memory b = BigNumbers.init(10, false);
    //     BigNumber memory result = a.v(b);
    //     bool verifyResult = BigNumbers.divVerify(a, b, result);
    //     assertEq(verifyResult, true);
    // }

    function testLargeModInverseVerify10e10Nums() public view {
        // bytes memory aBytes = 3840928903
        bytes memory aBytes = hex"E4EFEC87";
        // bytes memory mBytes = 2342343;
        bytes memory mBytes = hex"23BDC7";
        // 2154565
        bytes memory resultVal = hex"20E045";
        BigNumber memory a = BigNumbers.init(aBytes, false);
        BigNumber memory m = BigNumbers.init(mBytes, false);
        BigNumber memory resultModInv = BigNumbers.init(resultVal, false);
        bool verifyResult = BigNumbers.modinvVerify(a, m, resultModInv);
        assertEq(verifyResult, true);
    }
}
