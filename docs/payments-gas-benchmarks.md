# FilecoinPayV1 Gas Benchmarks

This file contains gas cost benchmarks for the payments contract.

**Note:** These benchmarks were measured on [DATE] against commit [COMMIT_HASH]. Results may vary with different contract versions or network conditions.

## Calibration Network Gas Costs

Below are the actual gas usage results for each FilecoinPayV1 contract operation, taken directly from transaction receipts on the Filecoin Calibration testnet after interacting with the FilecoinPayV1 contract.

- **Gas Used:** The total gas consumed by the transaction (from the receipt)
- **Base Fee (attoFIL):** The base fee per gas unit at the time of the transaction
- **Gas Fee (nanoFIL):** The total FIL paid for the transaction (in nanoFIL, for readability)
- **Tx Link:** Direct link to the transaction on Filscan for full details

| Operation                                 | Gas Used   | Base Fee (attoFIL) | Gas Fee (nanoFIL) | Tx Link                                                                                                                      |
|-------------------------------------------|------------|--------------------|-------------------|-----------------------------------------------------------------------------------------------------------------------------|
| deposit                                   | 20,625,602 | 100                | 4,906.5475        | [View](https://calibration.filscan.io/tx/0x2fe9dab2248d51fcedca613943dc5bbd77ba316c450f1b4ce49075076d5866de/)              |
| setOperatorApproval                       | 10,616,807 | 100                | 2,435.9343        | [View](https://calibration.filscan.io/tx/0x03688787c79446e11a394d70ee89529459b73582b620fc60484280b2195f7c93/)              |
| createRail                                | 14,541,402 | 100                | 3,008.6669        | [View](https://calibration.filscan.io/tx/0xc205e05b9adb2bf68a480fa157af2bc914e205fdea6bdc47ff5acfc5e77fbb06)               |
| modifyRailLockup                          | 19,127,193 | 100                | 3,862.7384        | [View](https://calibration.filscan.io/tx/0xa3876839e57603f395243423d7fa698071b17302c555aa5d2669d2afba21894f/)              |
| modifyRailPayment                         | 22,328,732 | 100                | 4,509.1863        | [View](https://calibration.filscan.io/tx/0x89dc79894fd15185c85b4b2514bca6d15fe50713040ce99d98408454e20c5524)               |
| terminateRail                             | 19,611,467 | 100                | 3,835.0452        | [View](https://calibration.filscan.io/tx/0x4dd8eadb5f25f75e3a37d104e20e7308f357efb3b354563d0ba949bc2d60baf2/)              |
| settleRail                                | 18,417,657 | 100                | 3,430.2870        | [View](https://calibration.filscan.io/tx/0xf9cb7f69b924008cba9f040369fdbc9c5644cbb7d289f34a3069fb65ada006a9/)              |
| settleTerminatedRailWithoutValidation     | 22,307,234 | 100                | 4,116.2309        | [View](https://calibration.filscan.io/tx/0x03a0226c8f88bafe87c9766596101a8a3868d2e1c9a6932c4fbd3dd6a7943670/)              |
| withdraw                                  | 19,012,089 | 100                | 3,504.0153        | [View](https://calibration.filscan.io/tx/0xf3f5431a6efb283c446fb15a849d381492682fd928ef26519c534fd52d572811/)              |
| withdrawTo                                | 20,653,139 | 100                | 3,722.0235        | [View](https://calibration.filscan.io/tx/0xe8f1f254fd63bc81700b5c95fdceda139e5f3e07f88cbb36228b7d63ddbf4377/)              |

### Notes

- These values represent the true cost users and operators pay on Filecoin FVM, including all protocol overhead.
- Gas costs can slightly vary based on contract state, network congestion (base fee), and operation complexity.
- These benchmarks were measured on 2025-07-17, with [this payments contract version](https://github.com/FilOzone/filecoin-services-payments/releases/tag/deployed%2Fcalibnet%2F0x0E690D3e60B0576D01352AB03b258115eb84A047. Results may vary with different contract versions or network conditions.
