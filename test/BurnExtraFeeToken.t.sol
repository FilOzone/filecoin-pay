// SPDX-License-Identifier: Apache-2.0 OR MIT
pragma solidity ^0.8.27;

import {MockFVMTest} from "fvm-solidity/mocks/MockFVMTest.sol";
import {BURN_ADDRESS} from "fvm-solidity/FVMActors.sol";

import {PaymentsTestHelpers} from "./helpers/PaymentsTestHelpers.sol";
import {ExtraFeeToken} from "./mocks/ExtraFeeToken.sol";
import {FIRST_AUCTION_START_PRICE, FilecoinPayV1} from "../src/FilecoinPayV1.sol";

contract BurnFeeOnTransferTokenTest is MockFVMTest {
    PaymentsTestHelpers helper = new PaymentsTestHelpers();
    FilecoinPayV1 payments;
    ExtraFeeToken feeToken;

    uint256 railId;

    address operator;
    address payer;
    address payee;
    address recipient;

    function setUp() public override {
        // Mock the FVM precompiles
        super.setUp();

        helper.setupStandardTestEnvironment();
        payments = helper.payments();
        operator = helper.OPERATOR();
        payer = helper.USER1();
        payee = helper.USER2();
        recipient = helper.USER3();
    }

    function testBurnFeeOnTransferToken() public {
        feeToken = new ExtraFeeToken(10 ** 16);

        feeToken.mint(payer, 50000 * 10 ** 18);
        vm.prank(payer);
        feeToken.approve(address(payments), 50000 * 10 ** 18);
        vm.prank(payer);
        payments.deposit(feeToken, payer, 500 * 10 ** 18);

        (uint256 balance,,,) = payments.accounts(feeToken, payer);
        assertEq(balance, 500 * 10 ** 18);

        vm.prank(payer);
        payments.setOperatorApproval(feeToken, operator, true, 50000 * 10 ** 18, 500 * 10 ** 18, 28800);

        vm.prank(operator);
        railId = payments.createRail(feeToken, payer, payee, address(0), 0, address(0));

        uint256 newRate = 100 * 10 ** 16;

        vm.prank(operator);
        payments.modifyRailPayment(railId, newRate, 0);

        vm.roll(vm.getBlockNumber() + 10);

        vm.prank(payer);
        payments.settleRail(railId, vm.getBlockNumber());

        (uint256 available,,,) = payments.accounts(feeToken, address(payments));
        assertEq(available, 10 * newRate * payments.NETWORK_FEE_NUMERATOR() / payments.NETWORK_FEE_DENOMINATOR());

        uint256 contractBalanceBefore = feeToken.balanceOf(address(payments));
        uint256 burnedBefore = BURN_ADDRESS.balance;

        // The contract holds enough tokens, but the sender-paid fee would consume user funds.
        // The actual debit exceeds the fee account, so checked subtraction must revert.
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x11));
        payments.burnForFees{value: FIRST_AUCTION_START_PRICE}(feeToken, recipient, available);

        uint256 requested = available - feeToken.transferFee();
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x11));
        payments.burnForFees{value: FIRST_AUCTION_START_PRICE}(feeToken, recipient, requested + 1);

        // Both failed purchases roll back the token transfer and FIL burn.
        assertEq(feeToken.balanceOf(address(payments)), contractBalanceBefore);
        assertEq(feeToken.balanceOf(recipient), 0);
        assertEq(BURN_ADDRESS.balance, burnedBefore);
        (uint256 availableAfterFailure,,,) = payments.accounts(feeToken, address(payments));
        assertEq(availableAfterFailure, available);

        payments.burnForFees{value: FIRST_AUCTION_START_PRICE}(feeToken, recipient, requested);
        uint256 received = feeToken.balanceOf(recipient);
        assertEq(requested, received);

        // The recipient gets requested, but the contract loses requested + transferFee.
        // Charging only requested would leave an unbacked fee balance of transferFee.
        uint256 actualDebit = contractBalanceBefore - feeToken.balanceOf(address(payments));
        assertEq(actualDebit, requested + feeToken.transferFee());
        assertEq(actualDebit, available);

        (uint256 availableAfter,,,) = payments.accounts(feeToken, address(payments));
        assertEq(availableAfter, 0);

        // All remaining tokens still back the payer and payee, not the depleted fee account.
        (uint256 payerFunds,,,) = payments.accounts(feeToken, payer);
        (uint256 payeeFunds,,,) = payments.accounts(feeToken, payee);
        assertEq(feeToken.balanceOf(address(payments)), payerFunds + payeeFunds);

        assertEq(BURN_ADDRESS.balance, FIRST_AUCTION_START_PRICE);
    }
}
