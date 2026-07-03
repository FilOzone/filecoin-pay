# Filecoin Pay

The Filecoin Pay V1 contract enables ERC20 token payment flows through "rails" - automated payment channels between payers and recipients. The contract supports continuous rate based payments, one-time transfers, and payment validation during settlement.

## Documentation

| If you want to... | Read |
| --- | --- |
| Understand the model: accounts, rails, lockup, validators, operators | [Concepts](./docs/concepts.md) |
| Build a service contract or integrate as an operator: function reference, worked example, escape hatches | [Integration Guide](./docs/integration.md) |
| Monitor solvency and rail health from a dashboard or SDK: paid-until, runway, termination windows | [Monitoring](./docs/monitoring.md) |
| Dig into contract internals: settlement, rate-change segments, invariants, fees | [SPEC.md](./SPEC.md) |
| Find deployed contract addresses | [CHANGELOG.md](./CHANGELOG.md) |

**Notable sections:**

- [Per-Rail Lockup: the safety-hatch model](./docs/concepts.md#per-rail-lockup-the-guarantee-mechanism): why locked funds are a guarantee, not a pre-payment
- [Worked Example](./docs/integration.md#worked-example): a full deal lifecycle from deposit to withdrawal
- [Emergency Scenarios](./docs/integration.md#emergency-scenarios): escape hatches when an operator, validator, or counterparty misbehaves
- [Known Issues](./docs/integration.md#known-issues): current v1 quirks such as the operator lockup-usage leak (#274)

## Key Concepts

- **Account**: Represents a user's token balance and locked funds
- **Rail**: A payment channel between a payer and recipient with configurable terms
- **Validator**: An optional contract that acts as a trusted "arbitrator". It can:
  - Validate and modify payment amounts during settlement.
  - Veto a rail termination attempt from any party by reverting the `railTerminated` callback.
  - Decide the final financial outcome (the total payout) of a rail that has been successfully terminated.
- **Operator**: An authorized third party who can manage rails on behalf of payers

See [Concepts](./docs/concepts.md) for the full model.

## Deployment Info

Check the latest deployed contracts in [CHANGELOG.md](./CHANGELOG.md)

## Security Audits

The Filecoin-Pay contracts have undergone the following security audits:
- [Zellic Security Audit (August 2025)](https://github.com/Zellic/publications/blob/master/Filecoin%20Services%20Payments%20-%20Zellic%20Audit%20Report.pdf)
- [Composable Security Audit (January 2026)](./audits/Security_Review_Retest_Report_Filecoin_FilecoinPay.pdf)

## Contributing

We welcome contributions to the payments contract! To ensure consistency and quality across the project, please follow these guidelines when contributing.

### Before Contributing

- **New Features**: Always create an issue first and discuss with maintainers before implementing new features. This ensures alignment with project goals and prevents duplicate work.
- **Bug Fixes**: While you can submit bug fix PRs without prior issues, please include detailed reproduction steps in your PR description.

### Pull Request Guidelines

- **Link to Issue**: All feature PRs should reference a related issue (e.g., "Closes #123" or "Addresses #456").
- **Clear Description**: Provide a detailed description of what your PR does, why it's needed, and how to test it.
- **Tests**: Include comprehensive tests for new functionality or bug fixes.
- **Documentation**: Update relevant documentation for any API or behavior changes.

### Commit Message Guidelines

This project follows the [Conventional Commits specification](https://www.conventionalcommits.org/). All commit messages should be structured as follows:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools and libraries

**Examples:**
- `feat: add rail termination functionality`
- `fix: resolve settlement calculation bug`
- `docs: update README with new API examples`
- `chore: update dependencies`

Following these conventions helps maintain a clear project history and makes handling of releases and changelogs easier.

## License

Dual-licensed under [MIT](https://github.com/filecoin-project/lotus/blob/master/LICENSE-MIT) + [Apache 2.0](https://github.com/filecoin-project/lotus/blob/master/LICENSE-APACHE)
