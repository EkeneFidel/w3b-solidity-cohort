// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {PropertyManagement} from "../src/PropertyManagement.sol";

contract PropertyManagementScript is Script {
    PropertyManagement public propertyManagement;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        propertyManagement = new PropertyManagement(address(0), 100);

        vm.stopBroadcast();
    }
}
