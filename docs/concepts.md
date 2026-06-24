# Filecoin Pay: Key Concepts

> Part of the [Filecoin Pay documentation](../README.md). For contract internals, see [SPEC.md](../SPEC.md).

## Contents

- [Account](#account)
- [Rail](#rail)
- [Validator](#validator)
- [Operator](#operator)
- [Per-Rail Lockup: The Guarantee Mechanism](#per-rail-lockup-the-guarantee-mechanism)

- **Account**: Represents a user's token balance and locked funds
- **Rail**: A payment channel between a payer and recipient with configurable terms
- **Validator**: An optional contract that acts as a trusted "arbitrator". It can:
  - Validate and modify payment amounts during settlement.
  - Veto a rail termination attempt from any party by reverting the `railTerminated` callback.
  - Decide the final financial outcome (the total payout) of a rail that has been successfully terminated.
- **Operator**: An authorized third party who can manage rails on behalf of payers

### Account

Tracks the funds, lockup, obligations, etc. associated with a single “owner” (where the owner is a smart contract or a wallet). Accounts can be both *payers* and *payees* but we’ll often talk about them as if they were separate types.

- **Payer —** An account that *pays* a payee (this may be for a service, in which case we may refer to the Payer as the *Client*)
- **Payee** — An account which receives payment from a payer (this may be for a service, in which case we may refer to the Payee as the *Service Provider*).

### Rail

A rail along which payments flow from a payer to a payee. Rails track lockup, maximum payment rates, and obligations between a payer and a payee. Payer ↔ Payee pairs can have multiple payment rails between them but they can also reuse the same rail across multiple deals. Importantly, rails:
- Specify the maximum rate at which the payer will pay the payee, the actual amount paid for any given period is subject to validation by the **validator** described below.
- Define a lockup period. The lockup period of a rail is the time period over which the payer is required to maintain locked funds to fully cover the current outgoing payment rate from the rail if the payer stops adding funds to the account. This provides a reliable way for payees to verify that a payer is guaranteed to pay up to a certain point in the future. When a rail's payer account drops to only cover the lockup period this is a signal to the payee that the payer is at risk of defaulting. The lockup period gives the payee time to settle and gracefully close down the rail without missing payment.
- Strictly enforce lockups. While the contract cannot force a payer to deposit funds from their external wallet, it strictly enforces lockups on all funds held within their contract account. It prevents payers from withdrawing locked funds and blocks operator actions that would increase a payer's lockup obligation beyond their available balance. This system provides an easy way for payees to verify a payer's funding commitment for the rail.


### Validator

A validator is an optional contract that acts as a trusted arbitrator for a rail. Its primary role is to validate payments during settlement, but it also plays a crucial part in the rail's lifecycle, especially during termination.

When a validator is assigned to a rail, it gains the ability to:

-   **Mediate Payments:** During settlement, a validator can prevent a payment, refuse to settle past a certain epoch, or reduce the payout amount to account for actual services rendered, penalties, etc.
-   **Oversee Termination:** When `terminateRail` is called by either the payer or the operator, the FilecoinPayV1 contract makes a synchronous call to the validator's `railTerminated` function. The payee (payee) cannot directly terminate a rail.
-   **Veto Termination:** The validator can block the termination attempt entirely by reverting inside the `railTerminated` callback. This gives the validator the ultimate say on whether a rail can be terminated, irrespective of who initiated the call.

### Operator

An operator is a smart contract (typically the main contract for a given service) that manages payment rails on behalf of payers. It is also sometimes referred to as the "service contract". A payer must explicitly approve an operator and grant it specific allowances, which act as a budget for how much the operator can spend or lock up on the payer's behalf.

The operator role is powerful, so the operator contract must be trusted by both the payer and the payee. The payer trusts it not to abuse its spending allowances, and the payee trusts it to correctly configure and manage the payment rail.

An approved operator can perform the following actions:

-   **Create Rails (`createRail`):** Establish a new payment rail from a payer to a payee, specifying the token, payee, and an optional validator.
-   **Modify Rail Terms (`modifyRailLockup`, `modifyRailPayment`):** Adjust the payment rate, lockup period, and fixed lockup amount for any rail it manages. Any increase in the payer's financial commitment is checked against the operator's allowances.
-   **Execute One-Time Payments (`modifyRailPayment`):** Execute one-time payments from the rail's fixed lockup.
-   **Settle Rails (`settleRail`):** Trigger payment settlement for a rail to process due payments within the existing terms of the rail. As a rail participant, the operator can initiate settlement at any time. The operator cannot, however, arbitrarily settle a rail for a higher-than-expected amount or higher than expected duration.
-   **Terminate Rails (`terminateRail`):** End a payment rail. Unlike payers, an operator can terminate a rail even if the payer's account is not fully funded.

### Per-Rail Lockup: The Guarantee Mechanism

Each payment rail can be configured to require the payer to lock funds to guarantee future payments. This lockup is composed of two distinct components:

-   **Streaming Lockup (`paymentRate × lockupPeriod`):** A calculated guarantee for rate based payments for a pre-agreed lockup period.
-   **Fixed Lockup (`lockupFixed`):** A specific amount set aside for one-time payments.

The total lockup for a payer's account is the sum of these requirements across *all* their active rails. This total is reserved from their deposited funds and cannot be withdrawn.

#### The Crucial Role of Streaming Lockup: A Safety Hatch, Not a Pre-payment

It is critical to understand that the streaming lockup is **not** a pre-paid account that is drawn from during normal operation. Instead, it functions as a **safety hatch** that can only be fully utilized *after* a rail is terminated.

**1. During Normal Operation (Before Termination)**

While a rail is active, the streaming lockup acts as a **guarantee of solvency for a pre-agreed number of epochs**, not as a direct source of payment.

-   **Payments from General Funds:** When `settleRail` is called on an active rail, payments are drawn from the payer's general `funds`.
-   **Lockup as a Floor:** The lockup simply acts as a minimum balance. The contract prevents the payer from withdrawing funds below this floor.
-   **Settlement Requires Solvency:** Critically, the contract will only settle an active rail up to the epoch where the payer's account is fully funded (`lockupLastSettledAt`). If a payer stops depositing funds and their account becomes insolvent for new epochs, **settlement for new epochs will stop**, even if there is a large theoretical lockup. The lockup itself is not automatically spent.

**2. After Rail Termination (Activating the Safety Hatch)**

The true purpose of the streaming lockup is realized when a rail is terminated. It becomes a guaranteed payment window for the payee.

-   **Activating the Guarantee:** When `terminateRail` is called, the contract sets a final, unchangeable settlement deadline (`endEpoch`), calculated as the payer's last solvent epoch (`lockupLastSettledAt`) plus the `lockupPeriod`.
-   **Drawing from Locked Funds:** The contract now permits `settleRail` to process payments up to this `endEpoch`, drawing directly from the funds that were previously reserved by the lockup.
-   **Guaranteed Payment Window:** This mechanism is the safety hatch. It guarantees that the payee can continue to get paid for the full `lockupPeriod` after the payer's last known point of solvency. This protects the provider if a payer stops paying and disappears.

#### Fixed Lockup (`lockupFixed`)

The fixed lockup is more straightforward. It is a dedicated pool of funds for immediate, one-time payments. When an operator makes a one-time payment, the funds are drawn directly from `lockupFixed`, and the payer's total lockup requirement is reduced at the same time.

#### Detailed Example of Lockup Calculations

The following scenarios illustrate how the lockup for a single rail is calculated and how changes affect the payer's total lockup obligation.

Assume a rail is configured as follows:
- `paymentRate = 3 tokens/epoch`
- `lockupPeriod = 8 epochs`
- `lockupFixed = 7 tokens`

The total lockup requirement for this specific rail is:
`(3 tokens/epoch × 8 epochs) + 7 tokens = 31 tokens`

The payer's account must have at least 31 tokens in *available* funds before this lockup can be established. Once set, 31 tokens will be added to the payer's `Account.lockupCurrent`.

**Scenario 1: Making a One-Time Payment**
The operator makes an immediate one-time payment of 4 tokens.
- **Action:** `modifyRailPayment` is called with `oneTimePayment = 4`.
- **Result:** The 4 tokens are paid from the payer's `funds`. The `lockupFixed` on the rail is reduced to `3` (7 - 4).
- **New Lockup Requirement:** The rail's total lockup requirement drops to `(3 × 8) + 3 = 27 tokens`. The payer's `Account.lockupCurrent` is reduced by 4 tokens.

**Scenario 2: Increasing the Streaming Rate**
The operator needs to increase the payment rate to 4 tokens/epoch.
- **Action:** `modifyRailPayment` is called with `newRate = 4`.
- **New Lockup Requirement:** The rail's streaming lockup becomes `4 × 8 = 32 tokens`. The total requirement is now `32 + 3 = 35 tokens`.
- **Funding Check:** This change increases the rail's lockup requirement by 8 tokens (from 27 to 35). The transaction will only succeed if the payer's account has at least 8 tokens in available (non-locked) funds to cover this increase. If not, the call will revert.

**Scenario 3: Reducing the Lockup Period**
The operator reduces the lockup period to 5 epochs.
- **Action:** `modifyRailLockup` is called with `period = 5`.
- **New Lockup Requirement:** The streaming lockup becomes `3 × 5 = 15 tokens`. The total requirement is now `15 + 3 = 18 tokens`.
- **Result:** The rail's total lockup requirement is reduced from 27 to 18 tokens. This frees up 9 tokens in the payer's `Account.lockupCurrent`, which they can now withdraw (assuming no other lockups).


#### Best Practices for Payees

This lockup mechanism places clear responsibilities on the payee to manage risk:

-   **Settle Regularly:** Depending on the solvency guarantees put in place by the operator contract's lockup requirements, you must settle rails frequently. A rail's `lockupPeriod` is a measure of the risk you are willing to take. If you wait longer than the `lockupPeriod` to settle, you allow a payer to build up a payment obligation that may not be fully covered by the lockup guarantee if they become insolvent.
-   **Monitor Payer Solvency:** Use the `getAccountInfoIfSettled` function to check if a payer is funded. If their `fundedUntilEpoch` is approaching the current epoch, they are at risk.
-   **Terminate Proactively:** If a payer becomes insolvent or unresponsive, request the operator to terminate the rail immediately. This is the **only way** to activate the safety hatch and ensure you can claim payment from the funds guaranteed by the streaming lockup.
