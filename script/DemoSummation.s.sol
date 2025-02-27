// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SummationProxy} from "../src/SummationProxy.sol";
import {SummationProxyEIP1967} from "../src/SummationProxyEIP1967.sol";
import {Summation} from "../src/Summation.sol";

contract DemoSummation is Script {
    SummationProxy public proxy;
    SummationProxyEIP1967 public proxyEIP1967;
    Summation public implementation;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        uint256 a = 10;
        uint256 b = 20;

        // Deploy implementation contract
        implementation = new Summation();

        // Deploy proxy contract with implementation address
        proxy = new SummationProxy(address(implementation));
        proxy.sum(a, b);

        console.log("Implemetation Contract variables");
        console.log(implementation.a());
        console.log(implementation.b());
        console.log(implementation.result());

        console.log("Proxy Contract variables");
        console.log(proxy.a());
        console.log(proxy.b());
        console.log(proxy.result());

        console.log("Summation using proxy EIP1967");
        proxyEIP1967 = new SummationProxyEIP1967(address(implementation));
        (bool success, ) = address(proxyEIP1967).call(
            abi.encodeWithSignature("sum(uint256,uint256)", a, b)
        );
        require(success, "Proxy call failed");

        console.log("ProxyEIP1967 Contract variables");
        // console.log(success);
        console.log(proxyEIP1967.a());
        console.log(proxyEIP1967.b());
        console.log(proxyEIP1967.result());

        vm.stopBroadcast();
    }
}
