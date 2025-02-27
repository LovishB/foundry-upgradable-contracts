// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
/*
* When sum(a, b) function is called
* delegatecall executes the sum function from implementation context
* but the state vairiables changes occur's only in proxy contract storage
* proxy maintians the state noe the implementation contract
*/

contract SummationProxy {
    uint256 public a;
    uint256 public b;
    uint256 public result;

    // Address of implementation contract
    address public implementation;

    constructor(address _implementation) {
        implementation = _implementation;
    }

    // Upgrade to a new implementation
    function upgrade(address newImplementation) public {
        implementation = newImplementation;
    }

    function sum(uint256 _a, uint256 _b) public {
        bytes memory data = abi.encodeWithSignature("sum(uint256,uint256)", _a, _b);
        performDelegateCall(data);
    }

    function performDelegateCall(bytes memory data) public returns (bytes memory) {
        (bool success, bytes memory returnData) = implementation.delegatecall(data);
        require(success, "Delegate call failed");
        return returnData;
    }


}