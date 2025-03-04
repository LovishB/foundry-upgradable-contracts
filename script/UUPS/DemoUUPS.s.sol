// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MyTokenV1} from "../../src/UUPS/MyTokenV1.sol";
import {MyTokenV2} from "../../src/UUPS/MyTokenV2.sol";
import {ERC1967Proxy} from "../../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

// Define an interface for the upgradeToAndCall function
interface IUUPSUpgradeable {
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

contract DemoUUPS is Script {

    function setUp() public {}

    function run() public {
        // First address from Anvil
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);
        address user = makeAddr("user");
        // 1) Deploying V1
        MyTokenV1 implementationV1 = new MyTokenV1();
        console.log("MyTokenV1 implementation deployed at:", address(implementationV1));

        // 2. Prepare initialization data instead of a constructor
         bytes memory initData = abi.encodeWithSelector(
            MyTokenV1.initialize.selector,
            deployer  // Pass the deployer as the owner
        );

        // 3. Setup Proxy
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementationV1),
            initData //initializer data will be passed here
        );
        console.log("ERC1967Proxy deployed at:", address(proxy));

        // 4. Mint Tokens
        /** 
        * Here we are generating a reference to the proxy address, type-cast as MyTokenV1
        * When we call a function on this reference, call goes to the proxy contract first
        * The proxy contract doesn't have a mint function itself, so it triggers its fallback function
        * In the fallback function, the proxy performs a delegatecall to the implementation contract
        */
        console.log("========== V1 MINTING ==========");
        MyTokenV1 tokenV1 = MyTokenV1(address(proxy));
        tokenV1.mint(user, 10000);
        console.log("User balance:", tokenV1.balanceOf(user));
        console.log("Total supply:", tokenV1.maxSupply());

        // 5. Upgrade Implementation
        MyTokenV2 implementationV2 = new MyTokenV2();
        console.log("MyTokenV2 implementation deployed at:", address(implementationV2));

        console.log("Upgrading proxy to V2...");
        IUUPSUpgradeable(address(proxy)).upgradeToAndCall(address(implementationV2), new bytes(0));

        // 6. calling updateToV2 to change supply
        MyTokenV2 tokenV2 = MyTokenV2(address(proxy));
        console.log("Updating to V2...");
        tokenV2.updateToV2();

        // 7. check V2
        console.log("========== V2 CHECKING ==========");
        console.log("User balance:", tokenV2.balanceOf(user));
        console.log("Total supply:", tokenV2.maxSupply());

        vm.stopBroadcast();
    }
}