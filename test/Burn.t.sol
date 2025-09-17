// SPDX-License-Identifier: Apache-2.0 OR MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Test} from "forge-std/Test.sol";
import {Payments} from "../src/Payments.sol";
import {PaymentsTestHelpers} from "./helpers/PaymentsTestHelpers.sol";

contract BurnTest is Test {
    PaymentsTestHelpers helper = new PaymentsTestHelpers();
    Payments payments;
    uint256 testTokenRailId;
    uint256 nativeTokenRailId;

    uint256 private constant AUCTION_START_PRICE = 0.083 ether;
    address payable private constant BURN_ADDRESS = payable(0xff00000000000000000000000000000000000063);

    IERC20 private TEST_TOKEN;
    IERC20 private constant NATIVE_TOKEN = IERC20(address(0));
    address private payer;
    address private payee;
    address private operator;

    function setUp() public {
        helper.setupStandardTestEnvironment();
        payments = helper.payments();

        TEST_TOKEN = helper.testToken();
        operator = helper.OPERATOR();
        payer = helper.USER1();
        payee = helper.USER2();


        vm.prank(payer);
        payments.setOperatorApproval(TEST_TOKEN, operator, true, 5 * 10 ** 18, 5 * 10 ** 18, 28800);
        vm.prank(payer);
        payments.setOperatorApproval(NATIVE_TOKEN, operator, true, 5 * 10 ** 18, 5 * 10 ** 18, 28800);

        vm.prank(operator);
        testTokenRailId = payments.createRail(TEST_TOKEN, payer, payee, address(0), 0, address(0));
        vm.prank(operator);
        nativeTokenRailId = payments.createRail(NATIVE_TOKEN, payer, payee, address(0), 0, address(0));

        vm.prank(payer);
        TEST_TOKEN.approve(address(payments), 5 * 10 ** 18);
        vm.prank(payer);
        payments.deposit(TEST_TOKEN, payer, 5 * 10 ** 18);

        vm.prank(payer);
        payments.deposit{value: 5 * 10 ** 18}(NATIVE_TOKEN, payer, 5 * 10 ** 18);
    }

    function testBurn() public {
        uint256 newRate = 9 * 10**16;
        vm.prank(operator);
        payments.modifyRailPayment(testTokenRailId, newRate, 0);

        vm.roll(block.number + 10);

        (uint256 availableBefore,,,) = payments.accounts(TEST_TOKEN, address(payments));
        assertEq(availableBefore, 0);

        vm.prank(payer);
        payments.settleRail(testTokenRailId, block.number);

        (uint256 available,,,) = payments.accounts(TEST_TOKEN, address(payments));
        assertEq(available, 10 * newRate * payments.NETWORK_FEE_NUMERATOR() / payments.NETWORK_FEE_DENOMINATOR());

        payments.burnFILForFees{value: AUCTION_START_PRICE}(TEST_TOKEN, helper.USER3(), available);
        assertEq(available, TEST_TOKEN.balanceOf(helper.USER3()));

        (uint256 availableAfter,,,) = payments.accounts(TEST_TOKEN, address(payments));
        assertEq(availableAfter, 0);
    }

    function testNativeAutoBurned() public {
        uint256 newRate = 7 * 10**16;
        vm.prank(operator);
        payments.modifyRailPayment(nativeTokenRailId, newRate, 0);

        vm.roll(block.number + 12);

        assertEq(BURN_ADDRESS.balance, 0);

        (uint256 availableBefore,,,) = payments.accounts(NATIVE_TOKEN, address(payments));
        assertEq(availableBefore, 0);

        vm.prank(payer);
        payments.settleRail(nativeTokenRailId, block.number);

        (uint256 availableAfter,,,) = payments.accounts(NATIVE_TOKEN, address(payments));
        assertEq(availableAfter, 0);

        assertEq(BURN_ADDRESS.balance, 12 * newRate * payments.NETWORK_FEE_NUMERATOR() / payments.NETWORK_FEE_DENOMINATOR());
    }
}
