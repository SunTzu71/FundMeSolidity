// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

/////////////////////
// Contract Fundme //
////////////////////
contract FundFundMe is Script {
    uint256 SEND_VALUE = 0.1 ether;

    /**
     * @dev Takes a deployed contract address and funds it with SEND_VALUE
     * @param mostRecentlyDeployed The address of the deployed FundMe contract
     */
    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    /**
     * @notice Main function that runs the funding script
     * @dev Gets most recent deployment and funds it
     */
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentlyDeployed);
    }
}

/////////////////////////////
// Contract WithdrawFundMe //
////////////////////////////
contract WithdrawFundMe is Script {
    /**
     * @dev Takes a deployed contract address and withdraws its balance
     * @param mostRecentlyDeployed The address of the deployed FundMe contract
     */
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    /**
     * @notice Main function that runs the withdrawal script
     * @dev Gets most recent deployment and withdraws from it
     */
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(mostRecentlyDeployed);
    }
}
