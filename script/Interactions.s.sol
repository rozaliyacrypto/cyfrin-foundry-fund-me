// Fund Interactions
// Withdraw Interactions

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

// аналог кнопки Fund в интерфейсе (как если бы мы взаим с контрактом через Remix)
contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether; // 10^16

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast(); // start transactions
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast(); // stop transactions
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        // it finds the most recently deployed contract
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentlyDeployed);
    }
}

// аналог кнопки Withdraw в интерфейсе
contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether; // 10^16

    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast(); // start transactions
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast(); // stop transactions
    }

    function run() external {
        // it finds the most recently deployed contract
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(mostRecentlyDeployed);
    }
}
