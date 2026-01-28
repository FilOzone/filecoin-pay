// SPDX-License-Identifier: Apache-2.0 OR MIT
pragma solidity ^0.8.27;

library RateChangeQueue {
    error EmptyQueue();

    struct RateChange {
        // The payment rate to apply
        uint256 rate;
        // The epoch up to and including which this rate will be used to settle a rail
        uint256 untilEpoch;
    }

    struct Queue {
        uint256 head;
        RateChange[] changes;
    }

    function enqueue(Queue storage queue, uint256 rate, uint256 untilEpoch) internal {
        queue.changes.push(RateChange(rate, untilEpoch));
    }

    function dequeue(Queue storage queue) internal returns (RateChange memory change) {
        RateChange[] storage c = queue.changes;
        require(queue.head < c.length, EmptyQueue());
        unchecked {
            change = c[queue.head];
            delete c[queue.head++];
        }
    }

    // Clears the storage of the Queue
    // If the queue isEmpty, all queue storage will be cleared
    function clearEmpty(Queue storage queue) internal {
        queue.head = 0;
        RateChange[] storage c = queue.changes;
        assembly ("memory-safe") {
            sstore(c.slot, 0)
        }
    }

    function peek(Queue storage queue) internal view returns (RateChange memory change) {
        require(queue.head < queue.changes.length, EmptyQueue());
        unchecked {
            change = queue.changes[queue.head];
        }
    }

    function peekTail(Queue storage queue) internal view returns (RateChange memory change) {
        require(queue.head < queue.changes.length, EmptyQueue());
        unchecked {
            change = queue.changes[queue.changes.length - 1];
        }
    }

    function isEmpty(Queue storage queue) internal view returns (bool) {
        return queue.head == queue.changes.length;
    }

    function size(Queue storage queue) internal view returns (uint256) {
        return queue.changes.length - queue.head;
    }
}
