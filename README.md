# FundMe Smart Contract

## Overview
FundMe is a Solidity smart contract that allows users to fund the contract with ETH while ensuring a minimum USD value requirement. It uses Chainlink Price Feeds to convert ETH to USD values and includes functionality for withdrawing funds by the contract owner.

## Features
- Accept ETH funding from users
- Minimum funding requirement in USD
- Real-time ETH/USD price conversion using Chainlink
- Owner-only withdrawal functionality
- Tracking of funders and their contributed amounts
- Fallback functions to handle direct ETH transfers

## Technical Details

### Core Functions
- `fund()`: Allows users to send ETH to the contract, requiring a minimum USD value
- `withdraw()`: Enables the owner to withdraw all funds and reset funder data
- `getVersion()`: Returns the version of the Chainlink price feed being used

### View Functions
- `getAddressToAmountFunded(address)`: Returns the amount funded by a specific address
- `getFunder(uint256)`: Returns the funder's address at a specific index
- `getOwner()`: Returns the contract owner's address

### Price Converter Library
- `getPrice()`: Fetches current ETH/USD price from Chainlink
- `getConversionRate()`: Converts ETH amounts to USD values

### State Variables
- `MINIMUM_USD`: Constant minimum funding amount (5 USD)
- `i_owner`: Immutable contract owner address
- `s_addressToAmountFunded`: Mapping of addresses to funded amounts
- `s_funders`: Array of funder addresses
- `s_priceFeed`: Chainlink price feed interface

### Modifiers
- `onlyOwner`: Restricts function access to contract owner

## Requirements
- Solidity ^0.8.26
- Chainlink Price Feed contract
- Minimum funding amount of 5 USD in ETH

## Installation & Setup
1. Deploy with a valid Chainlink Price Feed address for ETH/USD
2. Contract owner is set to deployer address
3. Ensure proper network configuration for Chainlink integration

## Security Features
- Immutable owner address
- Access control via onlyOwner modifier
- Custom error handling
- Safe withdrawal pattern
- Storage variables marked as private

## Events
*Note: This contract does not implement any events. Consider adding events for:*
- Funding received
- Withdrawal executed
- Owner actions

## Error Handling
- Custom error: `FundMe__NotOwner()`
- Require statements for:
  - Minimum funding amount
  - Successful fund transfers

## License
MIT License
