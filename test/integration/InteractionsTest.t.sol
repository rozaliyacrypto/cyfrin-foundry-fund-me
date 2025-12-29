//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe} from "../../script/Interactions.s.sol";
import {WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user"); // my test EOA account
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1; // for testing cost of transaction

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run(); // returs the instance of FundMe Contract
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMeContract = new FundFundMe();
        fundFundMeContract.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMeContract = new WithdrawFundMe();
        withdrawFundMeContract.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
