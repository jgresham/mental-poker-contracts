// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import "../src/TexasHoldemRoom.sol";
import "../src/PokerHandEvaluatorv2.sol";
import "../src/BigNumbers/BigNumbers.sol";
import "../src/CryptoUtils.sol";

contract TexasHoldemRoomRealKeysShuffledOnceTest is Test {
    using BigNumbers for BigNumber;

    TexasHoldemRoom public room;
    PokerHandEvaluatorv2 public pokerHandEvaluator;
    DeckHandler public deckHandler;
    address public player1;
    address public player2;
    address public player3;
    uint256 constant SMALL_BLIND = 10;
    uint256 constant INITIAL_BALANCE = 1000;
    CryptoUtils public cryptoUtils;
    BigNumber publicKey1;
    BigNumber privateKey1;
    BigNumber c1p1;
    BigNumber r1;
    BigNumber c1InversePowPrivate1;
    bytes[] encryptedDeck1bytes;

    BigNumber publicKey2;
    BigNumber privateKey2;
    BigNumber c1p2;
    BigNumber r2;
    BigNumber c1InversePowPrivate2;
    bytes[] encryptedDeck2bytes;

    function setUp() public {
        cryptoUtils = new CryptoUtils();
        pokerHandEvaluator = new PokerHandEvaluatorv2();
        room = new TexasHoldemRoom(address(cryptoUtils), SMALL_BLIND, false);
        deckHandler =
            new DeckHandler(address(room), address(cryptoUtils), address(pokerHandEvaluator));
        room.setDeckHandler(address(deckHandler));
        encryptedDeck1bytes = new bytes[](52);
        encryptedDeck2bytes = new bytes[](52);
        encryptedDeck1bytes[0] =
            hex"e001486ffce9035bdd04c38c2ab2b5c16bb221afe159e340071ba8f7954f7b14";
        encryptedDeck1bytes[1] =
            hex"e972d1069ecf7694ba4f8be76bb4f32502a6317120536b67cb447ee5339ece86";
        encryptedDeck1bytes[2] =
            hex"953d1e8753d499461248cc01e481fc4e72b561d2cb33428b2f87befd3afe6415";
        encryptedDeck1bytes[3] =
            hex"90845a3c02e15fa9a3a367d44400dd9ca73b59f22bb67e774d7354066bd6ba5c";
        encryptedDeck1bytes[4] =
            hex"a850c55e30e30aff8f3e24e7e29967999c7b20a427c09c2944c9ebbe0248cd87";
        encryptedDeck1bytes[5] =
            hex"25dc1863bbc8a88d76bb8eb9544f5ffed4475fbb5800b45daae4448a14f108fb";
        encryptedDeck1bytes[6] =
            hex"ad0989a981d6449bfde38915831a864b67f52884c73d603d26de56b4d1707740";
        encryptedDeck1bytes[7] =
            hex"703cccbcec95410398657e0b0a78a1e44f0fd4fa78ec2631221b8de5d75a62b0";
        encryptedDeck1bytes[8] =
            hex"f964dcfe6dd19d17eb657cafc075553a6fa1ce9dff1b001a30c211a631e91bb7";
        encryptedDeck1bytes[9] =
            hex"5d8c9b7587cea0e9c4822d5d9c68ae26a37e60c71199fb746d3601c3a7f7b688";
        encryptedDeck1bytes[10] =
            hex"2c5c9bc4e8e45bd7ca86b726680d84b0aa4eed26f7cec0e84c39015d74ec02ba";
        encryptedDeck1bytes[11] =
            hex"f4ac18b31cde637b7cc018821ff43688a427c6bd5f9e3c064eada6af62c171fe";
        encryptedDeck1bytes[12] =
            hex"388c49ab208f48a74a9edf66c25f53bc7fd8d3eebf52df1a5fc9d0ac4453b523";
        encryptedDeck1bytes[13] =
            hex"68c5e32205dd8dd086f2b9f850a7f18a44fff61350e4cc12f09f298dd71a5a00";
        encryptedDeck1bytes[14] =
            hex"3115601039d79574392c1b54088ea36275c8f507974b84fc2e4d6c544413ac73";
        encryptedDeck1bytes[15] =
            hex"cceda1991fda91a2600f6aa62c9b4a7641ec62de84cc89a1f1d97c36ce0511a2";
        encryptedDeck1bytes[16] =
            hex"80924e4433df3926728d770bef407b873a3fbcc54ceee9c4e7f5c1456d8c6d2b";
        encryptedDeck1bytes[17] =
            hex"113148209bd3486dd70039c35f0ddf379bd1baadd9bc5b97635246d2477f1211";
        encryptedDeck1bytes[18] =
            hex"0c7883d54ae00ed1685ad595be8cc085d057b2cd3a3f9783813ddbdb78576858";
        encryptedDeck1bytes[19] =
            hex"70a0424c64dd12a3417786439a801971cd441f986e27551282782e846f421ffa";
        encryptedDeck1bytes[20] =
            hex"854b128f84d272c2e132db398fc19a3905b9c4a5ec6badd8ca0a2c3c3cb416e4";
        encryptedDeck1bytes[21] =
            hex"4d9a8f7db8cc7a66936c3c9547a84c113682c39a32d266c207b86f02a9ad6957";
        encryptedDeck1bytes[22] =
            hex"9d177db1b2d41e18cccd984d2e5a2435faf98b57e875cb8ac160c3f3d3262a0f";
        encryptedDeck1bytes[23] =
            hex"1c6a8fcd19e235549970c65e134d229b3d534ffa19072c35e6bb6e9c76a1b589";
        encryptedDeck1bytes[24] =
            hex"a7ed4fceb89b395fe62c1caf5291f00c1e46d60632856d47e46d4b1f6a61103d";
        encryptedDeck1bytes[25] =
            hex"c834dd4dcee75805f16a06788c1a2bc476725afde54fc58e0fc5113ffedd67e9";
        encryptedDeck1bytes[26] =
            hex"d4648b34069244d571822eb8e66bfad04bfc41c5acd3e3c02355e08ece451a52";
        encryptedDeck1bytes[27] =
            hex"58d3d72a36db674d55dcc92ffbe78f74d80458e6721d37608b2196ccd8d00ccf";
        encryptedDeck1bytes[28] =
            hex"541b12dee5e82db0e73765025b6670c30c8a5105d2a0734ca90d2bd609a86316";
        encryptedDeck1bytes[29] =
            hex"eff35467cbeb29df0e1ab4547f7317d6d8adbedcc02177f26c993bb89399c845";
        encryptedDeck1bytes[30] =
            hex"df9dd2e084a131bc33f2bb539aab3e33ed7dd711ec1eb45ea6bf0858fd67bdca";
        encryptedDeck1bytes[31] =
            hex"7bd989f8e2ebff8a03e812de4ebf5cd56ec5b4e4ad7225b105e1564e9e64c372";
        encryptedDeck1bytes[32] =
            hex"b326977b36aa2646a89ca94a06d1336fbfc86b5271d03de667d672e99983b3b5";
        encryptedDeck1bytes[33] =
            hex"99f5e2d2a4c7d2e280ee302f85031b003e2f69b36ab0069f119c29f40a260dce";
        encryptedDeck1bytes[34] =
            hex"174e55f250a72a1881b959f7e2c48c5bf3a4fd7b844f3940a44a63070f924e86";
        encryptedDeck1bytes[35] =
            hex"212354186ad56ef108162a8bb3ce414d08cd57dab883f049c8cfd99345c95f42";
        encryptedDeck1bytes[36] =
            hex"049e24aaebe089feadd6094a74b4989e481389481cfd0e83ef64d6e4e02fa25e";
        encryptedDeck1bytes[37] =
            hex"38efbf3a98d71a46f3b0e79f5266cb49fe0d1e8cb48e0dfbc026714adc3b726d";
        encryptedDeck1bytes[38] =
            hex"48e1cb3267d940ca24c6d867a7272d5f6b08bbb99355a2ae25a4040bda85bf9e";
        encryptedDeck1bytes[39] =
            hex"b842d155ffe53182c05415b03759c9af0976bdd1068830dbaa477e7f00931ab8";
        encryptedDeck1bytes[40] =
            hex"e4ba0cbb4ddc3cf84baa27b9cb33d473372c299080d6a753e93013ee647724cd";
        encryptedDeck1bytes[41] =
            hex"0c150e45d2983d31bf48cd5d2e8548f85223682f450468a220e13b3ce06fab0e";
        encryptedDeck1bytes[42] =
            hex"17b1cb81c8eefbb82acb623072cc03e971d94819798a682204a703a5a77a0bd0";
        encryptedDeck1bytes[43] =
            hex"7b7614696aa42dea5ad60aa5beb7e547f0916a46b836f6cfa584b5b0067d0628";
        encryptedDeck1bytes[44] =
            hex"bcfb95a150d86b1f2ef979ddd7dae860d4f0c5b1a604f4ef8c5be975cfbac471";
        encryptedDeck1bytes[45] =
            hex"442906e716e6072db621743a06a60ead9f8eb3d8f3d8de9a438f99150b5e15e5";
        encryptedDeck1bytes[46] =
            hex"d4c800c37eda16751a9436f17673725dca308c63a20f12a183b2812d662cd79c";
        encryptedDeck1bytes[47] =
            hex"43c591579e9e358e0d0f6c01769e9720215a693afe9dafb8e332f8767376589b";
        encryptedDeck1bytes[48] =
            hex"fe1da149bec4d6b45a0ae0dd60f673ec3b1bd67e9e97c42e12d67c9d0110c570";
        encryptedDeck1bytes[49] =
            hex"75590697b5d04c3fb01cea713b01382398be27790da41926648c997b3e69c9b3";
        encryptedDeck1bytes[50] =
            hex"c1b459eca1cba4bb9d9ede0b785c0712a06acd924581b9036e70546c9ee26e2a";
        encryptedDeck1bytes[51] =
            hex"a0766633d1e3862cd4b9589c98c13fb21436f71f0a7e1329b2f0e6c76a21078d";
        encryptedDeck2bytes[0] =
            hex"9a743d42030180ac7163b343406b5ff6412175c20a2479b74e2d216f4a973fc1";
        encryptedDeck2bytes[1] =
            hex"6805a530391c390f565ce67a21d583d253747a793cfd2ca5e74b070021a0c46f";
        encryptedDeck2bytes[2] =
            hex"d8765118a925f75db9e9b9f8efbc7dc68e0104a7fda84de96a4653c98a882248";
        encryptedDeck2bytes[3] =
            hex"b7c44307a20e2488ffb49cbf6eb8b9894938814ba3af917ff32f57f38d0734ff";
        encryptedDeck2bytes[4] =
            hex"b91c6c61ef84e3e557bcb5a772777750defc40c010f4a31249f02b39bd50e172";
        encryptedDeck2bytes[5] =
            hex"0ae4e92a730b3efad4f086c20e5259eab29e254ea966d8c60c620bad32a280c9";
        encryptedDeck2bytes[6] =
            hex"49223988b2e445c146bd38c6d6b672195a8bb1d7e98bd8218a019d9e90bd4307";
        encryptedDeck2bytes[7] =
            hex"2a3ecde12cac5273371d8b138b97606061a2e936961a839d2cb8343cffd9c19f";
        encryptedDeck2bytes[8] =
            hex"48abc0797f7b2596f42fe228a4907d5ca46fb691504981cec6f4de7054698399";
        encryptedDeck2bytes[9] =
            hex"2a03915992f7c25e0dd6dfc4728466020694eb9349795873cb31d4a5e1afe1e8";
        encryptedDeck2bytes[10] =
            hex"6840e1b7d2d0c9247fa391c93ae87e30ae82781c899e57cf48d166973fcaa426";
        encryptedDeck2bytes[11] =
            hex"875f89e6f2bd4c87b889eacb9f1a8a4802793e6129b0d77d07a12f8feed80545";
        encryptedDeck2bytes[12] =
            hex"7b90d19a7cc98d5e61c4058ff54c4e3d4838ad20b6b32532f0e3b80db9b3be59";
        encryptedDeck2bytes[13] =
            hex"f7d035cf62c70ad61c16be4a6d01843c3d05c88fea5bf8c08a9c7c5957bf631e";
        encryptedDeck2bytes[14] =
            hex"f6019365e1e72b4f71814ec4371cd1b7f1260dd4e3d490db70cee9e4eb21f73d";
        encryptedDeck2bytes[15] =
            hex"495d76104c98d5d67003e415efc96c77b599af7b362d034aeb87fd35aee722be";
        encryptedDeck2bytes[16] =
            hex"98a59ad88221a125c6ce43bd0a86ad71f541bb07039d11d2345f8efaddf9d3e0";
        encryptedDeck2bytes[17] =
            hex"0b2025b20cbfcf0ffe373211276554490dac22f1f60803ef6de86b4450cc6080";
        encryptedDeck2bytes[18] =
            hex"2834eef01217e2d76341703e3c9fb37dbab530d842f1f08eb164423175127607";
        encryptedDeck2bytes[19] =
            hex"f80b7256fc7b9aeb455d699986147e9a9813c63336fd23e9ec22dbf075e942d5";
        encryptedDeck2bytes[20] =
            hex"48e6fd01192fb5ac1d768d77bda377baff7db4349ceaacf8287b3e0772936350";
        encryptedDeck2bytes[21] =
            hex"9a3900ba694cf097481d07f427586597e613781ebd834e8deca6c1d82c6d600a";
        encryptedDeck2bytes[22] =
            hex"7b559512e314fd49387d5a40dc3953deed2aaf7d6a11fa098f5d58769b89dea2";
        encryptedDeck2bytes[23] =
            hex"99fdc432cf9860821ed65ca50e456b398b057a7b70e223648b2062410e438053";
        encryptedDeck2bytes[24] =
            hex"d8b18da042da8772e330654808cf7824e90f024b4a497912cbccb360a8b201ff";
        encryptedDeck2bytes[25] =
            hex"d6e2eb36c1faa7ec389af5c1d2eac5a09d2f479043c2112db1ff20ec3c14961e";
        encryptedDeck2bytes[26] =
            hex"87244d5f5908bc728f433f7c86078fe9a76b40bddd0fac53a61acff8d0ae258e";
        encryptedDeck2bytes[27] =
            hex"b992e57122ee040faa4a0c45a49d6c0d95183c06aa36f9650cfcea67f9a4a0e0";
        encryptedDeck2bytes[28] =
            hex"67ca68a89f67a8fa2d163b2b08c28973f8667cd5f05c017c85c4a7690376e4b8";
        encryptedDeck2bytes[29] =
            hex"86e910d7bf542c5d65fc942d6cf4958b4c5d431a906e812a44947061b28445d7";
        encryptedDeck2bytes[30] =
            hex"9aaf79c99cb610c19aaa5e92597e5a549c2f736556c5a4e0afb3810668c11f78";
        encryptedDeck2bytes[31] =
            hex"d92806af7643a79d35bdbbe63af56ce19f2afd91e38bcf658ed9728ee505c16d";
        encryptedDeck2bytes[32] =
            hex"0aa9aca2d956aee5aba9db72f53f5f8c579027ab5cc5ad9caadbac161478a112";
        encryptedDeck2bytes[33] =
            hex"15203b9501d3aeb2aa67a7c69b4eddcf7c0cf977627e4e546ad8505219533b8b";
        encryptedDeck2bytes[34] =
            hex"298d184a5f8ea233bb498926405e71455078f04cb037022108251577a55c227a";
        encryptedDeck2bytes[35] =
            hex"8590e77d71dd6d010df47b456935d7c3b69983a623296f97edd39d1b823a9964";
        encryptedDeck2bytes[36] =
            hex"f759bcc02f5deaabc98967ac3adb8f7f86e9cd495119a26dc78fbd2b1b6ba3b0";
        encryptedDeck2bytes[37] =
            hex"b957a8e9893973fa810360f68b8a71af3a0a3e635d95ce3bab768ad0db7ac129";
        encryptedDeck2bytes[38] =
            hex"68b75ac70639e94ed230e8676d0e72ed649e736322e0ae220bde25c57c1e6394";
        encryptedDeck2bytes[39] =
            hex"d8ecca27dc8f17880c77109721e27283441cffee96eaa43c2d5312f7c6dbe1b6";
        encryptedDeck2bytes[40] =
            hex"167864ef4f4a6e0f026fc0ae9f0d9b9711d0b8ebcfc35fe6c1992398499ce7fe";
        encryptedDeck2bytes[41] =
            hex"ec017d82ecd34bacc550d90ec333483182c5374f775e467673df04d7229b1c32";
        encryptedDeck2bytes[42] =
            hex"d83b14910f71674890a30ea9d6a9836832f30704b10722c008bff4326c5e4291";
        encryptedDeck2bytes[43] =
            hex"66723f4e51f0e99dd50e22430503cbac62a2bd618316efea2f03d422d32d3845";
        encryptedDeck2bytes[44] =
            hex"29c854d1f9433248e490347559716ba3ab86edeffcd82d4a69ab750ec3860231";
        encryptedDeck2bytes[45] =
            hex"4753971f3204663a9c27c940a0d1bf950eabf71ce304703c70340b2a241fd726";
        encryptedDeck2bytes[46] =
            hex"a607b906df40afc09ee2ed2fd126a1a2a054095f308100d80364395a6191a6f6";
        encryptedDeck2bytes[47] =
            hex"b9ce21f8bca29424d390b794bdb0666bf02639a9f6d8248e6e8349ff17ce8097";
        encryptedDeck2bytes[48] =
            hex"16b3a176e8fefe242bb66bfdb82095f56cdeb68f1c648b10231f832f67c6c7b5";
        encryptedDeck2bytes[49] =
            hex"091646c0f22b5f742a5b173bd86da76666be6a93a2df70e0f2947938c60514e8";
        encryptedDeck2bytes[50] =
            hex"f794f947c9127ac0f2d012fb53ee89dde1f7caec9dbacd9729161cc239958367";
        encryptedDeck2bytes[51] =
            hex"687c1e3f6c855939a8ea3d1853fb788f099075bfd63f82f8aa57c62e5df483dd";

        bytes memory publicKey1bytes =
            hex"e339067d976a1255b11d761d52d8ffd9a64c98903b2dbe78a03be5cd94cfb8d9";
        bytes memory privateKey1bytes =
            hex"7f008f236006eede4a6e026e49cd1a7eeadac0e36088858e84545c16c1469e6e";
        bytes memory c1p1bytes =
            hex"69b481a9459039ebf5a46f511f7312a204b53a633d64563347fed740e5f9feeb";
        bytes memory r1bytes = hex"ef964d7bee8b0cdcaae8dbfdb5fc2b193a2f11c2da5e874979e89aae868a4014";
        bytes memory c1InversePowPrivateKey =
            hex"83fc50dac2ee8ad98c4bc0872593bd432ee27a5d1ad90b19b3d824b9de08a621";

        bytes memory publicKey2bytes =
            hex"fcf8341cefd3f559b2f0f48935b5043e009c35a6dc13cc18b1173db3090b28a8";
        bytes memory privateKey2bytes =
            hex"f87a3cbf05aab6ef9c94afdceb5a8af7317d5474587ce7ac4a1a836c2f3fb423";
        bytes memory c1p2bytes =
            hex"812190a41ff041bf544eb465ff7557c23080bdb2cf17fd521015adaaf7152b32";
        bytes memory r2bytes = hex"782ea8d386effebcae8fa1d390f26e6839864c6e56c01827e30071f6541efe7d";
        bytes memory c1InversePowPrivateKey2 =
            hex"8e80f2b7cc46fb0f66e1365695da1cfe4245dc6c7b1433585217bc102a51a171";
        publicKey1 = BigNumbers.init(publicKey1bytes, false);
        privateKey1 = BigNumbers.init(privateKey1bytes, false);
        c1p1 = BigNumbers.init(c1p1bytes, false);
        r1 = BigNumbers.init(r1bytes, false);
        c1InversePowPrivate1 = BigNumbers.init(c1InversePowPrivateKey, false);
        publicKey2 = BigNumbers.init(publicKey2bytes, false);
        privateKey2 = BigNumbers.init(privateKey2bytes, false);
        c1p2 = BigNumbers.init(c1p2bytes, false);
        r2 = BigNumbers.init(r2bytes, false);
        c1InversePowPrivate2 = BigNumbers.init(c1InversePowPrivateKey2, false);
        // BigNumber memory card1 = BigNumbers.init(encryptedDeck1bytes[0], false);
        // encryptedDeck1 = new BigNumber[](52);
        // for (uint256 i = 0; i < 52; i++) {
        //     encryptedDeck1[i] = BigNumbers.init(encryptedDeck1bytes[i], false);
        //     encryptedDeck2[i] = BigNumbers.init(encryptedDeck2bytes[i], false);
        // }
        // Create test accounts
        player1 = makeAddr("player1");
        player2 = makeAddr("player2");
        player3 = makeAddr("player3");

        // Fund test accounts
        vm.deal(player1, INITIAL_BALANCE);
        vm.deal(player2, INITIAL_BALANCE);
        vm.deal(player3, INITIAL_BALANCE);
    }

    // (gas: 7,682,186)
    // (gas: 4,980,995) w/o initializing deck with BigNumbers = 0
    // function test_CreateRoom() public {
    //     TexasHoldemRoom roomTestCreate = new TexasHoldemRoom(SMALL_BLIND, false);
    //     (TexasHoldemRoom.GameStage stageRoomTestCreate,,,,,,,,) = roomTestCreate.gameState();
    //     assertEq(uint256(stageRoomTestCreate), uint256(TexasHoldemRoom.GameStage.Idle));
    //     assertEq(roomTestCreate.numPlayers(), 0);
    // }

    // function test_JoinGameWith2PlayersStartsGame() public {
    //     // Verify that the game state is idle phase
    //     (TexasHoldemRoom.GameStage stage0,,,,,,,) = room.gameState();
    //     assertEq(uint256(stage0), uint256(TexasHoldemRoom.GameStage.Idle));

    //     // Test joining with player1
    //     vm.startPrank(player1);
    //     room.joinGame();
    //     vm.stopPrank();

    //     // Verify player1 joined successfully
    //     (
    //         address addr,
    //         uint256 chips,
    //         uint256 currentStageBet,
    //         uint256 totalRoundBet,
    //         bool hasFolded,
    //         bool isAllIn,
    //         uint256 seatPosition
    //     ) = room.players(0);
    //     assertEq(addr, player1);
    //     assertEq(chips, INITIAL_BALANCE);
    //     assertEq(currentStageBet, 0);
    //     assertEq(totalRoundBet, 0);
    //     assertEq(hasFolded, false);
    //     assertEq(isAllIn, false);
    //     assertEq(seatPosition, 0);
    //     assertEq(room.numPlayers(), 1);

    //     // Verify that the game state is still idle phase
    //     (TexasHoldemRoom.GameStage stage1,,,,,,,) = room.gameState();
    //     assertEq(uint256(stage1), uint256(TexasHoldemRoom.GameStage.Idle));

    //     // Test joining with player2
    //     vm.startPrank(player2);
    //     room.joinGame();
    //     vm.stopPrank();

    //     // Verify player2 joined successfully
    //     (addr, chips, currentStageBet, totalRoundBet, hasFolded, isAllIn, seatPosition) = room.players(1);
    //     assertEq(addr, player2);
    //     assertEq(chips, INITIAL_BALANCE);
    //     assertEq(currentStageBet, 0);
    //     assertEq(totalRoundBet, 0);
    //     assertEq(hasFolded, false);
    //     assertEq(isAllIn, false);
    //     assertEq(seatPosition, 1);
    //     assertEq(room.numPlayers(), 2);

    //     // Verify that the game state is now in the shuffle phase
    //     (TexasHoldemRoom.GameStage stage2,,,,,,,) = room.gameState();
    //     assertEq(uint256(stage2), uint256(TexasHoldemRoom.GameStage.Shuffle));
    // }

    function test_NextActivePlayer() public {
        // Test joining with player1
        vm.startPrank(player1);
        room.joinGame();
        vm.stopPrank();

        // Test joining with player2
        vm.startPrank(player2);
        room.joinGame();
        vm.stopPrank();

        // Verify the players' index and seat positions
        TexasHoldemRoom.Player[] memory players = room.getPlayers();
        assertEq(players[0].addr, player1);
        assertEq(players[1].addr, player2);
        assertEq(players[0].seatPosition, 0);
        assertEq(players[1].seatPosition, 1);

        assertEq(room.getNextActivePlayer(true), 1);
        // assertEq(room.getNextActivePlayer(1, true), 0);
        assertEq(room.getNextActivePlayer(false), 1);
        // assertEq(room.getNextActivePlayer(1, false), 0);
    }

    // For one player submit: (gas: 3,486,222) to save state (and emit event)
    // For one play submit: (gas: 768,315) to just emit event
    function test_RealKeysShuffle2Players256bit() public {
        console.log("test_RealKeysShuffle2Players");
        console.log("encryptedDeck1bytes.length");
        console.log(encryptedDeck1bytes.length);
        console.log("encryptedDeck2bytes.length");
        console.log(encryptedDeck2bytes.length);
        // Test joining with player1
        vm.startPrank(player1);
        room.joinGame();
        vm.stopPrank();
        // Test joining with player2
        vm.startPrank(player2);
        room.joinGame();
        vm.stopPrank();

        // Verify that the game state is now in the shuffle phase
        TexasHoldemRoom.GameStage stage2 = room.stage();
        assertEq(uint256(stage2), uint256(TexasHoldemRoom.GameStage.Shuffle));
        assertEq(room.dealerPosition(), 0);
        assertEq(room.currentPlayerIndex(), 0);

        // The Dealer should be player1
        // and player1 should submit their encrypted shuffle first
        vm.startPrank(player1);

        bytes[] memory encryptedShuffleBytes = new bytes[](52);
        for (uint256 i = 0; i < 52; i++) {
            encryptedShuffleBytes[i] = encryptedDeck1bytes[i];
        }

        deckHandler.submitEncryptedShuffle(encryptedShuffleBytes);

        vm.stopPrank();

        assertEq(room.dealerPosition(), 0);
        assertEq(room.currentPlayerIndex(), 1);

        // TODO: encryptions should be calculated from player1's encrypted shuffle
        // player2 should submit their encrypted shuffle next
        vm.startPrank(player2);

        for (uint256 i = 0; i < 52; i++) {
            encryptedShuffleBytes[i] = encryptedDeck2bytes[i];
        }

        deckHandler.submitEncryptedShuffle(encryptedShuffleBytes);

        vm.stopPrank();

        // Verify that the game state is now in the deal phase
        TexasHoldemRoom.GameStage stage3 = room.stage();
        assertEq(uint256(stage3), uint256(TexasHoldemRoom.GameStage.RevealDeal));
        assertEq(room.dealerPosition(), 0);
        assertEq(room.currentPlayerIndex(), 0);

        // player 1 should submit their decryption values for player 2's cards
        vm.startPrank(player1);
        // the encrypted values submitted are not correct at the moment
        // submit card index and decrypted value for each card
        // card 0 to p1, card 1 to p2, card 2 to p1, card 3 to p2!
        uint256[] memory cardIndexes = new uint256[](2);
        cardIndexes[0] = 1;
        cardIndexes[1] = 3;
        BigNumber[] memory decryptionValues = new BigNumber[](2);
        decryptionValues[0] = BigNumbers.init(
            hex"f565ffded402928ab07c9d4f27913ced60bae0c6b05027a5801ac2f3182f2bab", false
        );
        decryptionValues[1] = BigNumbers.init(
            hex"0f92bee100e9296ee21fa3c04ec5e77986663ec461dbf9e8483c25bb746841c4", false
        );
        bytes[] memory decryptionValuesBytes = new bytes[](2);
        decryptionValuesBytes[0] = decryptionValues[0].val;
        decryptionValuesBytes[1] = decryptionValues[1].val;
        deckHandler.submitDecryptionValues(cardIndexes, decryptionValuesBytes);
        vm.stopPrank();
        console.log("Player 1 submitted decryption values");

        assertEq(room.currentPlayerIndex(), 1, "Player 2 should be the current player");

        // player 2 should submit their decryption values for player 1's cards
        vm.startPrank(player2);
        cardIndexes[0] = 0;
        cardIndexes[1] = 2;
        decryptionValues[0] = BigNumbers.init(
            hex"90845a3c02e15fa9a3a367d44400dd9ca73b59f22bb67e774d7354066bd6ba5c", false
        );
        decryptionValues[1] = BigNumbers.init(
            hex"e4ba0cbb4ddc3cf84baa27b9cb33d473372c299080d6a753e93013ee647724cd", false
        );
        bytes[] memory decryptionValuesBytes2 = new bytes[](2);
        decryptionValuesBytes2[0] = decryptionValues[0].val;
        decryptionValuesBytes2[1] = decryptionValues[1].val;
        deckHandler.submitDecryptionValues(cardIndexes, decryptionValuesBytes2);
        vm.stopPrank();
        console.log("Player 2 submitted decryption values");

        // Verify that the game state is now in the preflop phase, stage 3
        TexasHoldemRoom.GameStage stage4 = room.stage();
        assertEq(
            uint256(stage4), uint256(TexasHoldemRoom.GameStage.Preflop), "Preflop stage not reached"
        );
        console.log("Preflop stage reached");
        // the first active player LEFT of the dealer starts all betting stages
        assertEq(
            room.currentPlayerIndex(),
            1,
            "Starting PreFlop: Current player index is 1(p2, left of the dealer)"
        );
        assertEq(
            room.lastRaiseIndex(),
            1,
            "Starting PreFlop: Last raise index is 1 (default left of the dealer)"
        );
        // TODO: verify that each player can decrypt their cards

        // Start preflop betting player 2 (left of the dealer)
        // player 2 should submit their action
        // test that player 1 cannot submit an action first
        vm.startPrank(player1);
        vm.expectRevert("Not your turn");
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 1);
        assertEq(room.lastRaiseIndex(), 1, "Starting PreFlop: Last raise index is not 1");
        // player 2 should submit their action
        console.log("Player 2 submitting check action");
        vm.startPrank(player2);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.stopPrank();

        // now player 1 should be able to submit an action
        assertEq(room.currentPlayerIndex(), 0);
        assertEq(room.lastRaiseIndex(), 1, "Player 2 should be the last raise index");
        console.log("Player 1 submitting check action");
        vm.startPrank(player1);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.stopPrank();

        // We should be in the reveal flop phase now
        assertEq(uint256(room.stage()), uint256(TexasHoldemRoom.GameStage.RevealFlop));
        // The dealer starts all reveal stages
        assertEq(room.currentPlayerIndex(), 0);
        console.log("Reveal flop stage reached");

        // All players should submit their decryption values for the flop cards
        uint256[] memory cardIndexesFlop = new uint256[](3);
        BigNumber[] memory decryptionValuesFlop = new BigNumber[](3);
        // player 1 should submit their decryption values for flop cards
        vm.startPrank(player1);
        // 2 players, 5th card is burned, 678 are the flop cards
        cardIndexesFlop[0] = 5;
        cardIndexesFlop[1] = 6;
        cardIndexesFlop[2] = 7;
        decryptionValuesFlop[0] = BigNumbers.init(
            hex"96009a73adbedacd4ac034c5f9a31bb8e449290fc85c336504b937a01f945653", false
        );
        decryptionValuesFlop[1] = BigNumbers.init(
            hex"81e2c5339ab7109f2709b6dda7f3437704536011abac714fe750bbc0cb0a8835", false
        );
        decryptionValuesFlop[2] = BigNumbers.init(
            hex"0e5f8a88616b8eb39d96d06c28554a00a7ebdf5ca708bafa4e86b48e7de5e4bf", false
        );
        bytes[] memory decryptionValuesBytesFlop = new bytes[](3);
        decryptionValuesBytesFlop[0] = decryptionValuesFlop[0].val;
        decryptionValuesBytesFlop[1] = decryptionValuesFlop[1].val;
        decryptionValuesBytesFlop[2] = decryptionValuesFlop[2].val;
        deckHandler.submitDecryptionValues(cardIndexesFlop, decryptionValuesBytesFlop);
        vm.stopPrank();

        assertEq(room.currentPlayerIndex(), 1);

        // 2 players, 5th card is burned, 678 are the flop cards
        vm.startPrank(player2);
        cardIndexesFlop[0] = 5;
        cardIndexesFlop[1] = 6;
        cardIndexesFlop[2] = 7;
        decryptionValuesFlop[0] = BigNumbers.init(
            hex"0000000000000000000000000000000000000000000000000000000000003338", false
        );
        decryptionValuesFlop[1] = BigNumbers.init(
            hex"0000000000000000000000000000000000000000000000000000000000003334", false
        );
        decryptionValuesFlop[2] = BigNumbers.init(
            hex"0000000000000000000000000000000000000000000000000000000000003435", false
        );
        decryptionValuesBytesFlop[0] = decryptionValuesFlop[0].val;
        decryptionValuesBytesFlop[1] = decryptionValuesFlop[1].val;
        decryptionValuesBytesFlop[2] = decryptionValuesFlop[2].val;

        // assert that none of the community cards are not set yet
        // assertEq(room.communityCards(4), "");
        // assertEq(room.communityCards(3), "");
        // assertEq(room.communityCards(2), "");
        // assertEq(room.communityCards(1), "");
        // assertEq(room.communityCards(0), "");

        vm.expectEmit();
        emit DeckHandler.FlopRevealed("38", "34", "45");
        deckHandler.submitDecryptionValues(cardIndexesFlop, decryptionValuesBytesFlop);
        // assertEq(room.communityCards(4), "");
        // assertEq(room.communityCards(3), "");
        // assertEq(room.communityCards(2), "17");
        // assertEq(room.communityCards(1), "0");
        // assertEq(room.communityCards(0), "47");
        vm.stopPrank();

        // We should be in the flop phase now
        assertEq(uint256(room.stage()), uint256(TexasHoldemRoom.GameStage.Flop));
        assertEq(room.currentPlayerIndex(), 1);
        assertEq(room.lastRaiseIndex(), 1);
        assertEq(room.dealerPosition(), 0);

        // test betting stage, player 2 checks, player 1 raises, player 2 raises, player 1 calls
        vm.startPrank(player2);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 0);
        assertEq(room.lastRaiseIndex(), 1);
        assertEq(room.currentStageBet(), 0);
        assertEq(room.pot(), 0);

        vm.startPrank(player1);
        room.submitAction(TexasHoldemRoom.Action.Raise, 10);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 1);
        assertEq(room.lastRaiseIndex(), 0); // p1 raised!
        assertEq(room.currentStageBet(), 10);
        assertEq(room.pot(), 10);

        vm.startPrank(player2);
        vm.expectRevert("Raise must be higher than current bet");
        room.submitAction(TexasHoldemRoom.Action.Raise, 10);
        room.submitAction(TexasHoldemRoom.Action.Raise, 100);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 0);
        assertEq(room.lastRaiseIndex(), 1); // p2 raised!
        assertEq(room.currentStageBet(), 100); // per player (to stay in the round)
        assertEq(room.pot(), 110); // total pot

        vm.startPrank(player1);
        room.submitAction(TexasHoldemRoom.Action.Call, 0);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 0); // End of betting stage, start of reveal stage
        assertEq(room.lastRaiseIndex(), 1);
        assertEq(room.currentStageBet(), 0);
        assertEq(room.pot(), 200);

        assertEq(uint256(room.stage()), uint256(TexasHoldemRoom.GameStage.RevealTurn));

        // All players should submit their decryption values for the turn card
        uint256[] memory cardIndexesTurn = new uint256[](1);
        BigNumber[] memory decryptionValuesTurn = new BigNumber[](1);
        // 2 players, 5th card is burned, 678 are the flop cards,
        // 9th card is burned, 10th card is the turn card
        cardIndexesTurn[0] = 9;
        decryptionValuesTurn[0] = BigNumbers.init(
            hex"8bf1afd3a43af5b638e4f5d1d0cb2f97f44e4490ba04525a7604f9b0754f6f44", false
        );
        bytes[] memory decryptionValuesBytesTurn = new bytes[](1);
        decryptionValuesBytesTurn[0] = decryptionValuesTurn[0].val;
        vm.startPrank(player1);
        deckHandler.submitDecryptionValues(cardIndexesTurn, decryptionValuesBytesTurn);
        vm.stopPrank();

        assertEq(room.currentPlayerIndex(), 1);
        vm.startPrank(player2);
        cardIndexesTurn[0] = 9;
        decryptionValuesTurn[0] = BigNumbers.init(
            hex"0000000000000000000000000000000000000000000000000000000000003336", false
        );
        decryptionValuesBytesTurn[0] = decryptionValuesTurn[0].val;
        vm.expectEmit();
        emit DeckHandler.TurnRevealed("36");
        deckHandler.submitDecryptionValues(cardIndexesTurn, decryptionValuesBytesTurn);
        // assertEq(room.communityCards(4), "");
        // assertEq(room.communityCards(3), "49");
        // assertEq(room.communityCards(2), "17");
        // assertEq(room.communityCards(1), "0");
        // assertEq(room.communityCards(0), "47");
        vm.stopPrank();

        assertEq(uint256(room.stage()), uint256(TexasHoldemRoom.GameStage.Turn));
        assertEq(room.currentPlayerIndex(), 1);

        vm.startPrank(player2);
        room.submitAction(TexasHoldemRoom.Action.Raise, 100);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 0);
        assertEq(room.lastRaiseIndex(), 1);
        assertEq(room.currentStageBet(), 100);
        assertEq(room.pot(), 300);

        vm.startPrank(player1);
        room.submitAction(TexasHoldemRoom.Action.Call, 0);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 0);
        assertEq(room.currentStageBet(), 0);
        assertEq(room.pot(), 400);

        assertEq(uint256(room.stage()), uint256(TexasHoldemRoom.GameStage.RevealRiver));

        // All players should submit their decryption values for the river card
        uint256[] memory cardIndexesRiver = new uint256[](1);
        BigNumber[] memory decryptionValuesRiver = new BigNumber[](1);
        // 2 players, 9th card is burned, 10th card is the turn card
        // 11th card is burned, 12th card is the river card
        cardIndexesRiver[0] = 11;
        decryptionValuesRiver[0] = BigNumbers.init(
            hex"6dc4eff387af4671035338f556436b35245d97138efcaf3ac9e83fe17680ba17", false
        );
        bytes[] memory decryptionValuesBytesRiver = new bytes[](1);
        decryptionValuesBytesRiver[0] = decryptionValuesRiver[0].val;
        vm.startPrank(player1);
        deckHandler.submitDecryptionValues(cardIndexesRiver, decryptionValuesBytesRiver);
        vm.stopPrank();

        assertEq(room.currentPlayerIndex(), 1);
        vm.startPrank(player2);
        cardIndexesRiver[0] = 11;
        decryptionValuesRiver[0] = BigNumbers.init(
            hex"0000000000000000000000000000000000000000000000000000000000003330", false
        );
        decryptionValuesBytesRiver[0] = decryptionValuesRiver[0].val;
        vm.expectEmit();
        emit DeckHandler.RiverRevealed("30");
        deckHandler.submitDecryptionValues(cardIndexesRiver, decryptionValuesBytesRiver);
        // assertEq(room.communityCards(4), "34");
        // assertEq(room.communityCards(3), "49");
        // assertEq(room.communityCards(2), "17");
        // assertEq(room.communityCards(1), "0");
        // assertEq(room.communityCards(0), "47");
        vm.stopPrank();

        assertEq(uint256(room.stage()), uint256(TexasHoldemRoom.GameStage.River));
        assertEq(room.currentPlayerIndex(), 1);

        vm.startPrank(player2);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 0);
        assertEq(room.lastRaiseIndex(), 1);
        assertEq(room.currentStageBet(), 0);
        assertEq(room.pot(), 400);

        vm.startPrank(player1);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 0);

        assertEq(uint256(room.stage()), uint256(TexasHoldemRoom.GameStage.Showdown));
        assertEq(room.currentPlayerIndex(), 0);
        // reveal cards?
        // submit private key r's and mid func calcs. verify cards. compare hands
        console.log("Player1 is revealing their cards");
        vm.startPrank(player1);
        CryptoUtils.EncryptedCard memory encryptedCard1 =
            CryptoUtils.EncryptedCard({ c1: c1p1, c2: deckHandler.getEncrypedCard(0) });
        CryptoUtils.EncryptedCard memory encryptedCard2 =
            CryptoUtils.EncryptedCard({ c1: c1p1, c2: deckHandler.getEncrypedCard(2) });

        // don't check equality of cards as we don't know them yet
        vm.expectEmit(address(deckHandler));
        emit DeckHandler.PlayerCardsRevealed(
            address(player1), "37", "24", PokerHandEvaluatorv2.HandRank.Flush, 600001413121006
        );
        (string memory card1, string memory card2) = deckHandler.revealMyCards(
            c1p1.val,
            // deckHandler.getEncrypedCard(0).val,
            // deckHandler.getEncrypedCard(2).val,
            privateKey1.val,
            c1InversePowPrivate1.val
        );
        vm.stopPrank();
        console.log("card1: %s %s", card1, pokerHandEvaluator.stringToHumanReadable(card1));
        console.log("card2: %s %s", card2, pokerHandEvaluator.stringToHumanReadable(card2));
        // assert that card1 is in the deck (range 0 to 51)
        vm.assertTrue(pokerHandEvaluator.parseInt(card1) < 52);
        vm.assertTrue(pokerHandEvaluator.parseInt(card2) < 52);
        TexasHoldemRoom.Player[] memory players = room.getPlayers();
        vm.assertEq(players[0].handScore, 600001413121006);

        console.log("Player2 is revealing their cards");
        vm.startPrank(player2);
        CryptoUtils.EncryptedCard memory encryptedCard3 =
            CryptoUtils.EncryptedCard({ c1: c1p2, c2: deckHandler.getEncrypedCard(1) });
        CryptoUtils.EncryptedCard memory encryptedCard4 =
            CryptoUtils.EncryptedCard({ c1: c1p2, c2: deckHandler.getEncrypedCard(3) });

        // don't check equality of cards as we don't know them yet
        vm.expectEmit(address(deckHandler));
        emit DeckHandler.PlayerCardsRevealed(
            address(player2), "23", "6", PokerHandEvaluatorv2.HandRank.TwoPair, 300000012080014
        );
        // also expect a winner event to be emitted
        // vm.expectEmit(address(room));
        // emit TexasHoldemRoom.RoundWinner(address(player2), 1);
        (string memory card3, string memory card4) = deckHandler.revealMyCards(
            c1p2.val,
            // deckHandler.getEncrypedCard(1).val,
            // deckHandler.getEncrypedCard(3).val,
            privateKey2.val,
            c1InversePowPrivate2.val
        );
        vm.stopPrank();
        console.log("card3: %s %s", card3, pokerHandEvaluator.stringToHumanReadable(card3));
        console.log("card4: %s %s", card4, pokerHandEvaluator.stringToHumanReadable(card4));
        // assert that card3 is in the deck (range 0 to 51)
        vm.assertTrue(pokerHandEvaluator.parseInt(card3) < 52);
        // assert that card4 is in the deck (range 0 to 51)
        vm.assertTrue(pokerHandEvaluator.parseInt(card4) < 52);
        players = room.getPlayers();
        // handScores get set to 0 after a new round!
        vm.assertEq(players[1].handScore, 0);
        vm.assertEq(players[0].handScore, 0);
        // todo: check cards exactly match an shuffled deck's cards (no dupes too)

        //         bytes memory expectedMessageBytes = hex"30";
        //        BigNumber memory testMessage = BigNumbers.init(expectedMessageBytes, false);
        // assertEq(BigNumbers.eq(decryptedMessage, testMessage), true);
        // compare cards
    }

    // function test_JoinGameFailures() public {
    //     // Test joining twice
    //     vm.startPrank(player1);
    //     room.joinGame();
    //     vm.expectRevert("Already in game");
    //     room.joinGame();
    //     vm.stopPrank();
    // }

    // function test_StartNewHand() public {
    //     // Setup: Join two players
    //     vm.prank(player1);
    //     room.joinGame();
    //     vm.prank(player2);
    //     room.joinGame();

    //     // Start new hand
    //     vm.prank(player1);
    //     room.startNewHand();

    //     // Verify game state
    //     (
    //         TexasHoldemRoom.GameStage stage,
    //         uint256 pot,
    //         uint256 currentBet,
    //         uint256 smallBlind,
    //         uint256 bigBlind,
    //         uint256 dealerPosition,
    //         uint256 currentPlayerIndex,
    //         uint256 lastRaiseIndex,
    //         uint256 revealedCommunityCards
    //     ) = room.gameState();

    //     assertEq(uint256(stage), uint256(TexasHoldemRoom.GameStage.Preflop));
    //     assertEq(pot, SMALL_BLIND + SMALL_BLIND * 2); // SB + BB
    //     assertEq(currentBet, SMALL_BLIND * 2); // BB amount
    //     assertEq(dealerPosition, 0);
    //     assertEq(currentPlayerIndex, 0); // First player after BB
    // }

    // function test_StartNewHandFailures() public {
    //     // Test starting with only one player
    //     vm.startPrank(player1);
    //     room.joinGame();
    //     vm.expectRevert("Not enough players");
    //     room.startNewHand();
    //     vm.stopPrank();
    // }

    // function test_PlayerActions() public {
    //     // Setup: Join three players and start hand
    //     vm.prank(player1);
    //     room.joinGame();
    //     vm.prank(player2);
    //     room.joinGame();
    //     vm.prank(player3);
    //     room.joinGame();

    //     vm.prank(player1);
    //     room.startNewHand();

    //     // Test fold action
    //     vm.prank(player1);
    //     room.submitAction(TexasHoldemRoom.Action.Fold, 0);

    //     // Test call action
    //     vm.prank(player2);
    //     room.submitAction(TexasHoldemRoom.Action.Call, 0);

    //     // Test raise action
    //     vm.prank(player3);
    //     room.submitAction(TexasHoldemRoom.Action.Raise, SMALL_BLIND * 4);

    //     // Verify game state after actions
    //     (, uint256 pot, uint256 currentBet,,,,,, uint256 revealedCommunityCards) = room.gameState();

    //     assertEq(currentBet, SMALL_BLIND * 4);
    //     assertEq(pot, SMALL_BLIND + SMALL_BLIND * 2 + SMALL_BLIND * 4);
    // }

    // function test_PlayerActionFailures() public {
    //     // Setup game
    //     vm.prank(player1);
    //     room.joinGame();
    //     vm.prank(player2);
    //     room.joinGame();

    //     vm.prank(player1);
    //     room.startNewHand();

    //     // Test acting out of turn
    //     vm.prank(player2);
    //     vm.expectRevert("Not your turn");
    //     room.submitAction(TexasHoldemRoom.Action.Call, 0);

    //     // Test invalid raise amount
    //     vm.prank(player1);
    //     vm.expectRevert("Raise must be higher than current bet");
    //     room.submitAction(TexasHoldemRoom.Action.Raise, SMALL_BLIND);
    // }

    // function test_GameProgression() public {
    //     // Setup game
    //     vm.prank(player1);
    //     room.joinGame();
    //     vm.prank(player2);
    //     room.joinGame();

    //     vm.prank(player1);
    //     room.startNewHand();

    //     // Submit actions to progress through stages
    //     vm.prank(player1);
    //     room.submitAction(TexasHoldemRoom.Action.Call, 0);
    //     vm.prank(player2);
    //     room.submitAction(TexasHoldemRoom.Action.Check, 0);

    //     // Verify we're in flop stage
    //     (TexasHoldemRoom.GameStage stage,,,,,,,, uint256 revealedCommunityCards) = room.gameState();
    //     assertEq(uint256(stage), uint256(TexasHoldemRoom.GameStage.Flop));

    //     // Continue through turn and river
    //     vm.prank(player1);
    //     room.submitAction(TexasHoldemRoom.Action.Check, 0);
    //     vm.prank(player2);
    //     room.submitAction(TexasHoldemRoom.Action.Check, 0);

    //     (stage,,,,,,,, revealedCommunityCards) = room.gameState();
    //     assertEq(uint256(stage), uint256(TexasHoldemRoom.GameStage.Turn));

    //     vm.prank(player1);
    //     room.submitAction(TexasHoldemRoom.Action.Check, 0);
    //     vm.prank(player2);
    //     room.submitAction(TexasHoldemRoom.Action.Check, 0);

    //     (stage,,,,,,,, revealedCommunityCards) = room.gameState();
    //     assertEq(uint256(stage), uint256(TexasHoldemRoom.GameStage.River));
    // }

    // function test_HandReveal() public {
    //     // Setup game
    //     vm.prank(player1);
    //     room.joinGame();
    //     vm.prank(player2);
    //     room.joinGame();

    //     vm.prank(player1);
    //     room.startNewHand();

    //     // Progress to showdown
    //     vm.prank(player1);
    //     room.submitAction(TexasHoldemRoom.Action.Call, 0);
    //     vm.prank(player2);
    //     room.submitAction(TexasHoldemRoom.Action.Check, 0);

    //     vm.prank(player1);
    //     room.submitAction(TexasHoldemRoom.Action.Check, 0);
    //     vm.prank(player2);
    //     room.submitAction(TexasHoldemRoom.Action.Check, 0);

    //     vm.prank(player1);
    //     room.submitAction(TexasHoldemRoom.Action.Check, 0);
    //     vm.prank(player2);
    //     room.submitAction(TexasHoldemRoom.Action.Check, 0);

    //     vm.prank(player1);
    //     room.submitAction(TexasHoldemRoom.Action.Check, 0);
    //     vm.prank(player2);
    //     room.submitAction(TexasHoldemRoom.Action.Check, 0);

    //     // Test hand reveal
    //     PokerHandEvaluator.Card[2] memory cards = [
    //         PokerHandEvaluator.Card(14, 0), // Ace of Hearts
    //         PokerHandEvaluator.Card(13, 0) // King of Hearts
    //     ];
    //     bytes32 secret = bytes32(uint256(1));
    //     bytes32 commitment = keccak256(abi.encode(cards, secret));

    //     vm.startPrank(player1);
    //     room.submitCardsCommitment(commitment);
    //     room.revealCards(cards, secret);
    //     vm.stopPrank();
    // }
}
