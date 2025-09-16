# Changelog

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- Support for ERC-3009 (Transfer with authorization) ([#214](https://github.com/FilOzone/filecoin-pay/pull/214))
- Support for relayers to submit deposit transactions ([#217](https://github.com/FilOzone/filecoin-pay/pull/217))
- Network fee charging in settlement operations ([#224](https://github.com/FilOzone/filecoin-pay/pull/224))
- IERC20 type improvements and label mapping keys ([#225](https://github.com/FilOzone/filecoin-pay/pull/225))

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

