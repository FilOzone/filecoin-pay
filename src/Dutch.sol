// SPDX-License-Identifier: Apache-2.0 OR MIT
pragma solidity ^0.8.30;

import {exp2} from "@prb-math/Common.sol";
import {UD60x18, uUNIT} from "@prb-math/UD60x18.sol";

/**
 * @dev Recurring dutch auction
 */
library Dutch {
    uint256 public constant RESET_FACTOR = 4;
    uint256 public constant HALVING_INTERVAL = 3.5 days;

    /**
     * @notice Exponential decay by 1/4 per week
     * @param startPrice The initial price at elapsed = 0
     * @param elapsed The amount of time since the startPrice
     */
    function decay(uint256 startPrice, uint256 elapsed) internal pure returns (uint256 price) {
        UD60x18 coefficient = UD60x18.wrap(startPrice);
        UD60x18 decayFactor = UD60x18.wrap(elapsed * uUNIT / HALVING_INTERVAL).exp2();

        return coefficient.div(decayFactor).unwrap();
    }
}
