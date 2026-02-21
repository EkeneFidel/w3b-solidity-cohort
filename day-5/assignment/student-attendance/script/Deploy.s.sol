// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/ERC20.sol";
import "../src/SaveAsset.sol";
import "../src/SaveEther.sol";
import "../src/StudentAttendance.sol";
import "../src/Todo.sol";

contract DeployAll is Script {
    function run() external {
        vm.startBroadcast();

        ERC20 token = new ERC20();
        console.log("ERC20 deployed:", address(token));

        SaveEther saveEther = new SaveEther();
        console.log("SaveEther deployed:", address(saveEther));

        SaveAsset saveAsset = new SaveAsset(address(token));
        console.log("SaveAsset deployed:", address(saveAsset));

        SchoolManagement school = new SchoolManagement(address(token));
        console.log("SchoolManagement deployed:", address(school));

        Todo todo = new Todo();
        console.log("Todo deployed:", address(todo));

        vm.stopBroadcast();
    }
}
