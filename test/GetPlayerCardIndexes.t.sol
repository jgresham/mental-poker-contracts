// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import "../src/TexasHoldemRoom.sol";
import "../src/PokerHandEvaluatorv2.sol";
import "../src/BigNumbers/BigNumbers.sol";
import "../src/CryptoUtils.sol";
import "../src/DeckHandler.sol";

contract GetPlayerCardIndexesTest is Test {
    using BigNumbers for BigNumber;

    TexasHoldemRoom public room;
    address public player1;
    address public player2;
    address public player3;
    uint256 constant SMALL_BLIND = 10;
    uint256 constant INITIAL_BALANCE = 1000;
    CryptoUtils public cryptoUtils;
    PokerHandEvaluatorv2 public handEvaluator;
    DeckHandler public deckHandler;
    BigNumber publicKey1;
    BigNumber privateKey1;
    BigNumber c1p1;
    BigNumber r1;
    BigNumber c1Inverse1;
    bytes[] encryptedDeck1bytes;

    bytes[] public args;

    function setUp() public {
        args = new bytes[](5);
        args[0] =
            hex"9eb6f0b80fa24b9747c6a64e78df2066709e07b12118e7564d599ed79eb51c531b4f793502f8f7ba2c0eb5c54545a16c93b2c040eb56ff6994bef2da10eb0d1c1829c2766bb99de877c1af413ed9d4eeab05e4047d99ccb4addb8870c2d2c5c63d69529820335116fb2eafe59a29f14f7f75680a1a4bb7d5348a9bde85976f2555b32fd93ca9595a863ff73b73dddb530b7f909f8b5372fb7ba438554b221cd53440141e7dc77c843b202ceca57828546aadb94ed86cfa9115452f76dde43b5b404673c70180d6cefa5a0e52cbba4292460abc2b405ea997b2e0d6080561a97f6351042d8ca3535d892501719a4f0bda7973d1595b760b28cbf9709f73c1222b";
        args[1] =
            hex"029a372c8db0496b5526a8fcb474e94c86a1d23983b2b1e5cb789f6915972414fedf408f8eb577dfe2155d78c2f6e37dd87a4450ff0e2107e3335dee57829f5d104e75fd1db53545f4b866d551c369c9d0c76837ad3436ae11eade08eacc6fea23a9d0762c518ae0da3dd5610580665076304d6eb262301ef3060ed43b117a181ee5f28c1494125c96b5e75c6ae0a99fa4e696ef6494b160acfe9c2edede08f71a13d9bdda0a137d1b2efe6e79cb201d3bbe522e12a9aa72c8a4dd63884da56392f791d4919fb44e860d1899f01eaa3bd4ed13b42f409a72c5f51e94f923cbd3c20d049f455745310d03689dc962e48507b68e3ba95dffb80325aa5b8f01770c";
        args[2] =
            hex"0c3367d686a8518fa75f62725fc46fc2d103fe6a6d43104ce754e7e76d4793059b8582393f50e44eb68bbcb6037b546fa3a1ff769901d0886fe4cb07327def4f319531be1697e9f86e648f24f5c54674f1087c7d1ff7b220336fa1bd92a5b3de8b7c3fdfbd60461f218ff35380dc77c42c966ed4982dcdadbaf6e78592140ea8ff463a3e0d9f1656f55925792cfc8c946b7b9549c4cf7ecfa8a432cf763e1642cdc31e3f136ed472678df963a89d169ac39ba1ea408e03496ad2b41911faca7a1aa9094d1a1ab8dff9b2b20c6ebb67e89ac542850d9d49a272fbf27804096a8b230110bd2f0059aea8b5b401cc25b1e8e9afd48cacdce9a330c63ea4ef4c3240";
        args[3] =
            hex"55f695dc9006b8651fcef34c6cd6545852516485bfd3f2d548d79ad4ada1924fb0c957d25bf5acbf314c024472278b5f45703a850ad0d261a427ea9fa76e9f2d6c9a16827e64eb9a7223399a67914bdd2fb5db9a9e37272d7744c9703848a728d3cb2ef43a1f86c7bd4095fa45d3d14b30488adecb11ebcb31c1a8df87f9fe12978eeb690e14b6ce37d5b87abac04dbccaca31088c7b6fa842333451f8183fa5c1353f9d2db357f08b287d21d94e62e9e5b58de880d2efebc94bcc7346bf94551303a1e719a04493111e8873f4f279e8f592a89900c63efb531b17c8909244e20c6e751d5eb77b0be09868a6991ab5f1e2df70dab9dd0342a8b98208d170eb21";
        args[4] =
            hex"1c96f75802e2e6def1a70c0761bbdb6bed5d5f8061947cde6f181a59a32b3800671234ec6e01b30a13dcfb41f13b89f7a70c96a771bbeaf47125e344df45c2a7be3f5c264b2dbaa04cd43d13f1f03ffc5be54cca4502810e9f9db97e23a788d01189366b3a2dd4ba427c2ce076ffd5af9f890387a378f5602a17e6010328e83447731b3203c12341456a902225f3ad01f42834311bda7c2c47062289287b8a4cc0e0441b923aa6ece4a069879c395eaca28c20934ef745a890410ef94c054b2198ec5af94ba12b133c7cc197e42ca8d6347ed632ee64a7e6f249f9b02b473e942e43382bcf1b63ffede8d2c924a9712619d7a5ab75f19a678486315c4ba04709";

        player1 = makeAddr("player1");
        player2 = makeAddr("player2");
        player3 = makeAddr("player3");
        cryptoUtils = new CryptoUtils();
        handEvaluator = new PokerHandEvaluatorv2();
        room = new TexasHoldemRoom(address(cryptoUtils), SMALL_BLIND, false);
        deckHandler = new DeckHandler(address(room), address(cryptoUtils), address(handEvaluator));
        room.setDeckHandler(address(deckHandler));
        vm.startPrank(player1);
        room.joinGame();
        vm.stopPrank();
        // Test joining with player2
        vm.startPrank(player2);
        room.joinGame();
        vm.stopPrank();
    }

    function test_getPlayersCards() public {
        uint256[2] memory playerCardIndexes = room.getPlayersCardIndexes(0);
        console.log("playerCardIndexes for playerIndex 0");
        uint256 playerCardIndex1 = playerCardIndexes[0];
        uint256 playerCardIndex2 = playerCardIndexes[1];
        assertEq(playerCardIndex1, 0);
        assertEq(playerCardIndex2, 2);

        playerCardIndexes = room.getPlayersCardIndexes(1);
        console.log("playerCardIndexes for playerIndex 1");
        playerCardIndex1 = playerCardIndexes[0];
        playerCardIndex2 = playerCardIndexes[1];
        assertEq(playerCardIndex1, 1);
        assertEq(playerCardIndex2, 3);
    }

    // was used to test the revealMyCards function, now outdated. move to shuffle tests
    // function test_submitRevealCards() public {
    //     bytes memory c1Bytes =
    //         hex"9eb6f0b80fa24b9747c6a64e78df2066709e07b12118e7564d599ed79eb51c531b4f793502f8f7ba2c0eb5c54545a16c93b2c040eb56ff6994bef2da10eb0d1c1829c2766bb99de877c1af413ed9d4eeab05e4047d99ccb4addb8870c2d2c5c63d69529820335116fb2eafe59a29f14f7f75680a1a4bb7d5348a9bde85976f2555b32fd93ca9595a863ff73b73dddb530b7f909f8b5372fb7ba438554b221cd53440141e7dc77c843b202ceca57828546aadb94ed86cfa9115452f76dde43b5b404673c70180d6cefa5a0e52cbba4292460abc2b405ea997b2e0d6080561a97f6351042d8ca3535d892501719a4f0bda7973d1595b760b28cbf9709f73c1222b";
    //     // bytes memory c2Bytes1 =
    //     // hex"029a372c8db0496b5526a8fcb474e94c86a1d23983b2b1e5cb789f6915972414fedf408f8eb577dfe2155d78c2f6e37dd87a4450ff0e2107e3335dee57829f5d104e75fd1db53545f4b866d551c369c9d0c76837ad3436ae11eade08eacc6fea23a9d0762c518ae0da3dd5610580665076304d6eb262301ef3060ed43b117a181ee5f28c1494125c96b5e75c6ae0a99fa4e696ef6494b160acfe9c2edede08f71a13d9bdda0a137d1b2efe6e79cb201d3bbe522e12a9aa72c8a4dd63884da56392f791d4919fb44e860d1899f01eaa3bd4ed13b42f409a72c5f51e94f923cbd3c20d049f455745310d03689dc962e48507b68e3ba95dffb80325aa5b8f01770c";
    //     bytes memory c2Bytes2 =
    //         hex"0c3367d686a8518fa75f62725fc46fc2d103fe6a6d43104ce754e7e76d4793059b8582393f50e44eb68bbcb6037b546fa3a1ff769901d0886fe4cb07327def4f319531be1697e9f86e648f24f5c54674f1087c7d1ff7b220336fa1bd92a5b3de8b7c3fdfbd60461f218ff35380dc77c42c966ed4982dcdadbaf6e78592140ea8ff463a3e0d9f1656f55925792cfc8c946b7b9549c4cf7ecfa8a432cf763e1642cdc31e3f136ed472678df963a89d169ac39ba1ea408e03496ad2b41911faca7a1aa9094d1a1ab8dff9b2b20c6ebb67e89ac542850d9d49a272fbf27804096a8b230110bd2f0059aea8b5b401cc25b1e8e9afd48cacdce9a330c63ea4ef4c3240";
    //     bytes memory privatekey2048Bytes =
    //         hex"55f695dc9006b8651fcef34c6cd6545852516485bfd3f2d548d79ad4ada1924fb0c957d25bf5acbf314c024472278b5f45703a850ad0d261a427ea9fa76e9f2d6c9a16827e64eb9a7223399a67914bdd2fb5db9a9e37272d7744c9703848a728d3cb2ef43a1f86c7bd4095fa45d3d14b30488adecb11ebcb31c1a8df87f9fe12978eeb690e14b6ce37d5b87abac04dbccaca31088c7b6fa842333451f8183fa5c1353f9d2db357f08b287d21d94e62e9e5b58de880d2efebc94bcc7346bf94551303a1e719a04493111e8873f4f279e8f592a89900c63efb531b17c8909244e20c6e751d5eb77b0be09868a6991ab5f1e2df70dab9dd0342a8b98208d170eb21";
    //     bytes memory c1InverseBytes =
    //         hex"1c96f75802e2e6def1a70c0761bbdb6bed5d5f8061947cde6f181a59a32b3800671234ec6e01b30a13dcfb41f13b89f7a70c96a771bbeaf47125e344df45c2a7be3f5c264b2dbaa04cd43d13f1f03ffc5be54cca4502810e9f9db97e23a788d01189366b3a2dd4ba427c2ce076ffd5af9f890387a378f5602a17e6010328e83447731b3203c12341456a902225f3ad01f42834311bda7c2c47062289287b8a4cc0e0441b923aa6ece4a069879c395eaca28c20934ef745a890410ef94c054b2198ec5af94ba12b133c7cc197e42ca8d6347ed632ee64a7e6f249f9b02b473e942e43382bcf1b63ffede8d2c924a9712619d7a5ab75f19a678486315c4ba04709";

    //     bytes memory c2Bytes12 =
    //         hex"029a372c8db0496b5526a8fcb474e94c86a1d23983b2b1e5cb789f6915972414fedf408f8eb577dfe2155d78c2f6e37dd87a4450ff0e2107e3335dee57829f5d104e75fd1db53545f4b866d551c369c9d0c76837ad3436ae11eade08eacc6fea23a9d0762c518ae0da3dd5610580665076304d6eb262301ef3060ed43b117a181ee5f28c1494125c96b5e75c6ae0a99fa4e696ef6494b160acfe9c2edede08f71a13d9bdda0a137d1b2efe6e79cb201d3bbe522e12a9aa72c8a4dd63884da56392f791d4919fb44e860d1899f01eaa3bd4ed13b42f409a72c5f51e94f923cbd3c20d049f455745310d03689dc962e48507b68e3ba95dffb80325aa5b8f01770c";
    //     bytes memory inversec1powpriv =
    //         hex"67e0355d161168f914cd325946223659fdc622a7f2fd45365d4feacfc5646d2eaf5d22cc23872dbd80f278a3a51f9b65e51667df411a1adbb2d498a2149eadcee5ba2ecb3a3c68187eeeca9743430afd7730a67a5af48564e0f1a2a9a3a9b8282fbc2dc31edff7f60f54d50c6c72ec780c7dc393b05d9cb8964689f9388b02f7af6773d7b65a9d89e47625ed326718c62eb2d578ed307f3b21a4d6c7cabc0959e1bc2d005e6f3883caea8a8a27a8807736c664c0f22d19120757150d17dec14104f6f1d12ff524f5f0e0d7d6195ec8497be4c34aa85a4fef263cc174c0a2c4b38c0caf372eba06a66ab304cd56787ba260e293455e5a275b8da4298a6ffd583e";
    //     vm.startPrank(player1);
    //     // for now this is ok, as it means that the two player cards were successfully revealed
    //     vm.expectRevert("Invalid card string length");

    //     (string memory card1, string memory card2) = deckHandler.revealMyCards(
    //         c1Bytes, c2Bytes12, c2Bytes2, privatekey2048Bytes, c1InverseBytes, inversec1powpriv
    //     );
    //     vm.stopPrank();
    //     console.log("card1: %s", card1);
    //     console.log("card2: %s", card2);
    // }

    // function test_submitRevealCardsP2() public {
    //     bytes memory c1Bytes =
    //         hex"37440654a87a6beb67598985bdfe9a24682624d0c44bd138b0fc28ef7c1db5963ea5a86bdad64c1429db01c4dfc3cb1c528bf4deed8f7281316b620f6757746c0302963278dbc9dfc620027b023a9b35fb12fed75c848636124e10ca8100c5be48d1a47d0ae2a54609add1d8ea5bb6ac328b2c7ea7cf68a1b261457037cf63cbee8e9ddaf8aef70a32da57e6fd4de667b96ff8d5bb169726d258cdc305970aaa0ab9cada0735e7fbc7f7c7c208dc93cbc4fc2ba85470438c88000f14931c658189acfba8a7d10585b36e304c65f34eb9d2da4683f3d0d20ba7df498f4a7f6a8cbcdcd0846acf7c556471f7306970e419c332b64ab55699b211ef550507189114";
    //     bytes memory c2Bytes1 =
    //         hex"495e6ffba6645deaa7d7cc333dcba858e7a19c5677c5cb64946ce7e094acaed1b6f1a72f6ca562a3667b1c172313c7b1d7bf536b31f34941c6e2fea03a90fc7b151c3c89f909fc58b91a1addf6798a73e81819327e8633ad6669e471ab6f9f162ed40013c50bdcc42d6a3bb0c93fe72080bdf97cbc49f108bb3b305fe4252a83770475dd3bfe5ddbd84d379aba431049d7834a692708943f417db2292835821120754f825beb3a51de4e008153d6abc27ed2fc4c66574c1df4b69ba5f186e1a3593f603576ba6641fbae6d1ff61c426b641042c0b733eea40b308bc6f42d093ac875f57c711aa3f3cb1ff838aca4752ec1183425067bfab2b342b487545faf09";
    //     bytes memory c2Bytes2 =
    //         hex"f4ce1ebb2b760b455d80672013795b858112b688a26f6b789d85646150de6ac92faad0af9cc12a12a7c1e0bce298a7ad59de0558ef66670c6ed5da63e1fa9205144ffb14e49fa065befdc1e977740e8bd01b602ebb87e7f0f28257a1d2e9c44465a73ebf4b00e7f992b84cc8535dfa0d7f959cbcaa70a70c519db1654156ea0c7ba2cd2963d7932979e9dc52fb56ee7941a80067cd41545459618a74be94c120fb488b44a96236adb8e148955acc28d7f24532ec80b61df89950d2424dfd8e1229b5f560245e17a2b4cae2655def1a72ad9d6babca4927571506b0dc9f359652598c657afe5a847bb04ff2d28345da02534848f80da15e9f4e1ba73a1a556d60";
    //     bytes memory privatekey2048Bytes =
    //         hex"7c666f54cfa4632a9245f2da215a95a5648382092e4c4267261344528c85f4b1a78f745e2bd8c22f9710a740c72f7e3e18cde62d508a141e55c3de00d64df7017ffac01643548cc7bfc34fb68e83b8983c00f3164ca4b24cc7175129fa3d2a9f8068f145426aaa059e669d97a6c4a26fd1dc6c9682592fe5ff7fc100c41c70de24a9d06d4748b719f3f3b78af86db19b196e93dea98c961544f041a7428b1b5ea38e257cbfd0a778561d1072fb451a363d1a325880be61d374f2515eeb0f2eb318221bc7d6f59dd7439cdd93bab36f2d4fd30bcaa9b3858a5caa2dd57aa54882e847447ba8fb72d2f4b241e8258705b9f9a012ef816ea1972faf8f983470603f";
    //     bytes memory c1InverseBytes =
    //         hex"a86d09b0b6a2829722482945c9bd5fc0141889ef7324471d8a86144c985e30d6b40d4f3f7446dcfc6a97b552d23e8b7b64e386b22d660cf3977ec46fa42175be2c27d026b8f7bcb9ddc94d0bfda0048da9b56e696ad14c2c2655a2546d46426e309566f4ef346e522b60202a1b04a97cc0499d6391d4933da58e21caf621710a28afd1185ff4712eff6432f3bd32762939874e1b6fc74af3165c1b127362c9104be2a1479e734b04a80185394d133dc728bd5d75aa3733de78de0929e78b630ef27bcd6bdb469a76d7d655b77989a316e79f851a7a90c49288aaccda1eed4c34b3ae914625bd3f612d2e9ac63c14916efaed9f341ebfa34c550e5d494f0c32b9";

    //     vm.startPrank(player1);
    //     (string memory card1, string memory card2) = deckHandler.revealMyCards(
    //         c1Bytes, c2Bytes1, c2Bytes2, privatekey2048Bytes, c1InverseBytes
    //     );
    //     vm.stopPrank();
    //     console.log("card1: %s", card1);
    //     console.log("card2: %s", card2);
    // }

    // function test_submitRevealCardsSmallNumbers() public {
    //   //
    //     bytes memory c1Bytes =
    //         hex"37440654a87a6beb67598985bdfe9a24682624d0c44bd138b0fc28ef7c1db5963ea5a86bdad64c1429db01c4dfc3cb1c528bf4deed8f7281316b620f6757746c0302963278dbc9dfc620027b023a9b35fb12fed75c848636124e10ca8100c5be48d1a47d0ae2a54609add1d8ea5bb6ac328b2c7ea7cf68a1b261457037cf63cbee8e9ddaf8aef70a32da57e6fd4de667b96ff8d5bb169726d258cdc305970aaa0ab9cada0735e7fbc7f7c7c208dc93cbc4fc2ba85470438c88000f14931c658189acfba8a7d10585b36e304c65f34eb9d2da4683f3d0d20ba7df498f4a7f6a8cbcdcd0846acf7c556471f7306970e419c332b64ab55699b211ef550507189114";
    //     bytes memory c2Bytes1 =
    //         hex"495e6ffba6645deaa7d7cc333dcba858e7a19c5677c5cb64946ce7e094acaed1b6f1a72f6ca562a3667b1c172313c7b1d7bf536b31f34941c6e2fea03a90fc7b151c3c89f909fc58b91a1addf6798a73e81819327e8633ad6669e471ab6f9f162ed40013c50bdcc42d6a3bb0c93fe72080bdf97cbc49f108bb3b305fe4252a83770475dd3bfe5ddbd84d379aba431049d7834a692708943f417db2292835821120754f825beb3a51de4e008153d6abc27ed2fc4c66574c1df4b69ba5f186e1a3593f603576ba6641fbae6d1ff61c426b641042c0b733eea40b308bc6f42d093ac875f57c711aa3f3cb1ff838aca4752ec1183425067bfab2b342b487545faf09";
    //     bytes memory c2Bytes2 =
    //         hex"f4ce1ebb2b760b455d80672013795b858112b688a26f6b789d85646150de6ac92faad0af9cc12a12a7c1e0bce298a7ad59de0558ef66670c6ed5da63e1fa9205144ffb14e49fa065befdc1e977740e8bd01b602ebb87e7f0f28257a1d2e9c44465a73ebf4b00e7f992b84cc8535dfa0d7f959cbcaa70a70c519db1654156ea0c7ba2cd2963d7932979e9dc52fb56ee7941a80067cd41545459618a74be94c120fb488b44a96236adb8e148955acc28d7f24532ec80b61df89950d2424dfd8e1229b5f560245e17a2b4cae2655def1a72ad9d6babca4927571506b0dc9f359652598c657afe5a847bb04ff2d28345da02534848f80da15e9f4e1ba73a1a556d60";
    //     bytes memory privatekey2048Bytes =
    //         hex"7c666f54cfa4632a9245f2da215a95a5648382092e4c4267261344528c85f4b1a78f745e2bd8c22f9710a740c72f7e3e18cde62d508a141e55c3de00d64df7017ffac01643548cc7bfc34fb68e83b8983c00f3164ca4b24cc7175129fa3d2a9f8068f145426aaa059e669d97a6c4a26fd1dc6c9682592fe5ff7fc100c41c70de24a9d06d4748b719f3f3b78af86db19b196e93dea98c961544f041a7428b1b5ea38e257cbfd0a778561d1072fb451a363d1a325880be61d374f2515eeb0f2eb318221bc7d6f59dd7439cdd93bab36f2d4fd30bcaa9b3858a5caa2dd57aa54882e847447ba8fb72d2f4b241e8258705b9f9a012ef816ea1972faf8f983470603f";
    //     bytes memory c1InverseBytes =
    //         hex"a86d09b0b6a2829722482945c9bd5fc0141889ef7324471d8a86144c985e30d6b40d4f3f7446dcfc6a97b552d23e8b7b64e386b22d660cf3977ec46fa42175be2c27d026b8f7bcb9ddc94d0bfda0048da9b56e696ad14c2c2655a2546d46426e309566f4ef346e522b60202a1b04a97cc0499d6391d4933da58e21caf621710a28afd1185ff4712eff6432f3bd32762939874e1b6fc74af3165c1b127362c9104be2a1479e734b04a80185394d133dc728bd5d75aa3733de78de0929e78b630ef27bcd6bdb469a76d7d655b77989a316e79f851a7a90c49288aaccda1eed4c34b3ae914625bd3f612d2e9ac63c14916efaed9f341ebfa34c550e5d494f0c32b9";

    //     vm.startPrank(player1);
    //     (string memory card1, string memory card2) = deckHandler.revealMyCards(
    //         c1Bytes, c2Bytes1, c2Bytes2, privatekey2048Bytes, c1InverseBytes
    //     );
    //     vm.stopPrank();
    //     console.log("card1: %s", card1);
    //     console.log("card2: %s", card2);
    // }
}
