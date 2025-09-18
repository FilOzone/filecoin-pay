// SPDX-License-Identifier: Apache-2.0 OR MIT
pragma solidity ^0.8.27;

import {ExtraFeeToken} from "./mocks/ExtraFeeToken.sol";
import {Payments} from "../src/Payments.sol";
import {Test} from "forge-std/Test.sol";

contract WithdrawExtraFeeTokenTest is Test {
    function testWithdrawFeeToken() public {
        Payments payments = new Payments();
        ExtraFeeToken feeToken = new ExtraFeeToken(10 ** 18);
        address user1 = vm.addr(0x1111);
        address user2 = vm.addr(0x2222);
        feeToken.mint(user1, 10 ** 24);
        feeToken.mint(user2, 10 ** 24);

        vm.prank(user1);
        feeToken.approve(address(payments), 10 ** 24);

        vm.prank(user2);
        feeToken.approve(address(payments), 10 ** 24);

        vm.prank(user1);
        vm.expectRevert();
        payments.deposit(feeToken, user1, 10 ** 24);

        vm.prank(user1);
        payments.deposit(feeToken, user1, 10 ** 23);

        assertEq(feeToken.balanceOf(address(payments)), 10 ** 23);
        (uint256 deposit,,,) = payments.accounts(feeToken, user1);
        assertEq(deposit, 10 ** 23);

        vm.prank(user1);
        vm.expectRevert();
        payments.withdraw(feeToken, 10 ** 23);

        vm.prank(user2);
        payments.deposit(feeToken, user2, 10 ** 23);

        // the other user's deposit should not allow the withdrawal
        vm.prank(user1);
        vm.expectRevert();
        payments.withdraw(feeToken, 10 ** 23);
    }
}
