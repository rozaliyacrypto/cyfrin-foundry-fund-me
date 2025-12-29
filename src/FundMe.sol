// Get funds from the users
// withdraw funds (by owner of the contract)
// + set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner(); // custom error name convention

contract FundMe {
    using PriceConverter for uint256;

    // State variables!
    uint256 public constant MIN_USD = 5e18;
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // allows users to send money to the contract
    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MIN_USD,
            "not enough amount of ETH"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    // let's keep this from storage to memory gas optimization in mind
    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (uint256 i = 0; i < fundersLength; i++) {
            address funder = s_funders[i]; // array
            s_addressToAmountFunded[funder] = 0; // mapping
        }
        s_funders = new address[](0); // new array with 0 length
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "call failed");
    }

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0; // rest all the values to 0 cause of withdrawing funds
        }
        s_funders = new address[](0);
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "call failed");
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "must be owner");
        // gas optimization technique to use custom errors instead of require
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
