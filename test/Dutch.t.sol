// SPDX-License-Identifier: Apache-2.0 OR MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";

import {Dutch} from "../src/Dutch.sol";

contract DutchTest is Test {
    using Dutch for uint256;

    function checkExactDecay(uint256 startPrice) internal pure {
        assertEq(startPrice.decay(0), startPrice);
        assertEq(startPrice.decay(3.5 days), startPrice / 2);
        assertEq(startPrice.decay(7 days), startPrice / 4);
        assertEq(startPrice.decay(14 days), startPrice / 16);
        assertEq(startPrice.decay(21 days), startPrice / 64);
        assertEq(startPrice.decay(28 days), startPrice / 256);
        assertEq(startPrice.decay(35 days), startPrice / 1024);
    }

    function testDecay() public pure {
        checkExactDecay(.00000001 ether);
        checkExactDecay(.01 ether);
        checkExactDecay(9 ether);
        checkExactDecay(11 ether);
        checkExactDecay(13 ether);
    }
}
