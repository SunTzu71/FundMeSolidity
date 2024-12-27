// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    /**
     * @dev Function deploys FundMe contract with price feed address based on chain ID
     * This uses helper config to determine price feed and returns both the deployed contract and helper config
     */
    function deployFundMe() public returns (FundMe, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig(); // This comes with our mocks!
        address priceFeed = helperConfig
            .getConfigByChainId(block.chainid)
            .priceFeed;

        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        return (fundMe, helperConfig);
    }

    /**
     * @dev Main function initiates deployment of the FundMe contract and returns both the deployed contract and helper config
     */
    function run() external returns (FundMe, HelperConfig) {
        return deployFundMe();
    }
}
