# Auction Bidder

A CLI tool for bidding on FilecoinPay fee auctions.

## Installation

```bash
cd tools/auction-bidder
npm install
npm run build
```

## Usage

### List Active Auctions

```bash
# Mainnet
npx auction-bidder list

# Calibration testnet
npx auction-bidder list --network calibration

# Check a specific token
npx auction-bidder list --network calibration --token 0x...
```

### Place a Bid

```bash
npx auction-bidder bid \
  --token 0xb3042... \
  --private-key 0x... \
  --network calibration
```

**Options:**
- `--token` (required) - Token address to bid on
- `--private-key` (required) - Bidder's private key  
- `--amount` (optional) - Amount to request (default: all)
- `--pay` (optional) - FIL amount to pay (default: calculated price)
- `--network` (optional) - `mainnet` or `calibration`

## Notes

The auction only applies to **ERC20 token fees**. Native FIL fees are burned directly during settlement.