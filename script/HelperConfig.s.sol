// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";
import {Script, console2} from "forge-std/Script.sol";

abstract contract CodeConstants {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is CodeConstants, Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        address priceFeed;
    }

    // Local network state variables
    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    /**
     * @dev Constructor initializes network configurations for supported chains
     * Sepolia and zkSync Sepolia are pre-configured
     * Local network config is handled separately on-demand
     */
    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
        networkConfigs[ZKSYNC_SEPOLIA_CHAIN_ID] = getZkSyncSepoliaConfig();
        // Note: We skip doing the local config
    }

    /**
     * @notice Gets network configuration based on chain ID
     * @dev Returns existing config for known networks, creates local config for Anvil,
     *      or reverts for unsupported chains
     * @param chainId The ID of the blockchain network
     * @return NetworkConfig configuration for the specified chain
     */
    function getConfigByChainId(
        uint256 chainId
    ) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].priceFeed != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    /**
     * @notice Returns Sepolia network configuration with price feed address
     * @dev Uses hardcoded Chainlink ETH/USD price feed address for Sepolia
     * @return NetworkConfig containing Sepolia price feed address
     */
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // ETH / USD
            });
    }

    /**
     * @notice Returns zkSync Sepolia network configuration with price feed address
     * @dev Uses hardcoded Chainlink ETH/USD price feed address for zkSync Sepolia
     * @return NetworkConfig containing zkSync Sepolia price feed address
     */
    function getZkSyncSepoliaConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        return
            NetworkConfig({
                priceFeed: 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF // ETH / USD
            });
    }

    /**
     * @notice Gets or creates local network configuration for Anvil
     * @dev Creates a new mock price feed if one doesn't exist
     * @return NetworkConfig configuration for local Anvil network
     */
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // Check to see if we set an active network config
        if (localNetworkConfig.priceFeed != address(0)) {
            return localNetworkConfig;
        }

        console2.log(unicode"⚠️ You have deployed a mock contract!");
        console2.log("Make sure this was intentional");
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return localNetworkConfig;
    }
}
