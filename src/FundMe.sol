// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders; // s_ for storage

    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    AggregatorV3Interface private s_priceFeed;

    /**
     * @notice Constructor sets the owner and price feed address
     * @param priceFeed The address of the price feed contract
     */
    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    /**
     * @notice Funds the contract with ETH
     * @dev Converts ETH amount to USD to check minimum value
     * @dev Stores funding data in state variables
     */
    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "You need to spend more ETH!"
        );
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    /**
     * @notice Gets the version of the price feed
     * @return The version number of the price feed contract
     */
    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    /**
     * @notice Modifier that ensures only the owner can call a function
     * @dev Reverts with FundMe__NotOwner error if caller is not owner
     */
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    /**
     * @notice Withdraws all funds from the contract to the owner
     * @dev Resets funders array and amount funded mapping
     * @dev Sends entire contract balance to owner address
     */
    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    /**
     * @notice Called when contract receives ETH without data
     * @dev Forwards funds to the fund() function
     */
    fallback() external payable {
        fund();
    }

    /**
     * @notice Called when contract receives ETH with empty calldata
     * @dev Forwards funds to the fund() function
     */
    receive() external payable {
        fund();
    }

    /**
     * @notice Gets the amount funded by a specific address
     * @param fundingAddress The address to check the funded amount for
     * @return The amount funded by the given address
     */
    function getAddressToAmountFunded(
        address fundingAddress
    ) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    /**
     * @notice Gets the funder at a specific index
     * @param index The index in the funders array
     * @return The address of the funder at the given index
     */
    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    /**
     * @notice Gets the owner of the contract
     * @return The address of the contract owner
     */
    function getOwner() public view returns (address) {
        return i_owner;
    }
}
