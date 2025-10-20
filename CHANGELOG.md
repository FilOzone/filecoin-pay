# Changelog

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added

### Changed

### Fixed

## [1.0.0] - M4: Filecoin Service Liftoff

This major version bump signifies that FilecoinPay v1.0.0 is the long-term stable version intended for production use on Filecoin Mainnet. This release is specifically prepared for `M4: Filecoin Service Liftoff`.

### Deployed
- **Calibration**: [TO_ADD_AFTER_DEPLOYMENT](https://calibration.filfox.info/en/address/)
- **Mainnet**: [TO_ADD_AFTER_DEPLOYMENT](https://filfox.info/en/address/)

### Added
- Performance optimization: Fee apportionment now occurs after settling all segments instead of per segment ([#248](https://github.com/FilOzone/filecoin-pay/pull/248))
  - Reduces redundant fee calculations
  - Simplifies bookkeeping in settlement operations
  - Applies network fee ceiling once instead of per segment
  - No breaking changes to public interfaces

### Changed
- **BREAKING**: Contract name changed from `Payments` to `FilecoinPayV1` for versioning scheme ([#235](https://github.com/FilOzone/filecoin-pay/issues/235), [#247](https://github.com/FilOzone/filecoin-pay/pull/247))
  - File renamed from `src/Payments.sol` to `src/FilecoinPayV1.sol`
  - All imports and references updated throughout codebase
  - **Migration note**: Existing integrations must update contract references to `FilecoinPayV1`
- Auction starting price updated to 0.0021 FIL ([#245](https://github.com/FilOzone/filecoin-pay/pull/245))

## [0.6.0] - Filecoin-Pay M3

### Deployed
- **Calibration**: [0x6dB198201F900c17e86D267d7Df82567FB03df5E](https://calibration.filfox.info/en/address/0x6dB198201F900c17e86D267d7Df82567FB03df5E)
- **Mainnet**: [0x7DaE6F488651ec5CEE38c9DFbd7d31223eAe1DDE](https://filfox.info/en/address/0x7DaE6F488651ec5CEE38c9DFbd7d31223eAe1DDE)

### Added
- Support for ERC-3009 (Transfer with authorization) ([#214](https://github.com/FilOzone/filecoin-pay/pull/214))
- Support for relayers to submit deposit transactions ([#217](https://github.com/FilOzone/filecoin-pay/pull/217))
- Network fee charging in settlement operations ([#224](https://github.com/FilOzone/filecoin-pay/pull/224))
- IERC20 type improvements and label mapping keys ([#225](https://github.com/FilOzone/filecoin-pay/pull/225))
- Fee auction functionality ([#229](https://github.com/FilOzone/filecoin-pay/pull/229))
- feat: burn via precompile ([#234](https://github.com/FilOzone/filecoin-pay/pull/234))
- Pagination support for `_getRailsForAddressAndToken` ([#237](https://github.com/FilOzone/filecoin-pay/pull/237))
- feat!: Update auction starting price to 0.5 FIL ([#243](https://github.com/FilOzone/filecoin-pay/pull/243))

### Changed
- Restored settlement permissions allowing any participant to settle rails ([#221](https://github.com/FilOzone/filecoin-pay/pull/221))

### Fixed
- Network fee handling in `settleTerminatedRailWithoutValidation` ([#223](https://github.com/FilOzone/filecoin-pay/pull/223))
- Add completed security audit report to readme ([#231](https://github.com/FilOzone/filecoin-pay/pull/231))


## [0.5.0] - Filecoin-Pay Developer Preview

⚠️ **DEPRECATION WARNING**: These contracts will be deprecated before October 15, 2025, due to 
upcoming breaking changes. 

**DO NOT use these deployments for production applications or to store significant value.** For updates and information about when the new set of Filecoin-Pay contracts will be deployed, track progress at: https://github.com/FilOzone/filecoin-pay/issues/232

### Deployed
- **Mainnet**: `[ADDRESS_TO_BE_UPDATED]`
- **Calibration**: [0x1096025c9D6B29E12E2f04965F6E64d564Ce0750](https://calibration.filfox.info/en/address/0x1096025c9D6B29E12E2f04965F6E64d564Ce0750)

### Added
- Automated ABI publishing on release ([#208](https://github.com/FilOzone/filecoin-pay/pull/208))

### Changed
- Updated alpha mainnet contract address in documentation ([#213](https://github.com/FilOzone/filecoin-pay/pull/213))
- Improved CI/CD workflow for project board management ([#215](https://github.com/FilOzone/filecoin-pay/pull/215))
- Settlement operations now accessible by any participant (payer, payee, or operator) ([#219](https://github.com/FilOzone/filecoin-pay/pull/219), [#220](https://github.com/FilOzone/filecoin-pay/pull/220))

### Fixed
- Network fee handling in `settleTerminatedRailWithoutValidation` ([#223](https://github.com/FilOzone/filecoin-pay/pull/223))
- Settlement permission logic corrections ([#220](https://github.com/FilOzone/filecoin-pay/pull/220))

## [0.2.0] - Mainnet Alpha

### Deployed
- **⚠️ WARNING**: This deployment may be deprecated within 1-month without migration support. DO NOT use for production applications or store significant value.
- Mainnet deployment: [`0x8c81C77E433725393Ba1eD5439ACdA098278eE1A`](https://etherscan.io/address/0x8c81C77E433725393Ba1eD5439ACdA098278eE1A)

### Added
- Complete payment rail system with streaming and one-time payments
- Per-rail lockup mechanisms for payment guarantees
- Operator system for delegated payment management  
- Optional validator interface for payment arbitration
- EIP-2612 permit support for gasless token approvals
- Emergency settlement capabilities
- Comprehensive account management functions

### Security
- Strict lockup enforcement to prevent underfunded payments
- Rate change queuing for accurate historical settlements
- Validator callback system for dispute resolution
- Emergency escape hatches for all participants

## [0.1.0] - Calibration Testnet

### Deployed  
- Calibration testnet: [`0x0E690D3e60B0576D01352AB03b258115eb84A047`](https://calibration.filfox.info/en/address/0x0E690D3e60B0576D01352AB03b258115eb84A047)

### Added
- Initial testnet deployment
- Core payment infrastructure
- Basic rail management functionality
- Account deposit/withdrawal system
