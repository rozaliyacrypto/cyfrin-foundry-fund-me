//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 0.1 ether; // 1 000 000 000 000 000 00 wei

    uint256 constant STARTING_BALANCE = 10 ether;

    uint256 constant GAS_PRICE = 1;

    // here - we deploy the contract to test
    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run(); // this function returns FundMe contract
        vm.deal(USER, STARTING_BALANCE); // give fake USER some ETH balance
    }

    function testMinUsdBalanceIsFive() public {
        assertEq(fundMe.MIN_USD(), 5e18);
        console.log("MIN_USD is:", fundMe.MIN_USD());
    }

    function testOwnerIsmsgSender() public {
        console.log("Owner is: ", fundMe.getOwner());
        console.log("Msg sender is: ", msg.sender);
        //assertEq(fundMe.i_owner(), msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertGt(version, 0);
    }

    // test fund function in FundMe contract

    modifier funded() {
        vm.prank(USER); // next tx will be sent by USER
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // we expect the next line to revert
        fundMe.fund(); // calling fund without sending any ETH
    }

    function testFundUpdatesFundedDataStructure() public funded {
        // test s_addressToAmountFunded mapping
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        // test s_funders array
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    // test withdraw function in FundMe contract

    function testWithdrawFailsIfNotOwner() public funded {
        vm.prank(USER); // next tx will be sent by USER
        vm.expectRevert(); // we expect the next line to revert
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner()); // withdraw can do only the owner
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Gas used for withdraw: ", gasUsed);

        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act
        // instead of using vm.prank - we can use vm.startPrank +  vm.stopPrank
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // assert
        assert(address(fundMe).balance == 0);
        assert(
            startingOwnerBalance + startingFundMeBalance ==
                fundMe.getOwner().balance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act
        // instead of using vm.prank - we can use vm.startPrank +  vm.stopPrank
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // assert
        assert(address(fundMe).balance == 0);
        assert(
            startingOwnerBalance + startingFundMeBalance ==
                fundMe.getOwner().balance
        );
    }
}
