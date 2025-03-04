// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// A version of the standard ERC20 token implementation modified to work with proxy patterns. 
// Unlike regular ERC20, it uses initializer functions instead of constructors 
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

// Provides the initialization mechanism that replaces constructors in upgradeable contracts. It includes the initializer
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

// Unlike regular Ownable, it's designed to work with proxy patterns and uses initializers.
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// Implements the Universal Upgradeable Proxy Standard. It contains the core upgrade functionality 
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract MyTokenV2 is Initializable, ERC20Upgradeable, OwnableUpgradeable, UUPSUpgradeable {

    uint256 public maxSupply;

    // The storage varaibles are actually maintained in proxies so we will not lose the data while updating to V2
    mapping(address => bool) public s_isTokenHolder;


    // This prevents the implementation contract from being initialized directly
    // Only the proxy contracts should be initialized
    constructor() {
        _disableInitializers();
    }

    // No initialize function in V2 - we'll inherit state from V1

    // updateToV2 function runs only when we upgrade to this implementation
    // Inside this function we can change the storage variables and other stuff
    function updateToV2() public reinitializer(2) {
        // Update max supply to 1 billion tokens
        maxSupply = 1_000_000_000 * 10**decimals();
    }

    // Now we also wish to change the mint function, we will simple write the new one
    // when this contract will be updated, it will tchange the working
    function mint(address to, uint256 amount) public {
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");
        _mint(to, amount);
        s_isTokenHolder[to] = true;
    }

    // This only allows owner to upgrade the contract
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}