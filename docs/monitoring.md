# Filecoin Pay: Monitoring Account & Rail Health

> How to read on-chain state to compute a payer's solvency and a rail's standing: "paid until", runway, and termination windows. Part of the [Filecoin Pay documentation](../README.md); for the model see [Concepts](./concepts.md), for the functions see the [Integration Guide](./integration.md).

## Contents

- [Account solvency](#account-solvency)
- [Per-rail standing](#per-rail-standing)
- [Time and risk thresholds](#time-and-risk-thresholds)
- [Reference implementation](#reference-implementation)

Filecoin Pay exposes enough on-chain state for any client, payee, or dashboard to compute a payer's solvency and a rail's standing. The account-level computation is performed on-chain by [`getAccountInfoIfSettled`](./integration.md#getaccountinfoifsettledaddress-token-address-owner); the derived, human-facing values (a "paid until" date, days of runway, "at risk" thresholds) are computed off-chain.

These are generic payment-rail metrics. Service-specific figures (such as [FWSS](https://github.com/FilOzone/filecoin-services)'s storage price per TiB/month, how much to deposit for a given dataset, lockup reserve targets) belong to the service contract built on top or external tooling (such as SDKs).

## Account solvency

The read-only primitive [`getAccountInfoIfSettled`](./integration.md#getaccountinfoifsettledaddress-token-address-owner) returns the snapshot directly:

```
(fundedUntilEpoch, currentFunds, availableFunds, currentLockupRate) = getAccountInfoIfSettled(token, payer)
```

- `fundedUntilEpoch`: the epoch the account is projected to run dry at the current burn rate. In the past means already in deficit, and active rails can no longer settle forward.
- `availableFunds`: withdrawable right now (funds not reserved by lockup); clamps toward zero in deficit.
- `currentFunds`, `currentLockupRate`: the account's raw `funds` and aggregate `lockupRate` (total streaming spend per epoch across all the payer's active rails), passed through unchanged.

To compute these yourself (off-chain, or in another language) read the raw [account](./concepts.md#account) struct from the public `accounts(token, owner)` getter, which returns `(funds, lockupCurrent, lockupRate, lockupLastSettledAt)`, and apply the same arithmetic the contract uses:

```
fundedUntilEpoch = lockupRate == 0
                     ? type(uint256).max            // nothing streaming: funded indefinitely
                     : lockupLastSettledAt + (funds - lockupCurrent) / lockupRate

availableFunds   = funds - (lockupCurrent + lockupRate * (min(now, fundedUntilEpoch) - lockupLastSettledAt))

runway (epochs)  = fundedUntilEpoch > now ? fundedUntilEpoch - now : 0
debt             = max(0, (lockupCurrent + lockupRate * (now - lockupLastSettledAt)) - funds)   // > 0 only when underfunded
```

`lockupCurrent` and `lockupLastSettledAt` are not part of the primitive's return; they are the additional raw fields the computation reads from `accounts`.

Runway is **account-wide, not per-rail**: a payer with several rails shares one `lockupRate`, so "paid until" is a property of the account, not of any single rail. For a single-rail account they coincide. A per-service breakdown is a product concern, not something Filecoin Pay can answer.

## Per-rail standing

Enumerate a party's rails with [`getRailsForPayerAndToken`](./integration.md#getrailsforpayerandtokenaddress-payer-address-token) or [`getRailsForPayeeAndToken`](./integration.md#getrailsforpayeeandtokenaddress-payee-address-token), then read each with [`getRail`](./integration.md#getrailuint256-railid):

| Field | Meaning |
| --- | --- |
| `paymentRate` | this rail's streaming rate per epoch |
| `lockupPeriod` | guaranteed payee window after termination, in epochs |
| `lockupFixed` | reserved for one-time payments (not part of the streaming burn) |
| `settledUpTo` | last epoch settled to the payee |
| `endEpoch` | `0` while active; `> 0` once terminated |

Lifecycle (see [Per-Rail Lockup](./concepts.md#per-rail-lockup-the-guarantee-mechanism) for the model):

| State | Detect | Meaning |
| --- | --- | --- |
| Active | `getRail` succeeds, `endEpoch == 0` | streaming; settles only up to the payer's last fully-funded epoch |
| Terminated | `getRail` succeeds, `endEpoch > 0` | safety hatch armed; settles up to `endEpoch` from the streaming lockup. Remaining guaranteed window = `endEpoch - now` |
| Finalized | `getRail` reverts (`RailInactiveOrSettled`) | fully settled and zeroed |

## Time and risk thresholds

```
30 seconds/epoch   |   2880 epochs/day   |   86400 epochs/month

paidUntil (wall clock) ~= now() + (fundedUntilEpoch - currentEpoch) * 30s
```

A payer is **at risk** once account runway falls to roughly a rail's `lockupPeriod`: at that point a payee that terminates the rail would consume the entire remaining guarantee. That threshold is the natural trigger for an application-level top-up prompt. See [Best Practices for Payees](./concepts.md#best-practices-for-payees) for the payee-side risk routine.

## Reference implementation

The [Synapse SDK](https://github.com/FilOzone/synapse-sdk) mirrors this algorithm off-chain in its `synapse-core` `pay/` helpers, reconstructing `fundedUntilEpoch`, `availableFunds`, and runway from the same account fields. It is a useful worked TypeScript implementation if you would rather compute these values client-side than call `getAccountInfoIfSettled` on every read.
