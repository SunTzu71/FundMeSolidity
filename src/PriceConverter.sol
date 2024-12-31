// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    error PriceConverter__StalePrice();
    error PriceConverter__InvalidPrice();

    /**
     * Retrieves the latest ETH/USD price from Chainlink price feed
     * See: https://docs.chain.link/data-feeds/price-feeds/addresses
     */
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        (
            uint80 roundId,
            int256 answer, // startedAt (unused)
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();

        // Check for stale data
        if (updatedAt == 0 || answeredInRound < roundId) {
            revert PriceConverter__StalePrice();
        }

        // Check for invalid data
        if (answer <= 0) {
            revert PriceConverter__InvalidPrice();
        }
        return uint256(answer * 10000000000);
    }

    /**
     * Converts ETH amount to USD using current price feed
     * @param ethAmount Amount of ETH to convert
     * @param priceFeed Price feed interface to use for conversion
     * @return USD value of provided ETH amount
     */
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }
}
