// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { Script } from "forge-std/Script.sol";
import { SimpleAdd5 } from "../src/SimpleAdd5.sol";

contract DeployAdd5 is Script {
    function run() public returns (SimpleAdd5) {
        vm.startBroadcast();
        SimpleAdd5 simpleAdd5 = new SimpleAdd5();
        vm.stopBroadcast();
        return simpleAdd5;
    }
}
