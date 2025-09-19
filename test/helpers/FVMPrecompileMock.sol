// SPDX-License-Identifier: Apache-2.0 OR MIT
pragma solidity ^0.8.27;

/**
 * @title FVMPrecompileMock
 * @dev Mock contract for the FVM call_actor_id precompile used in testing
 * This simulates the behavior of the FVM precompile at 0xfe00000000000000000000000000000000000005
 */
contract FVMPrecompileMock {
    address payable private constant BURN_ADDRESS = payable(0xff00000000000000000000000000000000000063);

    /**
     * @dev Fallback function that handles delegatecalls from the Payments contract
     * Expects data encoded as: method(u64) | value(u256) | flags(u64) | codec(u64) | params(bytes) | actor_id(u64)
     */
    fallback() external payable {
        // Decode the input parameters
        (
            uint64 method,
            uint256 value,
            uint64 flags,
            uint64 codec,
            bytes memory params,
            uint64 actorId
        ) = abi.decode(msg.data, (uint64, uint256, uint64, uint64, bytes, uint64));

        // Verify this is a burn operation (actor ID 99, method 0)
        require(actorId == 99, "FVMPrecompileMock: Only burn actor (99) supported");
        require(method == 0, "FVMPrecompileMock: Only method 0 (send) supported");
        require(flags == 0, "FVMPrecompileMock: Only non-readonly calls supported");
        require(codec == 0, "FVMPrecompileMock: Only no-codec calls supported");
        require(params.length == 0, "FVMPrecompileMock: No params expected");

        // Perform the burn by sending to the burn address
        (bool success,) = BURN_ADDRESS.call{value: value}("");

        // Prepare the response in FVM format: exit_code(i256) | codec(u64) | return_value(bytes)
        bytes memory response;
        if (success) {
            // Success: exit code 0
            response = abi.encode(int256(0), uint64(0), bytes(""));
        } else {
            // Failure: exit code -1
            response = abi.encode(int256(-1), uint64(0), bytes(""));
        }

        // Return the response using assembly to properly handle delegatecall return
        assembly {
            return(add(response, 0x20), mload(response))
        }
    }

    /**
     * @dev Receive function to accept ETH for testing
     */
    receive() external payable {}
}