// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// This is the implementation contract, it has the logic
//when delegate call will be made, execution will not happen in this contract
//it will happen in proxy contract & state variables will not update in this contract
contract Summation {
    uint256 public a;
    uint256 public b;
    uint256 public result;

    function sum(uint256 _a, uint256 _b) public {
        a = _a;
        b = _b;
        result = a + b;
    }

}