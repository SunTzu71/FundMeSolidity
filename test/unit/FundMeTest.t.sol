// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;
    HelperConfig public helperConfig;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 10 gwei;

    /*
     * setUp function runs before each test and sets up fresh contract instances
     * Deploys FundMe contract and helper config, deals USER test address with starting ETH
     */
    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        (fundMe, helperConfig) = deployer.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    /*
     * Tests whether the minimum USD amount required to fund is set correctly
     * Asserts that MINIMUM_USD is equal to 5e18 (5 USD in Wei)
     */
    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    /*
     * Tests whether the owner of the contract is correctly set to msg.sender
     * Asserts that contract owner is equal to the address that deployed the contract
     */
    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    /*
     * Tests whether the price feed version is accurate
     * Gets version number from contract and verifies it's equal to 4
     */
    function testPriceFeedVersionAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    /*
     * Tests fundMe funding with no value sent
     * Expects the transaction to revert because it requires a minimum amount in USD
     */
    function testFund() public {
        vm.expectRevert();
        fundMe.fund(); // send 0 eth to fail and revert
    }

    /*
     * Tests whether the funding amount is correctly recorded in data structure
     * Simulates a user funding the contract and verifies the amount stored
     * Uses prank to impersonate USER address when making the transaction
     */
    function testFundUpdatesFundedDataStructure() public {
        // this only works in foundry
        // the next transaction will be sent from the user
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    /*
     * Tests whether a funder is correctly added to the funders array
     * Uses prank to make call from USER address
     * Verifies the funder at index 0 is equal to USER address
     */
    function testAddsFunderToArray() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}(); // fund the user

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    /*
     * Modifier that funds the contract from USER address with SEND_VALUE amount
     * Used to set up testing state for withdrawal and other funded tests
     */
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    /*
     * Tests that only owner can withdraw
     * Uses prank to simulate a non-owner USER address
     * Expects revert when non-owner tries to withdraw
     */
    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    /*
     * Tests withdrawal functionality with a single funder
     * Records initial balances, measures gas usage during withdrawal
     * Verifies final balances are correct after withdrawal
     * Ensures contract balance is 0 and owner received funds
     */
    function testWithdrawWithSingleFunder() public funded {
        uint256 startingFundeMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        uint256 gasStart = gasleft(); // gasleft() returns the amount of gas left in the current transaction - its built into Solidty
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("gas used", gasUsed);
        vm.stopPrank();

        uint256 endingFundBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(endingFundBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundeMeBalance
        );
    }

    /*
     * Tests withdrawal functionality with multiple funders
     * Creates and funds multiple test accounts
     * Verifies final balances after withdrawal
     * Ensures contract balance is 0 and owner received all funds
     */
    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10; // if creating addresses you must use 160
        uint160 startingFunderIndex = 2;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingFundBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(endingFundBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundBalance
        );
    }
}
