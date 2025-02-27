// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
/*
* When sum(a, b) function is called
* delegatecall executes the sum function from implementation context
* but the state vairiables changes occur's only in proxy contract storage
* proxy maintians the state noe the implementation contract
*/

contract SummationProxyEIP1967 {

    uint256 public a;
    uint256 public b;
    uint256 public result;

    // EIP 1967 standard storage slot for implementation
    // It is a predefined storage location for different proxy implementation
    // it meants to prevent storage collisions with other conract variables
    bytes32 private constant IMPLEMENTATION_SLOT = 
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(address _implementation) {
        // Store implementation address in the specific EIP 1967 slot
        // assembly is a low level languague that has funstion like sstore, sload, mstore, mload
        assembly {
            sstore(IMPLEMENTATION_SLOT, _implementation)
        }
    }

    // Function to upgrade implementation
    function upgrade(address newImplementation) external {
        assembly {
            sstore(IMPLEMENTATION_SLOT, newImplementation)
        }
    }

    // fallback is called when contract recives a call with no matching funtion signatures
    // so basically when we will call sum(), this is will be called as proxy do not have this function
    // it will re-route to implementation contract with delegate call
    fallback() external payable {

        // Retrieve implementation address from EIP 1967 slot
        // using assembly low level lang now
        assembly {
            let implementation := sload(IMPLEMENTATION_SLOT)

            // Copy calldata to memory
            calldatacopy(0, 0, calldatasize())

            // Perform delegate call
            // The entire message data is forwarded to the implementation contract
            // Implementation contract will match and call sum(uint256,uint256)
            // The function is executed in the proxy's context, state changes occur in the proxy contract
            let success := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Get size of the return data
            let retSize := returndatasize()

            // Copy the return data
            returndatacopy(0, 0, retSize)

            // Revert if delegate call fails
            if iszero(success) {
                 revert(0, retSize)
            }
            return(0, retSize)
        }
    }

    receive() external payable {}
}
