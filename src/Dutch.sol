// SPDX-License-Identifier: Apache-2.0 OR MIT
pragma solidity ^0.8.30;

import { exp2 } from "@prb-math/Common.sol";
import { UD60x18 } from "@prb-math/UD60x18.sol";

library Dutch {
    uint256 private constant INTERVAL = 7 days; 
    uint256 private constant PRECISION = 10 ** 18; 
    // decays smoothly by 1/4 every week
    // P * (4 ** -(delay / interval))
    // P / (4 ** (delay / interval))
    function decay(uint256 startPrice, uint256 elapsed) internal pure returns (uint256 price) {
        UD60x18 coefficient = UD60x18.wrap(startPrice);
        UD60x18 decayFactor = UD60x18.wrap(elapsed * PRECISION * 2 / INTERVAL).exp2();

        return coefficient.div(decayFactor).unwrap();
    }
}
