// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { Test, console } from "forge-std/Test.sol";
import { CryptoUtils } from "../src/CryptoUtils.sol";
import "../src/BigNumbers/BigNumbers.sol";

contract StringComparator {
    function compareStrings(string memory _a, string memory _b) public pure returns (bool) {
        return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }
}

contract CryptoUtilsTest is Test {
    using BigNumbers for BigNumber;

    StringComparator public stringComparator;
    CryptoUtils public cryptoUtils;
    BigNumber public testMessage;
    uint256 public testPrivateKey;
    uint256 public testPublicKey;

    function setUp() public {
        cryptoUtils = new CryptoUtils();
        stringComparator = new StringComparator();
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

    function testVerifyDecryptCard256BitLen() public {
        bytes memory c1Bytes = hex"e3d0901804344fd3346b54f8bf7013690af3d274bb579ef1c53881a513a7b30b";
        bytes memory c2Bytes = hex"959ff3ad8fa3e605c223806961260e96539678db9c2a8201faeb6c5dc52aa0c7";

        bytes memory privatekey256Bytes =
            hex"62c1891979af2fef1fde0b30c79ade709e75289bc7c6bc6fd454a22fcee82da4";
        bytes memory c1InverseBytes =
            hex"485dba78f16903265d701d412292b2ed7bdb234403df26bf57e457135631ab43";

        BigNumber memory privatekey2048 = BigNumbers.init(privatekey256Bytes, false, 256);
        BigNumber memory c1Inverse = BigNumbers.init(c1InverseBytes, false, 256);
        CryptoUtils.EncryptedCard memory encryptedCard = CryptoUtils.EncryptedCard({
            c1: BigNumbers.init(c1Bytes, false, 256),
            c2: BigNumbers.init(c2Bytes, false, 256)
        });
        // 8D card
        bytes memory testMessageBytes =
            hex"0000000000000000000000000000000000000000000000000000000000003139";

        BigNumber memory decryptedMessage =
            cryptoUtils.verifyDecryptCard(encryptedCard, privatekey2048, c1Inverse);
        BigNumber memory testMessage1 = BigNumbers.init(testMessageBytes, false, 256);
        assertEq(BigNumbers.eq(decryptedMessage, testMessage1), true);
    }

    // (gas: 921,690)
    function testVerifyDecryptCardIntermediateDecryption() public {
        bytes memory c1Bytes =
            hex"766d4122af04919147ec81081b5b7c683108a3137f801bb7506810cab7dfb05940c8de77a82fb67a61854df04af75b1c7048d859790422d7a0b556f3ab03c27dcb6000b5bd434bd857295dd269b3c7f3cdc0584d6d28c3aa0b6f99dc3e6fcfc748fc6b4b67cf527b4253f2962af3423b90182cebc3af338e46895c485302d9334f26b5acedb2c7a7fca0e8f859775aa460afa5831dd34527d36ed1e51a3db3fd2c2c2e3ed788d9e603ed731c90db8f035a0a66092a43f78555377ba5204f60eaf9574db4b342ebc613a3ee0402d941b76ae3dd004431416d08e6348ecb1a44f645db547cefefa8132e17eed27c653dab4e6ded78242914f73030e7d210d31840";
        bytes memory c2Bytes =
            hex"054879e3f12a2d320df3c82267b0f0fb5d29d3d53ed89147b33becc2eaef111be169b355dae1dfad9386fbd61eed8c4111467a71ee72625386a7a4e4c485dbf7e575808c7f8dd26ca2eb52e5c37d73be489e153d2165d63f6d561b9baa4e60f60aa26e6ae1980e93aaa38618e1055bca6b0ecaffe504827b42db0148b38b15754242811f53499f07a8ee5af94d48d82e8b91979d02cb91b985d4a7eefe5a2d4f13eb0dfdeb7cc0a7dc40d5a96fac3408c319fb93408d897313224a9ce66e06e3267b410a3eb1d68a91ad206023885294788ef2be2cc5207e6e4b9e05a8da199404a81c50af2c88e2b5902498982294d78766b5f45f67e3fd45038a69e1c23684";

        bytes memory privatekey2048Bytes =
            hex"5a2fe5ae328ecce90980b144c638e3f202d7fc4640eff148930092d3258ca140e32fb8642fb21541ac2b23106f16f5e72669ebd6ea019996e0b6725149e55d12d73d7fd5b0c9cd6e1846826f8a1a81fcec964803f32e3f21a1b927b059c8c427c40e6359ce5af8f9883fad01050e6c63057e8123f381166645eff9fc70f92d1cc844fd5c5a2e44156ec64cda1a37e2a587a95048b7104f62439a6cef1895e1750517f361cc830d6a6a7a6e42e4b3978ca39bfe8f0ff8a16d1c59393f1b2625c2c782e9312187f6df79cba41d2be203b403310e931bd3c01bde2af395576b669f6fb2f5a2e283c3e95eb528c01f5a152ed7d3d276ece593f8521a65595c577848";
        bytes memory c1InverseBytes =
            hex"185fa24fdbed20d7359cdb0eea1812350be60e2cad84c27c01d4eb603c57501e26d879016c41b334b24be11af7a9b5e84a356897321f098b26f2c2878397f135466937f3cc1ba221d1ffecbaf5baf6926e373c76f4c94a62a149a1eb0e013233e1537b5b9b2d790b8bca90ce177fa12afe36f10abf16ff674faa0fc2d7dbc068929f827f69b3022d771fc538288f6fcf48f4261676e6e992e611ab51b4193695c1e503fd5df222124f1f8c35809962d47e877586d6d7c63b09c80a35610a930bf339e84d51aba2f2427ce69814671232318d94e8f60758de9ccde82bf973c1808f9d58b095155e266728eac3199111a541e76796ae7b4a33088c0b56cbd3af7f";
        bytes memory testMessageBytes =
            hex"7a4468d5a3087760f92208a2e37f245c289eb9342901b32e99fc0125117b99f555d21473fa1fb22120de774ba76bccdd43c168ce098f436bb0689135796086d547b875d7fae7e1150e5361f9acefe1b2914b904176e3453fa45a6e39f5ba0ae81be8299e5c87b11df2058e18d836da78a41851addba0c8f6228e0f87a52368c8e020cd8f568c2b62a7a393a4a459a10d84068b98f9774f9e773f5f03ddef5936a60b0cddbedc414248277979b45b7a7ac2c09ed1f3bab7a0d619bf5cc55860fb5d7506b0dcdfe502b5840274d60ce600a016d91112e424918717f34e5ab15efd0cfaaea4692dc71e8197578efc6bd57975c46c21b59c987136b089b0d45efaa2";
        BigNumber memory privatekey2048 = BigNumbers.init(privatekey2048Bytes, false);
        BigNumber memory c1Inverse = BigNumbers.init(c1InverseBytes, false);
        CryptoUtils.EncryptedCard memory encryptedCard = CryptoUtils.EncryptedCard({
            c1: BigNumbers.init(c1Bytes, false),
            c2: BigNumbers.init(c2Bytes, false)
        });

        // BigNumber memory decryptedMessage =
        //     cryptoUtils.verifyDecryptCard(encryptedCard, privatekey2048, c1Inverse);
        // BigNumber memory testMessage1 = BigNumbers.init(testMessageBytes, false);
        // assertEq(BigNumbers.eq(decryptedMessage, testMessage1), true);
    }

    // (gas: 902,290)
    function testVerifyDecryptCardFinalDecryptionCard25() public {
        bytes memory c1Bytes =
            hex"87b293c0d6cdb448af3df6c8511476cb5bed431d8059b5b7c21c3782ea9abff3d930568d6ef3f51d5dfc1f565320612e9fc0d1eb0a02ee81bc9298524905df845947a87452cd31b5e24d2bb58534e710b40ab3e5c85a98724b021d4ec01b32cf582cd021a2f115f14696200cebf32419249688e2a3e06cc4470188aac124e01c4b6b3298d414db061d81e20e9c0eac674fa2b8abd9a81b899ff4fec59f99d02f761fe460d2b8a39ddeba5dce82b014155a909fb92af908ae2763c7e7e9f0a1e52e9db57a1da3bca7faa1b2801568034fe8d233173f4ef8461c63f81704155d810585faaaabdebebd01b07f3fe31ba738253e5d846e5421bfd04e4aac68bcc16e";
        bytes memory c2Bytes =
            hex"7a4468d5a3087760f92208a2e37f245c289eb9342901b32e99fc0125117b99f555d21473fa1fb22120de774ba76bccdd43c168ce098f436bb0689135796086d547b875d7fae7e1150e5361f9acefe1b2914b904176e3453fa45a6e39f5ba0ae81be8299e5c87b11df2058e18d836da78a41851addba0c8f6228e0f87a52368c8e020cd8f568c2b62a7a393a4a459a10d84068b98f9774f9e773f5f03ddef5936a60b0cddbedc414248277979b45b7a7ac2c09ed1f3bab7a0d619bf5cc55860fb5d7506b0dcdfe502b5840274d60ce600a016d91112e424918717f34e5ab15efd0cfaaea4692dc71e8197578efc6bd57975c46c21b59c987136b089b0d45efaa2";

        bytes memory privatekey2048Bytes =
            hex"83d8f20805187383cc6e9ac2be472f4f05db19f95fe87ca8d51acd2c93f2d1cd4003253a49479d016acd517c02fc156b8a4448ff75b7c751de87c17877933795b719a0af4757b912cb87e1981ab7b6b66ebecf6144df99c65e8232b08ac906e52ac78b4a412edc97370f11500851857961eef679002cdf7c30ccb2e057166f45dd6d8c95c48f44f7cf716211e745412452fb6045396e0a6df879b768ddfd349090cf3e83d660be2738bbf9a876d38e90445c265080dd80ef966a92b0708f073f05003b9a9deb29266d95e73ea2d9d3517935ad38ce5808f047f57acf45e9032513ea7966f933110c86dbcba56772e6bb5b3b16c9e2c418da09ce9d035510d2b0";
        bytes memory c1InverseBytes =
            hex"66a21e57ac9681706a9a4e581f24fff0158b7b84176cbd4fb01e382de50d88423d7bf70679b6bb3436a8c458763c543a60d5db575be933884a73a32b21b372006a7e65ea1b8d8ea3ba9d6ce48e89bd6bc2aaa20e03fe6cccd84bc5740e9335a89f290077055a4feed4090cc8e63fc83952ca842974f6a2d2375384fa4997b10584009ca1c245838cbe66d52bf8151bd5b3a7ceedea6b316737ee14fbdaade98a917349ff0ec21e6a7dd44db52832306868803d5f382289fae7e43012f526afef45307d6aff5d4cd81e62a91a9480a11069ce9b81a5d58340a942b41d3d07969355de9310f61df0eb4eff739e5117090831fb027b14fb305353aa97a2a4e24825";
        // string "25" in hex
        bytes memory expectedMessageBytes = hex"3235";
        BigNumber memory privatekey2048 = BigNumbers.init(privatekey2048Bytes, false);
        BigNumber memory c1Inverse = BigNumbers.init(c1InverseBytes, false);
        CryptoUtils.EncryptedCard memory encryptedCard = CryptoUtils.EncryptedCard({
            c1: BigNumbers.init(c1Bytes, false),
            c2: BigNumbers.init(c2Bytes, false)
        });

        // BigNumber memory decryptedMessage =
        //     cryptoUtils.verifyDecryptCard(encryptedCard, privatekey2048, c1Inverse);
        // BigNumber memory testMessage2 = BigNumbers.init(expectedMessageBytes, false);
        // assertEq(BigNumbers.eq(decryptedMessage, testMessage2), true);

        // Convert BigNumber to string and trim leading zeros for comparison
        // string memory expectedCardString = string(expectedMessageBytes);

        // // possibly put this in decryptCard(), but don't want extra gas cost for all intermediate decryptions
        // // Extract the actual value from BigNumber, ignoring leading zeros
        // bytes memory decryptedBytes = decryptedMessage.val;
        // uint256 startIndex = 0;

        // // Find the first non-zero byte
        // for (uint256 i = 0; i < decryptedBytes.length; i++) {
        //     if (decryptedBytes[i] != 0) {
        //         startIndex = i;
        //         break;
        //     }
        // }

        // // Create a new bytes array with only the significant bytes
        // bytes memory trimmedBytes = new bytes(decryptedBytes.length - startIndex);
        // for (uint256 i = 0; i < trimmedBytes.length; i++) {
        //     trimmedBytes[i] = decryptedBytes[i + startIndex];
        // }

        // string memory decryptedCardString = string(trimmedBytes);

        // // Compare the strings
        // assertEq(stringComparator.compareStrings("25", decryptedCardString), true);
        // assertEq(stringComparator.compareStrings(expectedCardString, decryptedCardString), true);
        // assertEq(keccak256(bytes(expectedCardString)), keccak256(bytes(decryptedCardString)));
    }

    // (gas: 922,347)
    function testVerifyDecryptCardFinalDecryptionCard0() public {
        bytes memory c1Bytes =
            hex"0d3ae90d2777bb50bf1f508525b3d8017e259f3dfcc415b6c983ab7a4086cd6d64f227f9f5bc3038a36c01cb1b2af9b66472269c0a14d00beaa8d93cee3ccc0fa54bd3305f6b0a0296867f110f18a364e6762834e2ee2438ca2702d1aa7560c270c42c7b7d5a13779f8b141e73c3e100fe56d91e1ebc8f34d44669ea0f2899f47de2f31bb491b48f8f2ec4e067781c32c761b941527c61cefa868f2738bb7604cedf7978605d9907470db3cf961bdb096a9add335da0ab6642daa77dad88a482c87c4232d0028b99fab763e2bb48c69c2fc52fda9eae81fe6d8a5502556c0acbf31036bf9d1f71fcaf5773d40759f4a7a8d3f9245fd5d4a7febc000e03be93bf";
        bytes memory c2Bytes =
            hex"688e529dd9d22d18538d18e321f034f1a61afaaea637e8083edac3a7c09b3b09d4a507b1f631350b5a4cd9a557a7c1346eb138a06a1f3c855ec489c918010eedf1fd2674d4a20cdb96f245e4a165003e12d57cdad095442b594866efa488c71abfaf3b268a3ac70ee28612f8b45033b61eb3ea62c335bda17797ee34817d88c46883c11b53768b3a52dbc26b0ce079718d94d8701944f9aa3d80cc82074b6f418e66bdfe1d8d31a8df2acf1589b6c68548057ec127b6fb1be74a936239542024e589fbe32b3102b6935d3dd63b4615bd96c5ff094b9f8a31e4999360815577decdbdf5c4bf7234cb0539189623e49af840b70a7a2b531e389c723390e90c25a8";

        bytes memory privatekey2048Bytes =
            hex"0a960d7ca46ec4a7a60f9f58473b5aa84a921ee4601ab36d2bdea1df2ede12a1ab11a06139a3592980237baf24c8a974b1af5f253ba183b329e2952b250cd165d6fa832339aa9055d751eb7c02b683f20caa28d97151789e93e6ed7b027e00ad1768ba0d7ec9faaeea0ba7f60404c40200f89f63dfcbff12591f0db09f5cded698fe81aa05ade335ad9d4f1c797e57344457cd7b863c6f9cc2ae339f3755fcfdfc264e4e926a79b55e564adb68fd2d6eff776296f58dae5ac35fe46be58c9167b2061a6954b04f04b23bbc27ea68fa3eaa15534306c40d4b32d473cda9f143172a761f99020d3d23ff0eb294ebc63af224e645ce0a987cd0e110d39f1a4f8458";
        bytes memory c1InverseBytes =
            hex"cb01e43b531107d578455de8363c18f8eaafae333485b0e5c3377afed8b21558bd6ed4bb4f0a827d455d6e72ea48b5fc55639453f517b1809d7f98cd0c0fa4f5e1815094c34708cd2f805caf76df96e1c90e761ccd6c25d0acb67e56c2d36e3432b8ccd6c2848168bc36d028bc9ad2eacf51dd3ce0039415c0daa84ceebc9fcdca73d7e8fc97083103f3605b3253fe6f1f7ea7d70d47d1bff61fc46b8a4f6bbdd44be17c6e858ce63ba139a310eb335c866f722b0e0318ca0b3ba294cdeb04f47625b8038a1306285ec9c4626ac1f55bb22ec1619606f9c53b40d6c7317ee210dbe50227a6210b36ce00c44e7214fcc2130f0ca2703e6312a252db1c63174e5b";
        // string "0" in hex
        bytes memory expectedMessageBytes = hex"30";
        BigNumber memory privatekey2048 = BigNumbers.init(privatekey2048Bytes, false);
        BigNumber memory c1Inverse = BigNumbers.init(c1InverseBytes, false);
        CryptoUtils.EncryptedCard memory encryptedCard = CryptoUtils.EncryptedCard({
            c1: BigNumbers.init(c1Bytes, false),
            c2: BigNumbers.init(c2Bytes, false)
        });

        // BigNumber memory decryptedMessage =
        //     cryptoUtils.verifyDecryptCard(encryptedCard, privatekey2048, c1Inverse);
        // BigNumber memory testMessage3 = BigNumbers.init(expectedMessageBytes, false);
        // assertEq(BigNumbers.eq(decryptedMessage, testMessage3), true);

        // Convert BigNumber to string and trim leading zeros for comparison
        // string memory expectedCardString = string(expectedMessageBytes);

        // // possibly put this in decryptCard(), but don't want extra gas cost for all intermediate decryptions
        // // Extract the actual value from BigNumber, ignoring leading zeros
        // bytes memory decryptedBytes = decryptedMessage.val;
        // uint256 startIndex = 0;

        // // Find the first non-zero byte
        // for (uint256 i = 0; i < decryptedBytes.length; i++) {
        //     if (decryptedBytes[i] != 0) {
        //         startIndex = i;
        //         break;
        //     }
        // }

        // // Create a new bytes array with only the significant bytes
        // bytes memory trimmedBytes = new bytes(decryptedBytes.length - startIndex);
        // for (uint256 i = 0; i < trimmedBytes.length; i++) {
        //     trimmedBytes[i] = decryptedBytes[i + startIndex];
        // }

        // string memory decryptedCardString = string(trimmedBytes);
        // // string memory = string(decryptedMessage.val)
        // // Compare the strings
        // assertEq(stringComparator.compareStrings("0", decryptedCardString), true);
        // assertEq(stringComparator.compareStrings(expectedCardString, decryptedCardString), true);
        // assertEq(keccak256(bytes(expectedCardString)), keccak256(bytes(decryptedCardString)));
        // assertEq(keccak256(bytes("0")), keccak256(bytes(decryptedCardString)));
    }

    // function testModInverse() public view {
    //     // Test with small numbers for verification
    //     BigNumber memory a = BigNumbers.init(3, false);
    //     BigNumber memory m = BigNumbers.init(11, false);

    //     console.log("Testing modInverse with a =");
    //     console.logBytes(a.val);
    //     console.log("m =");
    //     console.logBytes(m.val);

    //     BigNumber memory inverse = cryptoUtils.modInverse(a, m);
    //     console.log("Inverse result =");
    //     console.logBytes(inverse.val);

    //     // Verify: (a * inverse) mod m should be 1
    //     BigNumber memory product = BigNumbers.modmul(a, inverse, m);
    //     console.log("Product (should be 1) =");
    //     console.logBytes(product.val);
    //     assertTrue(BigNumbers.eq(product, BigNumbers.init(1, false)));
    // }

    // function testElGamalEncryptionDecryption() public view {
    //     console.log("\nTesting ElGamal encryption/decryption");
    //     console.log("Original message:");
    //     console.logBytes(testMessage.val);

    //     // Encrypt the message
    //     CryptoUtils.EncryptedCard memory encryptedCard = cryptoUtils.encryptMessageBigint(
    //         testMessage,
    //         testPublicKey,
    //         50 // Use random r
    //     );
    //     console.log("Encrypted card c1:");
    //     console.logBytes(encryptedCard.c1.val);
    //     console.log("Encrypted card c2:");
    //     console.logBytes(encryptedCard.c2.val);

    //     // Decrypt the message
    //     BigNumber memory decryptedMessage = cryptoUtils.decryptCard(encryptedCard, testPrivateKey);
    //     console.log("Decrypted message:");
    //     console.logBytes(decryptedMessage.val);

    //     // Verify the decrypted message matches the original
    //     assertTrue(BigNumbers.eq(decryptedMessage, testMessage));
    // }

    // function testElGamalEncryptionDecryptionWithFixedR() public view {
    //     console.log("\nTesting ElGamal encryption/decryption with fixed R");
    //     console.log("Original message:");
    //     console.logBytes(testMessage.val);

    //     // Use a fixed random value for deterministic testing
    //     uint256 fixedR = 54321;
    //     console.log("Using fixed R value:", fixedR);

    //     // Encrypt the message
    //     CryptoUtils.EncryptedCard memory encryptedCard =
    //         cryptoUtils.encryptMessageBigint(testMessage, testPublicKey, fixedR);
    //     console.log("Encrypted card c1:");
    //     console.logBytes(encryptedCard.c1.val);
    //     console.log("Encrypted card c2:");
    //     console.logBytes(encryptedCard.c2.val);

    //     // Decrypt the message
    //     BigNumber memory decryptedMessage = cryptoUtils.decryptCard(encryptedCard, testPrivateKey);
    //     console.log("Decrypted message:");
    //     console.logBytes(decryptedMessage.val);

    //     // Verify the decrypted message matches the original
    //     assertTrue(BigNumbers.eq(decryptedMessage, testMessage));
    // }

    // function testElGamalEncryptionDecryptionWithLargeNumbers() public view {
    //     console.log("\nTesting ElGamal encryption/decryption with large numbers");

    //     // Test with a larger message
    //     bytes memory largeMessageBytes = new bytes(256); // 2048 bits
    //     for (uint256 i = 0; i < 256; i++) {
    //         largeMessageBytes[i] = bytes1(uint256(i % 256));
    //     }
    //     BigNumber memory largeMessage = BigNumbers.init(largeMessageBytes, false);
    //     console.log("Large message:");
    //     console.logBytes(largeMessage.val);

    //     // Encrypt the message
    //     CryptoUtils.EncryptedCard memory encryptedCard = cryptoUtils.encryptMessageBigint(
    //         largeMessage,
    //         testPublicKey,
    //         0 // Use random r
    //     );
    //     console.log("Encrypted card c1:");
    //     console.logBytes(encryptedCard.c1.val);
    //     console.log("Encrypted card c2:");
    //     console.logBytes(encryptedCard.c2.val);

    //     // Decrypt the message
    //     BigNumber memory decryptedMessage = cryptoUtils.decryptCard(encryptedCard, testPrivateKey);
    //     console.log("Decrypted message:");
    //     console.logBytes(decryptedMessage.val);

    //     // Verify the decrypted message matches the original
    //     assertTrue(BigNumbers.eq(decryptedMessage, largeMessage));
    // }

    // function testElGamalEncryptionDecryptionWithZeroMessage() public view {
    //     console.log("\nTesting ElGamal encryption/decryption with zero message");

    //     // Test with zero message
    //     BigNumber memory zeroMessage = BigNumbers.init(0, false);
    //     console.log("Zero message:");
    //     console.logBytes(zeroMessage.val);

    //     // Encrypt the message
    //     CryptoUtils.EncryptedCard memory encryptedCard = cryptoUtils.encryptMessageBigint(
    //         zeroMessage,
    //         testPublicKey,
    //         0 // Use random r
    //     );
    //     console.log("Encrypted card c1:");
    //     console.logBytes(encryptedCard.c1.val);
    //     console.log("Encrypted card c2:");
    //     console.logBytes(encryptedCard.c2.val);

    //     // Decrypt the message
    //     BigNumber memory decryptedMessage = cryptoUtils.decryptCard(encryptedCard, testPrivateKey);
    //     console.log("Decrypted message:");
    //     console.logBytes(decryptedMessage.val);

    //     // Verify the decrypted message matches the original
    //     assertTrue(BigNumbers.eq(decryptedMessage, zeroMessage));
    // }

    // function testElGamalEncryptionDecryptionWithNegativeMessage() public view {
    //     console.log("\nTesting ElGamal encryption/decryption with negative message");

    //     // Test with negative message
    //     BigNumber memory negativeMessage = BigNumbers.init(42, true);
    //     console.log("Negative message:");
    //     console.logBytes(negativeMessage.val);

    //     // Encrypt the message
    //     CryptoUtils.EncryptedCard memory encryptedCard = cryptoUtils.encryptMessageBigint(
    //         negativeMessage,
    //         testPublicKey,
    //         0 // Use random r
    //     );
    //     console.log("Encrypted card c1:");
    //     console.logBytes(encryptedCard.c1.val);
    //     console.log("Encrypted card c2:");
    //     console.logBytes(encryptedCard.c2.val);

    //     // Decrypt the message
    //     BigNumber memory decryptedMessage = cryptoUtils.decryptCard(encryptedCard, testPrivateKey);
    //     console.log("Decrypted message:");
    //     console.logBytes(decryptedMessage.val);

    //     // Verify the decrypted message matches the original
    //     assertTrue(BigNumbers.eq(decryptedMessage, negativeMessage));
    // }
}
