// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import "../src/TexasHoldemRoom.sol";
import "../src/PokerHandEvaluatorv2.sol";
import "../src/BigNumbers/BigNumbers.sol";
import "../src/CryptoUtils.sol";

// REQUIRED: in TexasHoldemRoom.sol, change uint256 public constant MIN_PLAYERS = 3;

contract TexasHoldemRoom3pRealKeysShuffledOnceTest is Test {
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

    BigNumber publicKey3;
    BigNumber privateKey3;
    BigNumber c1p3;
    BigNumber r3;
    BigNumber c1InversePowPrivate3;
    bytes[] encryptedDeck3bytes;

    function setUp() public {
        cryptoUtils = new CryptoUtils();
        pokerHandEvaluator = new PokerHandEvaluatorv2();
        room = new TexasHoldemRoom(address(cryptoUtils), SMALL_BLIND, false);
        deckHandler =
            new DeckHandler(address(room), address(cryptoUtils), address(pokerHandEvaluator));
        room.setDeckHandler(address(deckHandler));
        encryptedDeck1bytes = new bytes[](52);
        encryptedDeck2bytes = new bytes[](52);
        encryptedDeck3bytes = new bytes[](52);
        encryptedDeck1bytes[0] =
            hex"854b128f84d272c2e132db398fc19a3905b9c4a5ec6badd8ca0a2c3c3cb416e4";
        encryptedDeck1bytes[1] =
            hex"953d1e8753d499461248cc01e481fc4e72b561d2cb33428b2f87befd3afe6415";
        encryptedDeck1bytes[2] =
            hex"212354186ad56ef108162a8bb3ce414d08cd57dab883f049c8cfd99345c95f42";
        encryptedDeck1bytes[3] =
            hex"7b7614696aa42dea5ad60aa5beb7e547f0916a46b836f6cfa584b5b0067d0628";
        encryptedDeck1bytes[4] =
            hex"5d8c9b7587cea0e9c4822d5d9c68ae26a37e60c71199fb746d3601c3a7f7b688";
        encryptedDeck1bytes[5] =
            hex"90845a3c02e15fa9a3a367d44400dd9ca73b59f22bb67e774d7354066bd6ba5c";
        encryptedDeck1bytes[6] =
            hex"68c5e32205dd8dd086f2b9f850a7f18a44fff61350e4cc12f09f298dd71a5a00";
        encryptedDeck1bytes[7] =
            hex"17b1cb81c8eefbb82acb623072cc03e971d94819798a682204a703a5a77a0bd0";
        encryptedDeck1bytes[8] =
            hex"70a0424c64dd12a3417786439a801971cd441f986e27551282782e846f421ffa";
        encryptedDeck1bytes[9] =
            hex"99f5e2d2a4c7d2e280ee302f85031b003e2f69b36ab0069f119c29f40a260dce";
        encryptedDeck1bytes[10] =
            hex"0c150e45d2983d31bf48cd5d2e8548f85223682f450468a220e13b3ce06fab0e";
        encryptedDeck1bytes[11] =
            hex"fe1da149bec4d6b45a0ae0dd60f673ec3b1bd67e9e97c42e12d67c9d0110c570";
        encryptedDeck1bytes[12] =
            hex"df9dd2e084a131bc33f2bb539aab3e33ed7dd711ec1eb45ea6bf0858fd67bdca";
        encryptedDeck1bytes[13] =
            hex"7bd989f8e2ebff8a03e812de4ebf5cd56ec5b4e4ad7225b105e1564e9e64c372";
        encryptedDeck1bytes[14] =
            hex"a0766633d1e3862cd4b9589c98c13fb21436f71f0a7e1329b2f0e6c76a21078d";
        encryptedDeck1bytes[15] =
            hex"58d3d72a36db674d55dcc92ffbe78f74d80458e6721d37608b2196ccd8d00ccf";
        encryptedDeck1bytes[16] =
            hex"cceda1991fda91a2600f6aa62c9b4a7641ec62de84cc89a1f1d97c36ce0511a2";
        encryptedDeck1bytes[17] =
            hex"c1b459eca1cba4bb9d9ede0b785c0712a06acd924581b9036e70546c9ee26e2a";
        encryptedDeck1bytes[18] =
            hex"f964dcfe6dd19d17eb657cafc075553a6fa1ce9dff1b001a30c211a631e91bb7";
        encryptedDeck1bytes[19] =
            hex"43c591579e9e358e0d0f6c01769e9720215a693afe9dafb8e332f8767376589b";
        encryptedDeck1bytes[20] =
            hex"25dc1863bbc8a88d76bb8eb9544f5ffed4475fbb5800b45daae4448a14f108fb";
        encryptedDeck1bytes[21] =
            hex"c834dd4dcee75805f16a06788c1a2bc476725afde54fc58e0fc5113ffedd67e9";
        encryptedDeck1bytes[22] =
            hex"113148209bd3486dd70039c35f0ddf379bd1baadd9bc5b97635246d2477f1211";
        encryptedDeck1bytes[23] =
            hex"3115601039d79574392c1b54088ea36275c8f507974b84fc2e4d6c544413ac73";
        encryptedDeck1bytes[24] =
            hex"2c5c9bc4e8e45bd7ca86b726680d84b0aa4eed26f7cec0e84c39015d74ec02ba";
        encryptedDeck1bytes[25] =
            hex"388c49ab208f48a74a9edf66c25f53bc7fd8d3eebf52df1a5fc9d0ac4453b523";
        encryptedDeck1bytes[26] =
            hex"e972d1069ecf7694ba4f8be76bb4f32502a6317120536b67cb447ee5339ece86";
        encryptedDeck1bytes[27] =
            hex"049e24aaebe089feadd6094a74b4989e481389481cfd0e83ef64d6e4e02fa25e";
        encryptedDeck1bytes[28] =
            hex"1c6a8fcd19e235549970c65e134d229b3d534ffa19072c35e6bb6e9c76a1b589";
        encryptedDeck1bytes[29] =
            hex"174e55f250a72a1881b959f7e2c48c5bf3a4fd7b844f3940a44a63070f924e86";
        encryptedDeck1bytes[30] =
            hex"48e1cb3267d940ca24c6d867a7272d5f6b08bbb99355a2ae25a4040bda85bf9e";
        encryptedDeck1bytes[31] =
            hex"a7ed4fceb89b395fe62c1caf5291f00c1e46d60632856d47e46d4b1f6a61103d";
        encryptedDeck1bytes[32] =
            hex"541b12dee5e82db0e73765025b6670c30c8a5105d2a0734ca90d2bd609a86316";
        encryptedDeck1bytes[33] =
            hex"bcfb95a150d86b1f2ef979ddd7dae860d4f0c5b1a604f4ef8c5be975cfbac471";
        encryptedDeck1bytes[34] =
            hex"d4648b34069244d571822eb8e66bfad04bfc41c5acd3e3c02355e08ece451a52";
        encryptedDeck1bytes[35] =
            hex"9d177db1b2d41e18cccd984d2e5a2435faf98b57e875cb8ac160c3f3d3262a0f";
        encryptedDeck1bytes[36] =
            hex"703cccbcec95410398657e0b0a78a1e44f0fd4fa78ec2631221b8de5d75a62b0";
        encryptedDeck1bytes[37] =
            hex"38efbf3a98d71a46f3b0e79f5266cb49fe0d1e8cb48e0dfbc026714adc3b726d";
        encryptedDeck1bytes[38] =
            hex"b842d155ffe53182c05415b03759c9af0976bdd1068830dbaa477e7f00931ab8";
        encryptedDeck1bytes[39] =
            hex"e001486ffce9035bdd04c38c2ab2b5c16bb221afe159e340071ba8f7954f7b14";
        encryptedDeck1bytes[40] =
            hex"4d9a8f7db8cc7a66936c3c9547a84c113682c39a32d266c207b86f02a9ad6957";
        encryptedDeck1bytes[41] =
            hex"eff35467cbeb29df0e1ab4547f7317d6d8adbedcc02177f26c993bb89399c845";
        encryptedDeck1bytes[42] =
            hex"0c7883d54ae00ed1685ad595be8cc085d057b2cd3a3f9783813ddbdb78576858";
        encryptedDeck1bytes[43] =
            hex"75590697b5d04c3fb01cea713b01382398be27790da41926648c997b3e69c9b3";
        encryptedDeck1bytes[44] =
            hex"80924e4433df3926728d770bef407b873a3fbcc54ceee9c4e7f5c1456d8c6d2b";
        encryptedDeck1bytes[45] =
            hex"e4ba0cbb4ddc3cf84baa27b9cb33d473372c299080d6a753e93013ee647724cd";
        encryptedDeck1bytes[46] =
            hex"f4ac18b31cde637b7cc018821ff43688a427c6bd5f9e3c064eada6af62c171fe";
        encryptedDeck1bytes[47] =
            hex"ad0989a981d6449bfde38915831a864b67f52884c73d603d26de56b4d1707740";
        encryptedDeck1bytes[48] =
            hex"d4c800c37eda16751a9436f17673725dca308c63a20f12a183b2812d662cd79c";
        encryptedDeck1bytes[49] =
            hex"b326977b36aa2646a89ca94a06d1336fbfc86b5271d03de667d672e99983b3b5";
        encryptedDeck1bytes[50] =
            hex"a850c55e30e30aff8f3e24e7e29967999c7b20a427c09c2944c9ebbe0248cd87";
        encryptedDeck1bytes[51] =
            hex"442906e716e6072db621743a06a60ead9f8eb3d8f3d8de9a438f99150b5e15e5";
        encryptedDeck2bytes[0] =
            hex"d8b18da042da8772e330654808cf7824e90f024b4a497912cbccb360a8b201ff";
        encryptedDeck2bytes[1] =
            hex"d83b14910f71674890a30ea9d6a9836832f30704b10722c008bff4326c5e4291";
        encryptedDeck2bytes[2] =
            hex"b91c6c61ef84e3e557bcb5a772777750defc40c010f4a31249f02b39bd50e172";
        encryptedDeck2bytes[3] =
            hex"6805a530391c390f565ce67a21d583d253747a793cfd2ca5e74b070021a0c46f";
        encryptedDeck2bytes[4] =
            hex"98a59ad88221a125c6ce43bd0a86ad71f541bb07039d11d2345f8efaddf9d3e0";
        encryptedDeck2bytes[5] =
            hex"48abc0797f7b2596f42fe228a4907d5ca46fb691504981cec6f4de7054698399";
        encryptedDeck2bytes[6] =
            hex"0ae4e92a730b3efad4f086c20e5259eab29e254ea966d8c60c620bad32a280c9";
        encryptedDeck2bytes[7] =
            hex"2834eef01217e2d76341703e3c9fb37dbab530d842f1f08eb164423175127607";
        encryptedDeck2bytes[8] =
            hex"f759bcc02f5deaabc98967ac3adb8f7f86e9cd495119a26dc78fbd2b1b6ba3b0";
        encryptedDeck2bytes[9] =
            hex"86e910d7bf542c5d65fc942d6cf4958b4c5d431a906e812a44947061b28445d7";
        encryptedDeck2bytes[10] =
            hex"ec017d82ecd34bacc550d90ec333483182c5374f775e467673df04d7229b1c32";
        encryptedDeck2bytes[11] =
            hex"f80b7256fc7b9aeb455d699986147e9a9813c63336fd23e9ec22dbf075e942d5";
        encryptedDeck2bytes[12] =
            hex"f794f947c9127ac0f2d012fb53ee89dde1f7caec9dbacd9729161cc239958367";
        encryptedDeck2bytes[13] =
            hex"9a743d42030180ac7163b343406b5ff6412175c20a2479b74e2d216f4a973fc1";
        encryptedDeck2bytes[14] =
            hex"167864ef4f4a6e0f026fc0ae9f0d9b9711d0b8ebcfc35fe6c1992398499ce7fe";
        encryptedDeck2bytes[15] =
            hex"f7d035cf62c70ad61c16be4a6d01843c3d05c88fea5bf8c08a9c7c5957bf631e";
        encryptedDeck2bytes[16] =
            hex"29c854d1f9433248e490347559716ba3ab86edeffcd82d4a69ab750ec3860231";
        encryptedDeck2bytes[17] =
            hex"87244d5f5908bc728f433f7c86078fe9a76b40bddd0fac53a61acff8d0ae258e";
        encryptedDeck2bytes[18] =
            hex"9a3900ba694cf097481d07f427586597e613781ebd834e8deca6c1d82c6d600a";
        encryptedDeck2bytes[19] =
            hex"d8ecca27dc8f17880c77109721e27283441cffee96eaa43c2d5312f7c6dbe1b6";
        encryptedDeck2bytes[20] =
            hex"a607b906df40afc09ee2ed2fd126a1a2a054095f308100d80364395a6191a6f6";
        encryptedDeck2bytes[21] =
            hex"0aa9aca2d956aee5aba9db72f53f5f8c579027ab5cc5ad9caadbac161478a112";
        encryptedDeck2bytes[22] =
            hex"6840e1b7d2d0c9247fa391c93ae87e30ae82781c899e57cf48d166973fcaa426";
        encryptedDeck2bytes[23] =
            hex"68b75ac70639e94ed230e8676d0e72ed649e736322e0ae220bde25c57c1e6394";
        encryptedDeck2bytes[24] =
            hex"15203b9501d3aeb2aa67a7c69b4eddcf7c0cf977627e4e546ad8505219533b8b";
        encryptedDeck2bytes[25] =
            hex"2a3ecde12cac5273371d8b138b97606061a2e936961a839d2cb8343cffd9c19f";
        encryptedDeck2bytes[26] =
            hex"16b3a176e8fefe242bb66bfdb82095f56cdeb68f1c648b10231f832f67c6c7b5";
        encryptedDeck2bytes[27] =
            hex"4753971f3204663a9c27c940a0d1bf950eabf71ce304703c70340b2a241fd726";
        encryptedDeck2bytes[28] =
            hex"7b90d19a7cc98d5e61c4058ff54c4e3d4838ad20b6b32532f0e3b80db9b3be59";
        encryptedDeck2bytes[29] =
            hex"49223988b2e445c146bd38c6d6b672195a8bb1d7e98bd8218a019d9e90bd4307";
        encryptedDeck2bytes[30] =
            hex"d92806af7643a79d35bdbbe63af56ce19f2afd91e38bcf658ed9728ee505c16d";
        encryptedDeck2bytes[31] =
            hex"d6e2eb36c1faa7ec389af5c1d2eac5a09d2f479043c2112db1ff20ec3c14961e";
        encryptedDeck2bytes[32] =
            hex"298d184a5f8ea233bb498926405e71455078f04cb037022108251577a55c227a";
        encryptedDeck2bytes[33] =
            hex"2a03915992f7c25e0dd6dfc4728466020694eb9349795873cb31d4a5e1afe1e8";
        encryptedDeck2bytes[34] =
            hex"0b2025b20cbfcf0ffe373211276554490dac22f1f60803ef6de86b4450cc6080";
        encryptedDeck2bytes[35] =
            hex"9aaf79c99cb610c19aaa5e92597e5a549c2f736556c5a4e0afb3810668c11f78";
        encryptedDeck2bytes[36] =
            hex"495d76104c98d5d67003e415efc96c77b599af7b362d034aeb87fd35aee722be";
        encryptedDeck2bytes[37] =
            hex"b992e57122ee040faa4a0c45a49d6c0d95183c06aa36f9650cfcea67f9a4a0e0";
        encryptedDeck2bytes[38] =
            hex"8590e77d71dd6d010df47b456935d7c3b69983a623296f97edd39d1b823a9964";
        encryptedDeck2bytes[39] =
            hex"99fdc432cf9860821ed65ca50e456b398b057a7b70e223648b2062410e438053";
        encryptedDeck2bytes[40] =
            hex"d8765118a925f75db9e9b9f8efbc7dc68e0104a7fda84de96a4653c98a882248";
        encryptedDeck2bytes[41] =
            hex"67ca68a89f67a8fa2d163b2b08c28973f8667cd5f05c017c85c4a7690376e4b8";
        encryptedDeck2bytes[42] =
            hex"875f89e6f2bd4c87b889eacb9f1a8a4802793e6129b0d77d07a12f8feed80545";
        encryptedDeck2bytes[43] =
            hex"b9ce21f8bca29424d390b794bdb0666bf02639a9f6d8248e6e8349ff17ce8097";
        encryptedDeck2bytes[44] =
            hex"687c1e3f6c855939a8ea3d1853fb788f099075bfd63f82f8aa57c62e5df483dd";
        encryptedDeck2bytes[45] =
            hex"f6019365e1e72b4f71814ec4371cd1b7f1260dd4e3d490db70cee9e4eb21f73d";
        encryptedDeck2bytes[46] =
            hex"b7c44307a20e2488ffb49cbf6eb8b9894938814ba3af917ff32f57f38d0734ff";
        encryptedDeck2bytes[47] =
            hex"091646c0f22b5f742a5b173bd86da76666be6a93a2df70e0f2947938c60514e8";
        encryptedDeck2bytes[48] =
            hex"48e6fd01192fb5ac1d768d77bda377baff7db4349ceaacf8287b3e0772936350";
        encryptedDeck2bytes[49] =
            hex"7b559512e314fd49387d5a40dc3953deed2aaf7d6a11fa098f5d58769b89dea2";
        encryptedDeck2bytes[50] =
            hex"66723f4e51f0e99dd50e22430503cbac62a2bd618316efea2f03d422d32d3845";
        encryptedDeck2bytes[51] =
            hex"b957a8e9893973fa810360f68b8a71af3a0a3e635d95ce3bab768ad0db7ac129";
        encryptedDeck3bytes[0] =
            hex"4a27ad8d2b33a33c8958f17fb353f8e82d7001e15b35eba6076e25c50bf01474";
        encryptedDeck3bytes[1] =
            hex"af9ab142ab106d0049d7da57afa705819ebdaccf40db3fb4f671444696a7d8b1";
        encryptedDeck3bytes[2] =
            hex"135e9ae632bc64458decb6fabfeabab4ca94898b9398e6769ea83033d413e31a";
        encryptedDeck3bytes[3] =
            hex"e3d4244dcd7ba38fff647d5919c5174720da12feec60385c550f4f5f6fe1a1c4";
        encryptedDeck3bytes[4] =
            hex"f6a51554fd211c6ac79b3645b0e1d7edf10d80cf57290e58108f087dce6663a5";
        encryptedDeck3bytes[5] =
            hex"15ee3a8208c86cacd3cc4e7e4935e722ab539bb1afb0f2fea8d01aac32b64b61";
        encryptedDeck3bytes[6] =
            hex"a841bc547b26a667919caa12c1060fcfad19496769e387e569395d9bcd456693";
        encryptedDeck3bytes[7] =
            hex"80807d6f34bd473f200a665d581f4c97de1f6aebcd86601dac230e1e7ab2e02c";
        encryptedDeck3bytes[8] =
            hex"1a9d36f4c5f2e286fad0b7de0d2e557abaa5b0b292947b56f90ee26526e1b64d";
        encryptedDeck3bytes[9] =
            hex"fe6e4d081bf87df7e4912c31ee20b82394ddf382836d56df61d7fc6060e23b65";
        encryptedDeck3bytes[10] =
            hex"61a79b07180391f1789413cc0e6927e70cf584b2a8e249fa132ca69c5ea04141";
        encryptedDeck3bytes[11] =
            hex"301820776857ac20543e37afcef39d7b6d2b6ce9f17180c9f187ba755a9d7f60";
        encryptedDeck3bytes[12] =
            hex"c78ae18186cdf6a99dcdc24b595a1f04306f3eebe3d42ec0c640d255b2716b20";
        encryptedDeck3bytes[13] =
            hex"d9eb8fc3c785d4900149b590a1d8f5274e769d70f9507404bdaf7e3c47dcc75f";
        encryptedDeck3bytes[14] =
            hex"645193828ac2e2b009cadab13911af40ef47d3199cf679715025c58e33d74873";
        encryptedDeck3bytes[15] =
            hex"180d9758efe6da1fb4f1205a83e3290cd9e69e8c767c6eceeee6f7ecc83f4e06";
        encryptedDeck3bytes[16] =
            hex"c4fb41e5b0c1ee4257ee2ac7d00ef2964fb02cc5c7bc2238bc18e7dd53cf02d9";
        encryptedDeck3bytes[17] =
            hex"32a7c0133e63b4879a1dcf33583ec9e94dea7f100d898d51fbafa4edb93fe7a7";
        encryptedDeck3bytes[18] =
            hex"28348fe4accd023bebf11261f0576259c7c7bdf5ed3115536d6d9219518d08b5";
        encryptedDeck3bytes[19] =
            hex"93516e766462c019e8411f49ef3c0d3eae52d8bc384f361967a2c73cd937a20d";
        encryptedDeck3bytes[20] =
            hex"10b4a26abffd1386fcb5f0159542335ae8423b249f84b6ff61af1141fedcdbe8";
        encryptedDeck3bytes[21] =
            hex"b22a50de811c75678fb771db38f231ef7f7cbef55cf34c3d00992ebef54a40f8";
        encryptedDeck3bytes[22] =
            hex"49b76ac83c460848249e2bd864b60e647b43f29605e95aee435d188d42d6aed2";
        encryptedDeck3bytes[23] =
            hex"8e17d65f1b9766f4112ac0e13b485976eb41782f2822fa1a2081bdd2a55e3294";
        encryptedDeck3bytes[24] =
            hex"f934b4f0d32d24d20d7acdc93a2d045bd1cc92f573411ae01ab6f2f62d08cbec";
        encryptedDeck3bytes[25] =
            hex"9b1aa629833a21a7053715362c7aed7452234b6f64937ea0b8ebbb1f6bb379cd";
        encryptedDeck3bytes[26] =
            hex"7e6120984d9ed9cc3ee594811d720aadaf8c681106bae44d660c30dde529dd87";
        encryptedDeck3bytes[27] =
            hex"2ade88601f8c52fa7d27d9471affe9b3aa1a0c5ce14544caaa66b10b26c40fe7";
        encryptedDeck3bytes[28] =
            hex"ad7b546bc3f1ff8d68b3087b74f9c397702aa9f47a0fc3e4b05a6706011ed60c";
        encryptedDeck3bytes[29] =
            hex"e1b4c776e65d361d1e3fab7cdf17d55cf24710242594bc8c0ef8721eda589f1f";
        encryptedDeck3bytes[30] =
            hex"7df0ddd35eb13ed7da2aced9ced42029fd6058c5b16e5395a1fb23a61c1077e5";
        encryptedDeck3bytes[31] =
            hex"dc7b2f5f9d91dcf747294d142b2421952f35af971568808cc7d768b4a67f2fa6";
        encryptedDeck3bytes[32] =
            hex"90c1ceda8e56b7b2a26187c665f0e0d0cd93c6961c3729915d7adcc47a9539c6";
        encryptedDeck3bytes[33] =
            hex"4c470a64125210af6a7dc35bee013ad25c0304bc220167764d850305a1791719";
        encryptedDeck3bytes[34] =
            hex"0e2502cee9f10b1fb6d658920bf706ed078328fe836caa77578726c9a03a73a1";
        encryptedDeck3bytes[35] =
            hex"aad15bf05132aeced77c41964a513c3d8dd85b8d85fb946d736148142be7ceda";
        encryptedDeck3bytes[36] =
            hex"ccc47998cf994fcf74e420b40d4dd2cbf3809f78f4006ac00d61dbbfe64ada99";
        encryptedDeck3bytes[37] =
            hex"e4446712bc693e84641f4300686301cad306224a41acc91419205c9738fb0766";
        encryptedDeck3bytes[38] =
            hex"44ee1575e2684a16b2429316ff6045206a5ea1544b09afa6c04d1c5ad816a4fb";
        encryptedDeck3bytes[39] =
            hex"988b068dad2e193fbf577db2a32fc10671643949487b7218aec3d0a70d111186";
        encryptedDeck3bytes[40] =
            hex"ca34d9fcf98d47682f0489308402a65e12c18d52d7e85e380339f14787a87252";
        encryptedDeck3bytes[41] =
            hex"47980df155279ad5437959fc2a08cc7a4cb0efbb3f1ddf1dfd463b4cad4dac2d";
        encryptedDeck3bytes[42] =
            hex"2d6e27fbf5985b61c30770caa44b16218ad91e82fd5d5152b48e9b838566782e";
        encryptedDeck3bytes[43] =
            hex"00fdeca3f204865f2a70c3b5776be491ac8d2b067e1ca132a739844d3ea886db";
        encryptedDeck3bytes[44] =
            hex"5f17fb6b41f7898a32b47c48851dfb792c36728c8cca3d720904bc23fffdd8fa";
        encryptedDeck3bytes[45] =
            hex"7408494958bb6fd7dc10071156e7fe0a2afce337be5e8f3e0a9b5282f40b9d80";
        encryptedDeck3bytes[46] =
            hex"425e75da0c5c41af6c62fb93761518b2899f8f2e2ef1a31eb62531e279743cb4";
        encryptedDeck3bytes[47] =
            hex"7bd180fc7792d164f905fcfd9426de3fcecd55eaeaa2d7c55be4466586877540";
        encryptedDeck3bytes[48] =
            hex"e663c3e9a387abf7454414dca31043b501992525087844e45f3739d7ce840a0b";
        encryptedDeck3bytes[49] =
            hex"66e1331e60ceeb174faa7234c25cdbaed006e53fb90e85f95a4db0069279b0ba";
        encryptedDeck3bytes[50] =
            hex"7697e8e52ec7783f21ef9e94e0332a780bbbf55dda769bc614c33cfb52ae05c7";
        encryptedDeck3bytes[51] =
            hex"b00af40799fe07f4ae929ffefe44f00550e9bc1a9627d06cba82517e5fc13e53";

        // bytes memory c1p1bytes =
        //     hex"69b481a9459039ebf5a46f511f7312a204b53a633d64563347fed740e5f9feeb";
        // bytes memory r1bytes = hex"ef964d7bee8b0cdcaae8dbfdb5fc2b193a2f11c2da5e874979e89aae868a4014";
        // bytes memory c1InversePowPrivateKey =
        //     hex"83fc50dac2ee8ad98c4bc0872593bd432ee27a5d1ad90b19b3d824b9de08a621";

        // bytes memory publicKey2bytes =
        //     hex"fcf8341cefd3f559b2f0f48935b5043e009c35a6dc13cc18b1173db3090b28a8";
        // bytes memory privateKey2bytes =
        //     hex"f87a3cbf05aab6ef9c94afdceb5a8af7317d5474587ce7ac4a1a836c2f3fb423";
        // bytes memory c1p2bytes =
        //     hex"812190a41ff041bf544eb465ff7557c23080bdb2cf17fd521015adaaf7152b32";
        // bytes memory r2bytes = hex"782ea8d386effebcae8fa1d390f26e6839864c6e56c01827e30071f6541efe7d";
        // bytes memory c1InversePowPrivateKey2 =
        //     hex"8e80f2b7cc46fb0f66e1365695da1cfe4245dc6c7b1433585217bc102a51a171";

        // bytes memory publicKey3bytes =
        //     hex"684e23d6a2aaf120915743091e8d8bce49a10777fe17ff733f066f6da024e39d";
        // bytes memory privateKey3bytes =
        //     hex"666a6233679d309343e1b608f1fb411fe49b5e6ce2dce728deec912f90453188";
        // bytes memory c1p3bytes =
        //     hex"45349718e42ebca41087d31720be5d4ca264ba8b5109ac8ce461aff54f8df4a8";
        // bytes memory r3bytes = hex"10c51fc72e0803cb9e161dc9ecb3cf0c0d0130bba7343dba7534c392db107512";
        // bytes memory c1InversePowPrivateKey3 =
        //     hex"8e80f2b7cc46fb0f66e1365695dd9414a26b9a1cc8f82dc7b638f08245e8485840ec8f8a10d8b04e895c6ac6f35a1cfe4245dc6c7b1433585217bc102a51a171";

        // 1
        publicKey1 = BigNumbers.init(
            hex"e339067d976a1255b11d761d52d8ffd9a64c98903b2dbe78a03be5cd94cfb8d9", false
        );
        privateKey1 = BigNumbers.init(
            hex"7f008f236006eede4a6e026e49cd1a7eeadac0e36088858e84545c16c1469e6e", false
        );
        c1p1 = BigNumbers.init(
            hex"69b481a9459039ebf5a46f511f7312a204b53a633d64563347fed740e5f9feeb", false
        );
        r1 = BigNumbers.init(
            hex"ef964d7bee8b0cdcaae8dbfdb5fc2b193a2f11c2da5e874979e89aae868a4014", false
        );
        c1InversePowPrivate1 = BigNumbers.init(
            hex"83fc50dac2ee8ad98c4bc0872593bd432ee27a5d1ad90b19b3d824b9de08a621", false
        );
        // 2
        publicKey2 = BigNumbers.init(
            hex"fcf8341cefd3f559b2f0f48935b5043e009c35a6dc13cc18b1173db3090b28a8", false
        );
        privateKey2 = BigNumbers.init(
            hex"f87a3cbf05aab6ef9c94afdceb5a8af7317d5474587ce7ac4a1a836c2f3fb423", false
        );
        c1p2 = BigNumbers.init(
            hex"812190a41ff041bf544eb465ff7557c23080bdb2cf17fd521015adaaf7152b32", false
        );
        r2 = BigNumbers.init(
            hex"782ea8d386effebcae8fa1d390f26e6839864c6e56c01827e30071f6541efe7d", false
        );
        c1InversePowPrivate2 = BigNumbers.init(
            hex"8e80f2b7cc46fb0f66e1365695da1cfe4245dc6c7b1433585217bc102a51a171", false
        );
        // 3
        publicKey3 = BigNumbers.init(
            hex"684e23d6a2aaf120915743091e8d8bce49a10777fe17ff733f066f6da024e39d", false
        );
        privateKey3 = BigNumbers.init(
            hex"666a6233679d309343e1b608f1fb411fe49b5e6ce2dce728deec912f90453188", false
        );
        c1p3 = BigNumbers.init(
            hex"45349718e42ebca41087d31720be5d4ca264ba8b5109ac8ce461aff54f8df4a8", false
        );
        r3 = BigNumbers.init(
            hex"10c51fc72e0803cb9e161dc9ecb3cf0c0d0130bba7343dba7534c392db107512", false
        );
        c1InversePowPrivate3 = BigNumbers.init(
            hex"d9414a26b9a1cc8f82dc7b638f08245e8485840ec8f8a10d8b04e895c6ac6f35", false
        );

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
        // Players join the game
        vm.startPrank(player1);
        room.joinGame();
        vm.stopPrank();

        vm.startPrank(player2);
        room.joinGame();
        vm.stopPrank();

        vm.startPrank(player3);
        room.joinGame();
        vm.stopPrank();

        // Verify the players' index and seat positions
        TexasHoldemRoom.Player[] memory players = room.getPlayers();
        assertEq(players[0].addr, player1);
        assertEq(players[1].addr, player2);
        assertEq(players[2].addr, player3);
        assertEq(players[0].seatPosition, 0);
        assertEq(players[1].seatPosition, 1);

        assertEq(room.getNextActivePlayer(true), 1);
        // assertEq(room.getNextActivePlayer(1, true), 0);
        assertEq(room.getNextActivePlayer(false), 1);
        // assertEq(room.getNextActivePlayer(1, false), 0);
    }

    // For one player submit: (gas: 3,486,222) to save state (and emit event)
    // For one play submit: (gas: 768,315) to just emit event
    function test_RealKeysShuffle3Players256bit() public {
        console.log("test_RealKeysShuffle3Players256bit");

        // Players join the game
        vm.startPrank(player1);
        room.joinGame();
        vm.stopPrank();

        vm.startPrank(player2);
        room.joinGame();
        vm.stopPrank();

        vm.startPrank(player3);
        room.joinGame();
        vm.stopPrank();

        // Verify that the game state is now in the shuffle phase
        TexasHoldemRoom.GameStage stage2 = room.stage();
        assertEq(uint256(stage2), uint256(TexasHoldemRoom.GameStage.Shuffle));
        assertEq(room.dealerPosition(), 0);
        assertEq(room.currentPlayerIndex(), 0);

        // START submit encrypted shuffle
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

        vm.startPrank(player2);
        for (uint256 i = 0; i < 52; i++) {
            encryptedShuffleBytes[i] = encryptedDeck2bytes[i];
        }
        deckHandler.submitEncryptedShuffle(encryptedShuffleBytes);
        vm.stopPrank();
        vm.startPrank(player3);
        for (uint256 i = 0; i < 52; i++) {
            encryptedShuffleBytes[i] = encryptedDeck3bytes[i];
        }
        deckHandler.submitEncryptedShuffle(encryptedShuffleBytes);
        vm.stopPrank();
        // END submit encrypted shuffle

        // Verify that the game state is now in the deal phase
        TexasHoldemRoom.GameStage stage3 = room.stage();
        assertEq(uint256(stage3), uint256(TexasHoldemRoom.GameStage.RevealDeal));
        assertEq(room.dealerPosition(), 0);
        assertEq(room.currentPlayerIndex(), 0);

        // player 1 should submit their decryption values for player 2 and 3's cards
        vm.startPrank(player1);
        // the encrypted values submitted are not correct at the moment
        // submit card index and decrypted value for each card
        // card 0 to p1, card 1 to p2, card 2 to p1, card 3 to p2!
        uint256[] memory cardIndexes = new uint256[](4);
        BigNumber[] memory decryptionValues = new BigNumber[](4);
        cardIndexes[0] = 1;
        cardIndexes[1] = 2;
        cardIndexes[2] = 4;
        cardIndexes[3] = 5;
        decryptionValues[0] = BigNumbers.init(
            hex"528ecd9daf4b3e96d9ed977c703c08b12c4dafa6f97388191bdf900ca9686459", false
        );
        decryptionValues[1] = BigNumbers.init(
            hex"11af01d7927d2ad50c3c2d90d0afc58aed179044395afb42a2bfbdb95b14c1bb", false
        );
        decryptionValues[2] = BigNumbers.init(
            hex"d2486f463e8fa01606f370b329977ff332b531712aedb7b636ad4fc2a2d014ba", false
        );
        decryptionValues[3] = BigNumbers.init(
            hex"41c965385cc386455b59fc1c4b2d78d21616b1953354723b827cfac96de06a65", false
        );
        bytes[] memory decryptionValuesBytes = new bytes[](4);
        decryptionValuesBytes[0] = decryptionValues[0].val;
        decryptionValuesBytes[1] = decryptionValues[1].val;
        decryptionValuesBytes[2] = decryptionValues[2].val;
        decryptionValuesBytes[3] = decryptionValues[3].val;
        deckHandler.submitDecryptionValues(cardIndexes, decryptionValuesBytes);
        vm.stopPrank();
        console.log("Player 1 submitted decryption values");

        assertEq(room.currentPlayerIndex(), 1, "Player 2 should be the current player");

        // player 2 should submit their decryption values for player 1 and 3's cards
        vm.startPrank(player2);
        cardIndexes[0] = 0;
        cardIndexes[1] = 2;
        cardIndexes[2] = 3;
        cardIndexes[3] = 5;
        decryptionValues[0] = BigNumbers.init(
            hex"2d9436d5424acf2c5b885507182f2412746ccab8ec8a7bc2337d3c28f4757d9e", false
        );
        decryptionValues[1] = BigNumbers.init(
            hex"596fbb6d2e754f4257d3e16c37c652557652ca83c35b50809e196a9a3514909d", false
        );
        decryptionValues[2] = BigNumbers.init(
            hex"49e4b273842ecff70595560aa18e0b41716c7d7d791225e83473b71073d25a03", false
        );
        decryptionValues[3] = BigNumbers.init(
            hex"dc4cc6e6ce098d94c5b1d51a06f1cf899c20ee684d6531f0b49109e2c096883c", false
        );
        bytes[] memory decryptionValuesBytes2 = new bytes[](4);
        decryptionValuesBytes2[0] = decryptionValues[0].val;
        decryptionValuesBytes2[1] = decryptionValues[1].val;
        decryptionValuesBytes2[2] = decryptionValues[2].val;
        decryptionValuesBytes2[3] = decryptionValues[3].val;
        deckHandler.submitDecryptionValues(cardIndexes, decryptionValuesBytes2);
        vm.stopPrank();
        console.log("Player 2 submitted decryption values");

        // player 3 should submit their decryption values for player 1 and 2's cards
        vm.startPrank(player3);
        cardIndexes[0] = 0;
        cardIndexes[1] = 1;
        cardIndexes[2] = 3;
        cardIndexes[3] = 4;
        decryptionValues[0] = BigNumbers.init(
            hex"90845a3c02e15fa9a3a367d44400dd9ca73b59f22bb67e774d7354066bd6ba5c", false
        );
        decryptionValues[1] = BigNumbers.init(
            hex"1b080fc3b280cd58d3add4400e0f11c977beadfe3ed3c2cfe9b025523448bb72", false
        );
        decryptionValues[2] = BigNumbers.init(
            hex"43c591579e9e358e0d0f6c01769e9720215a693afe9dafb8e332f8767376589b", false
        );
        decryptionValues[3] = BigNumbers.init(
            hex"f2cc65438c7138fc8c40d86f6aaf614580e2f6a426dd00da73a5901f0c113c07", false
        );
        bytes[] memory decryptionValuesBytes3 = new bytes[](4);
        decryptionValuesBytes3[0] = decryptionValues[0].val;
        decryptionValuesBytes3[1] = decryptionValues[1].val;
        decryptionValuesBytes3[2] = decryptionValues[2].val;
        decryptionValuesBytes3[3] = decryptionValues[3].val;
        deckHandler.submitDecryptionValues(cardIndexes, decryptionValuesBytes3);
        vm.stopPrank();
        console.log("Player 3 submitted decryption values");

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

        // player 3 should submit their action
        assertEq(room.currentPlayerIndex(), 2);
        assertEq(room.lastRaiseIndex(), 1, "Player 2 should be the last raise index");
        console.log("Player 3 submitting check action");
        vm.startPrank(player3);
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
        cardIndexesFlop[0] = 7;
        cardIndexesFlop[1] = 8;
        cardIndexesFlop[2] = 9;
        decryptionValuesFlop[0] = BigNumbers.init(
            hex"11af01d7927d2ad50c3c2d90d0afc58aed179044395afb42a2bfbdb95b14c1bb", false
        );
        decryptionValuesFlop[1] = BigNumbers.init(
            hex"01a6360ca465b704f1dce8b7a7db347334c285293b5d28efad80a95eaa26342d", false
        );
        decryptionValuesFlop[2] = BigNumbers.init(
            hex"10dcd460b61d42f1cc46169f4c9c25f27b33ac9e30edb1ce56c5ef0ad50539cf", false
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
        decryptionValuesFlop[0] = BigNumbers.init(
            hex"596fbb6d2e754f4257d3e16c37c652557652ca83c35b50809e196a9a3514909d", false
        );
        decryptionValuesFlop[1] = BigNumbers.init(
            hex"2dd0b799f943e526dddf3adcf2b7d344146369379558055b4146e02cb13e9368", false
        );
        decryptionValuesFlop[2] = BigNumbers.init(
            hex"a3463bbbadbba4238d7c8e7057612336033757c445e8024c59e213e78f70fe2c", false
        );
        decryptionValuesBytesFlop[0] = decryptionValuesFlop[0].val;
        decryptionValuesBytesFlop[1] = decryptionValuesFlop[1].val;
        decryptionValuesBytesFlop[2] = decryptionValuesFlop[2].val;
        deckHandler.submitDecryptionValues(cardIndexesFlop, decryptionValuesBytesFlop);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 2);

        // player 3 submit flop values
        vm.startPrank(player3);
        decryptionValuesFlop[0] = BigNumbers.init(
            hex"0000000000000000000000000000000000000000000000000000000000000031", false
        );
        decryptionValuesFlop[1] = BigNumbers.init(
            hex"0000000000000000000000000000000000000000000000000000000000000030", false
        );
        decryptionValuesFlop[2] = BigNumbers.init(
            hex"0000000000000000000000000000000000000000000000000000000000003136", false
        );
        decryptionValuesBytesFlop[0] = decryptionValuesFlop[0].val;
        decryptionValuesBytesFlop[1] = decryptionValuesFlop[1].val;
        decryptionValuesBytesFlop[2] = decryptionValuesFlop[2].val;

        // Verfied FLOP REVEAL
        vm.expectEmit();
        emit DeckHandler.DecryptionValuesSubmitted(
            address(player3), cardIndexesFlop, decryptionValuesBytesFlop
        );
        vm.expectEmit();
        emit DeckHandler.FlopRevealed("1", "0", "16");
        deckHandler.submitDecryptionValues(cardIndexesFlop, decryptionValuesBytesFlop);
        vm.stopPrank();

        // We should be in the flop phase now
        assertEq(uint256(room.stage()), uint256(TexasHoldemRoom.GameStage.Flop));
        assertEq(room.currentPlayerIndex(), 1);
        assertEq(room.lastRaiseIndex(), 1);
        assertEq(room.dealerPosition(), 0);

        // test betting stage, player 2 checks, player 3 raises, player 1 raises, player 2 raises, player 3 calls, player 1 calls
        vm.startPrank(player2);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 2);
        assertEq(room.lastRaiseIndex(), 1);
        assertEq(room.currentStageBet(), 0);
        assertEq(room.pot(), 0);

        vm.startPrank(player3);
        room.submitAction(TexasHoldemRoom.Action.Raise, 10);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 0);
        assertEq(room.lastRaiseIndex(), 2);
        assertEq(room.currentStageBet(), 10);
        assertEq(room.pot(), 10);

        vm.startPrank(player1);
        room.submitAction(TexasHoldemRoom.Action.Raise, 20);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 1);
        assertEq(room.lastRaiseIndex(), 0); // p1 raised!
        assertEq(room.currentStageBet(), 20);
        assertEq(room.pot(), 30);

        vm.startPrank(player2);
        vm.expectRevert("Raise must be higher than current bet");
        room.submitAction(TexasHoldemRoom.Action.Raise, 10);
        room.submitAction(TexasHoldemRoom.Action.Raise, 100);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 2);
        assertEq(room.lastRaiseIndex(), 1); // p2 raised!
        assertEq(room.currentStageBet(), 100); // per player (to stay in the round)
        assertEq(room.pot(), 130); // total pot

        vm.startPrank(player3);
        room.submitAction(TexasHoldemRoom.Action.Call, 0);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 0);
        assertEq(room.lastRaiseIndex(), 1);
        assertEq(room.currentStageBet(), 100);
        assertEq(room.pot(), 220); // already put in 10 before, so add 90 to previous pot()

        vm.startPrank(player1);
        room.submitAction(TexasHoldemRoom.Action.Call, 0);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 0); // End of betting stage, start of reveal stage
        assertEq(room.lastRaiseIndex(), 1);
        assertEq(room.currentStageBet(), 0); // reset to 0 after betting stage ends
        assertEq(room.pot(), 300); // already put in 20 before, so add 80 to previous pot()

        assertEq(uint256(room.stage()), uint256(TexasHoldemRoom.GameStage.RevealTurn));

        // ======= TURN CARD REVEAL =======
        uint256[] memory cardIndexesTurn = new uint256[](1);
        BigNumber[] memory decryptionValuesTurn = new BigNumber[](1);
        // 3 players, 6th card is burned, 789 are the flop cards,
        // 10th card is burned, 11th card is the turn card
        cardIndexesTurn[0] = 11;
        decryptionValuesTurn[0] = BigNumbers.init(
            hex"0262d2a708d5fb8656113f3ea415333a92a47820037e6c7a51a42a4734bfa093", false
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
            hex"8a0fda7fa62d06e082e05fdbea4247e9c9b7e06e95ddb6cc65e65cab68f1a2bb", false
        );
        decryptionValuesBytesTurn[0] = decryptionValuesTurn[0].val;
        deckHandler.submitDecryptionValues(cardIndexesTurn, decryptionValuesBytesTurn);
        vm.stopPrank();

        assertEq(room.currentPlayerIndex(), 2);
        vm.startPrank(player3);
        cardIndexesTurn[0] = 9;
        decryptionValuesTurn[0] = BigNumbers.init(
            hex"0000000000000000000000000000000000000000000000000000000000003334", false
        );
        decryptionValuesBytesTurn[0] = decryptionValuesTurn[0].val;
        vm.expectEmit();
        emit DeckHandler.TurnRevealed("34");
        deckHandler.submitDecryptionValues(cardIndexesTurn, decryptionValuesBytesTurn);
        vm.stopPrank();
        // ======= END OF TURN CARD REVEAL =======

        // ======= START OF TURN CARD BETTING =======
        assertEq(uint256(room.stage()), uint256(TexasHoldemRoom.GameStage.Turn));
        assertEq(room.currentPlayerIndex(), 1);

        vm.startPrank(player2);
        room.submitAction(TexasHoldemRoom.Action.Raise, 100);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 2);
        assertEq(room.lastRaiseIndex(), 1);
        assertEq(room.currentStageBet(), 100);
        assertEq(room.pot(), 400);

        vm.startPrank(player3);
        room.submitAction(TexasHoldemRoom.Action.Call, 0);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 0);
        assertEq(room.currentStageBet(), 100);
        assertEq(room.pot(), 500);

        vm.startPrank(player1);
        room.submitAction(TexasHoldemRoom.Action.Call, 0);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 0);
        assertEq(room.currentStageBet(), 0);
        assertEq(room.pot(), 600);
        // ======= END OF TURN CARD BETTING =======

        // ======= START OF RIVER CARD REVEAL =======
        assertEq(uint256(room.stage()), uint256(TexasHoldemRoom.GameStage.RevealRiver));
        // All players should submit their decryption values for the river card
        uint256[] memory cardIndexesRiver = new uint256[](1);
        BigNumber[] memory decryptionValuesRiver = new BigNumber[](1);
        // 3 players, 10th card is burned, 11th card is the turn card
        // 12th card is burned, 13th card is the river card
        cardIndexesRiver[0] = 13;
        decryptionValuesRiver[0] = BigNumbers.init(
            hex"61dafcce38f26de5901885ce9cd69b0186c0c7cb2f5016e16cfb237ecfbd8581", false
        );
        bytes[] memory decryptionValuesBytesRiver = new bytes[](1);
        decryptionValuesBytesRiver[0] = decryptionValuesRiver[0].val;
        vm.startPrank(player1);
        deckHandler.submitDecryptionValues(cardIndexesRiver, decryptionValuesBytesRiver);
        vm.stopPrank();

        assertEq(room.currentPlayerIndex(), 1);
        vm.startPrank(player2);
        decryptionValuesRiver[0] = BigNumbers.init(
            hex"338ace8d386c61cbb99b2238910ecdac96efd65e88030606a96fbc32476665d5", false
        );
        decryptionValuesBytesRiver[0] = decryptionValuesRiver[0].val;
        deckHandler.submitDecryptionValues(cardIndexesRiver, decryptionValuesBytesRiver);
        vm.stopPrank();

        assertEq(room.currentPlayerIndex(), 2);
        vm.startPrank(player3);
        decryptionValuesRiver[0] = BigNumbers.init(
            hex"0000000000000000000000000000000000000000000000000000000000000036", false
        );
        decryptionValuesBytesRiver[0] = decryptionValuesRiver[0].val;
        vm.expectEmit();
        emit DeckHandler.RiverRevealed("6");
        deckHandler.submitDecryptionValues(cardIndexesRiver, decryptionValuesBytesRiver);
        vm.stopPrank();
        // ======= END OF RIVER CARD REVEAL =======

        // ======= START OF RIVER CARD BETTING =======
        assertEq(uint256(room.stage()), uint256(TexasHoldemRoom.GameStage.River));
        assertEq(room.currentPlayerIndex(), 1);

        vm.startPrank(player2);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 2);
        assertEq(room.lastRaiseIndex(), 1);
        assertEq(room.currentStageBet(), 0);
        assertEq(room.pot(), 600);

        vm.startPrank(player3);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 0);
        assertEq(room.lastRaiseIndex(), 1);
        assertEq(room.currentStageBet(), 0);
        assertEq(room.pot(), 600);

        vm.startPrank(player1);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.stopPrank();
        assertEq(room.currentPlayerIndex(), 0);
        assertEq(room.currentStageBet(), 0);
        assertEq(room.pot(), 600);
        // ======= END OF RIVER CARD BETTING =======

        assertEq(uint256(room.stage()), uint256(TexasHoldemRoom.GameStage.Showdown));
        assertEq(room.currentPlayerIndex(), 0);
        // reveal cards?
        // submit private key r's and mid func calcs. verify cards. compare hands
        console.log("Player1 is revealing their cards");
        vm.startPrank(player1);
        // CryptoUtils.EncryptedCard memory encryptedCard1 =
        //     CryptoUtils.EncryptedCard({ c1: c1p1, c2: deckHandler.getEncrypedCard(0) });
        // CryptoUtils.EncryptedCard memory encryptedCard2 =
        //     CryptoUtils.EncryptedCard({ c1: c1p1, c2: deckHandler.getEncrypedCard(3) });

        // don't check equality of cards as we don't know them yet
        vm.expectEmit(address(deckHandler));
        emit DeckHandler.PlayerCardsRevealed(
            address(player1), "37", "5", PokerHandEvaluatorv2.HandRank.HighCard, 100000013108705
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
        vm.assertEq(players[0].handScore, 100000013108705);

        console.log("Player3 is revealing their cards");
        vm.startPrank(player3);
        // CryptoUtils.EncryptedCard memory encryptedCard5 =
        //     CryptoUtils.EncryptedCard({ c1: c1p2, c2: deckHandler.getEncrypedCard(2) });
        // CryptoUtils.EncryptedCard memory encryptedCard6 =
        //     CryptoUtils.EncryptedCard({ c1: c1p2, c2: deckHandler.getEncrypedCard(5) });

        // don't check equality of cards as we don't know them yet
        vm.expectEmit(address(deckHandler));
        emit DeckHandler.PlayerCardsRevealed(
            address(player3), "1", "4", PokerHandEvaluatorv2.HandRank.Flush, 600000806030302
        );
        // also expect a winner event to be emitted
        // vm.expectEmit(address(room));
        // emit TexasHoldemRoom.RoundWinner(address(player2), 1);
        (string memory card5, string memory card6) =
            deckHandler.revealMyCards(c1p3.val, privateKey3.val, c1InversePowPrivate3.val);
        vm.stopPrank();
        console.log("card5: %s %s", card5, pokerHandEvaluator.stringToHumanReadable(card5));
        console.log("card6: %s %s", card6, pokerHandEvaluator.stringToHumanReadable(card6));
        // assert that card3 is in the deck (range 0 to 51)
        vm.assertTrue(pokerHandEvaluator.parseInt(card5) < 52);
        // assert that card4 is in the deck (range 0 to 51)
        vm.assertTrue(pokerHandEvaluator.parseInt(card6) < 52);

        console.log("Player2 is revealing their cards");
        vm.startPrank(player2);
        // CryptoUtils.EncryptedCard memory encryptedCard3 =
        //     CryptoUtils.EncryptedCard({ c1: c1p2, c2: deckHandler.getEncrypedCard(1) });
        // CryptoUtils.EncryptedCard memory encryptedCard4 =
        //     CryptoUtils.EncryptedCard({ c1: c1p2, c2: deckHandler.getEncrypedCard(4) });

        // don't check equality of cards as we don't know them yet
        vm.expectEmit(address(deckHandler));
        emit DeckHandler.PlayerCardsRevealed(
            address(player2), "39", "31", PokerHandEvaluatorv2.HandRank.Pair, 200000002070810
        );
        // Player 3 won!
        vm.expectEmit(address(room));
        uint256[] memory expectedWinnerPlayerIndicies = new uint256[](1);
        expectedWinnerPlayerIndicies[0] = 2;

        address[] memory winnerAddresses = new address[](1);
        winnerAddresses[0] = address(player3);
        emit TexasHoldemRoom.PotWon(winnerAddresses, expectedWinnerPlayerIndicies, 600);
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
        vm.assertEq(players[2].handScore, 0);

        // Player 3 won!
        vm.assertEq(players[2].chips, 1400);
        vm.assertEq(players[1].chips, 800);
        vm.assertEq(players[0].chips, 800);

        vm.assertEq(room.dealerPosition(), 1);
        vm.assertEq(room.currentPlayerIndex(), 1);
        // todo: check cards exactly match an shuffled deck's cards (no dupes too)

        //         bytes memory expectedMessageBytes = hex"30";
        //        BigNumber memory testMessage = BigNumbers.init(expectedMessageBytes, false);
        // assertEq(BigNumbers.eq(decryptedMessage, testMessage), true);
        // compare cards
    }
}
