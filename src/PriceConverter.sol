// Price Converting Library

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// this interface is from chainlinl GitHub
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// libraries cant have any state variables and all the funcs have to be marked internal
library PriceConverter {
    // how much ethAmount is in USD
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getEthPriceInUsd(priceFeed); // what is the price of 1 ETH in USD
        uint256 ethAmountInUsd = (ethAmount * ethPrice) / 1e18;
        return ethAmountInUsd;
    }

    // 0x694AA1769357215DE4FAC081bf1f309aDC325306 - Ethereum Sepolia TestNet
    // 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF - ZkSync Sepolia TestNet
    function getEthPriceInUsd(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price) * 1e10; // because the decimals for price is only 10, but msg.value is 18 (in wei)
    }

    // get the decimals for current pair
    function getAggregatorDecimals(AggregatorV3Interface priceFeed) internal view returns (uint8) {
        return priceFeed.decimals();
    }
}
