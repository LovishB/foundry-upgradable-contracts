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

contract MyTokenV1 is Initializable, ERC20Upgradeable, OwnableUpgradeable, UUPSUpgradeable {

    uint256 public maxSupply;
    mapping(address => bool) public s_isTokenHolder;

    // This prevents the implementation contract from being initialized directly
    // Only the proxy contracts should be initialized
    constructor() {
        _disableInitializers();
    }

    // Initialize Function
    function initialize(address initialOwner) public initializer {
        __ERC20_init("MyToken", "MTK");
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();

        maxSupply = 1_000_000 * 10**decimals(); // Setting 1 million supply 
    }

    // Can only be minted by Owner
    function mint(address to, uint256 amount) public onlyOwner {
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
