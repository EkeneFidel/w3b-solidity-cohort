// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {School} from "../src/School.sol";

contract SchoolScript is Script {
    School public school;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        school = new School();

        vm.stopBroadcast();
    }
}
