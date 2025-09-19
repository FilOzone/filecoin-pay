pragma solidity ^0.8.30;

import "forge-std/Script.sol";

import "../src/Payments.sol";
import "../test/mocks/MockERC20.sol";

contract Profile is Script {
    function createRail(address sender) public {
        vm.deal(sender, 2000 * 10 ** 18);

        vm.startBroadcast();

        MockERC20 token = new MockERC20("MockToken", "MOCK");

        Payments payments = new Payments();

        address from = sender;
        address to = sender;
        address operator = sender;
        address validator = address(0);

        uint256 commissionRateBps = 0;
        address serviceFeeRecipient = sender;
        
        uint256 rateAllowance = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        uint256 lockupAllowance = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        uint256 maxLockupPeriod = 0x00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

        payments.setOperatorApproval(address(token), operator, true, rateAllowance, lockupAllowance, maxLockupPeriod);

        uint256 railId = payments.createRail(address(token), from, to, validator, commissionRateBps, serviceFeeRecipient);

        uint256 amount = 10**18;
        token.mint(from, amount);
        token.approve(address(payments), amount);
        payments.deposit(address(token), from, amount);

        // TODO depositWithPermit
        // TODO depositWithPermitAndApproveOperator
        // TODO depositWithPermitAndIncreaseOperatorApproval
        // TODO increaseOperatorApproval


        payments.modifyRailPayment(railId, 10**6, 0);

        payments.modifyRailLockup(railId, 5, 10**6);

        payments.modifyRailPayment(railId, 10**3, 10**6);

        payments.settleRail{value:payments.NETWORK_FEE()}(railId, block.number);

        payments.withdraw(address(token), 10**6);

        payments.withdrawTo(address(token), to, 10**6);
    }

    function settleRail(address sender, Payments payments, uint256 railId) public {
        vm.deal(sender, 2000 * 10 ** 18);
        vm.startBroadcast();

        payments.settleRail{value:payments.NETWORK_FEE()}(railId, block.number);
    }

    function terminateRail(address sender, Payments payments, uint256 railId) public {
        vm.deal(sender, 2000 * 10 ** 18);
        vm.startBroadcast();

        payments.terminateRail(railId);

        // TODO settleTerminatedRailWithoutValidation
    }
}
