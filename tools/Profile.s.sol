pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {FVMCallActorById} from "fvm-solidity/mocks/FVMCallActorById.sol";
import {CALL_ACTOR_BY_ID} from "fvm-solidity/FVMPrecompiles.sol";

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

        payments.setOperatorApproval(token, operator, true, rateAllowance, lockupAllowance, maxLockupPeriod);

        uint256 railId = payments.createRail(token, from, to, validator, commissionRateBps, serviceFeeRecipient);

        uint256 amount = 10**18;
        token.mint(from, amount);
        token.approve(address(payments), amount);
        payments.deposit(token, from, amount);

        // TODO depositWithPermit
        // TODO depositWithPermitAndApproveOperator
        // TODO depositWithPermitAndIncreaseOperatorApproval
        // TODO increaseOperatorApproval


        payments.modifyRailPayment(railId, 10**6, 0);

        payments.modifyRailLockup(railId, 5, 10**6);

        payments.modifyRailPayment(railId, 10**3, 10**6);

        payments.settleRail(railId, block.number);

        payments.withdraw(token, 10**6);

        payments.withdrawTo(token, to, 10**6);
    }

    function settleRail(address sender, Payments payments, uint256 railId) public {
        vm.deal(sender, 2000 * 10 ** 18);
        vm.startBroadcast();

        payments.settleRail(railId, block.number);
    }

    function terminateRail(address sender, Payments payments, uint256 railId) public {
        vm.deal(sender, 2000 * 10 ** 18);
        vm.startBroadcast();

        payments.terminateRail(railId);

        // TODO settleTerminatedRailWithoutValidation
    }

    function endAuction(address sender, Payments payments, uint256 railId) public {
        vm.deal(sender, 2000 * 10 ** 18);

        Payments.RailView memory railView = payments.getRail(railId);
        IERC20 token = railView.token;

        (uint256 fullAmount,,,) = payments.accounts(token, address(payments));

        address recipient = address(0x4a6f6B9fF1fc974096f9063a45Fd12bD5B928AD1);

        FVMCallActorById precompileMock = new FVMCallActorById();
        vm.etch(CALL_ACTOR_BY_ID, address(precompileMock).code);

        vm.startBroadcast();

        payments.burnForFees{value: FIRST_AUCTION_START_PRICE}(token, recipient, fullAmount);
    }
}
