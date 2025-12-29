//SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig; // what is the active network

    // this constants make code more readable
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed contract address
    }

    constructor() {
        if (block.chainid == 11155111) {
            // Sepolia Ethereum Chain ID
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 300) {
            // zkSync sepolia Chain ID
            activeNetworkConfig = getZkSyncSepoliaEthConfig();
        } else if (block.chainid == 1) {
            // Mainnet Ethereum Chain ID
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            // local anvil chain (local blockchain)
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return mainnetConfig;
    }

    function getZkSyncSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory zkSyncSepoliaConfig =
            NetworkConfig({priceFeed: 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF});
        return zkSyncSepoliaConfig;
    }

    // if we are on a local anvil - we deploy mocks
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // if we've already deployed one - we don't want to deploy a new one
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }
}
