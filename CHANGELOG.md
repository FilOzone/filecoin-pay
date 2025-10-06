# Changelog

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added

### Changed

### Fixed

## [0.6.0] - Filecoin-Pay M3

### Deployed
- **Calibration**: [TBD]()
- **Mainnet**: [TBD]()

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
