// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SummationProxy} from "../src/SummationProxy.sol";
import {Summation} from "../src/Summation.sol";

contract DemoSummation is Script {
    SummationProxy public proxy;
    Summation public implementation;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // Deploy implementation contract
        implementation = new Summation();

        // Deploy proxy contract with implementation address
        proxy = new SummationProxy(address(implementation));

        uint256 a = 10;
        uint256 b = 20;

        proxy.sum(a, b);

        console.log("Implemetation Contract variables");
        console.log(implementation.a());
        console.log(implementation.b());
        console.log(implementation.result());

        console.log("Proxy Contract variables");
        console.log(proxy.a());
        console.log(proxy.b());
        console.log(proxy.result());

        vm.stopBroadcast();
    }
}
