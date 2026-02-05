#!/usr/bin/env node
/**
 * Auction Bidder CLI
 * 
 * A tool for bidding on FilecoinPay fee auctions.
 */
import { Command } from 'commander'
import chalk from 'chalk'
import { createWalletClient, http, parseEther, type Address, type Chain } from 'viem'
import { privateKeyToAccount } from 'viem/accounts'
import { getChain } from '@filoz/synapse-core/chains'
import {
    listAllAuctions,
    getAuctionDetails,
    getPaymentsContract,
    formatFIL,
    formatTokenAmount,
    formatTimeAgo,
} from './auction.js'

const program = new Command()

program
    .name('auction-bidder')
    .description('CLI tool for bidding on FilecoinPay fee auctions')
    .version('1.0.0')

// LIST command
program
    .command('list')
    .description('List all active auctions')
    .option('-n, --network <network>', 'Network (mainnet or calibration)', 'mainnet')
    .option('-t, --token <address>', 'Check a specific token address')
    .action(async (options) => {
        const chainId = options.network === 'calibration' ? 314159 : 314
        const networkName = options.network === 'calibration' ? 'Calibration' : 'Mainnet'

        console.log(chalk.bold.cyan(`\nActive Auctions on Filecoin ${networkName}`))
        console.log(chalk.gray('━'.repeat(50)))

        const paymentsContract = getPaymentsContract(chainId)
        console.log(chalk.gray(`Payments Contract: ${paymentsContract}\n`))

        let auctions
        if (options.token) {
            const details = await getAuctionDetails(chainId, options.token as `0x${string}`, 'Custom')
            auctions = [details]
        } else {
            auctions = await listAllAuctions(chainId)
        }

        const activeAuctions = auctions.filter(a => a.hasAuction || a.available > 0n)

        if (activeAuctions.length === 0) {
            console.log(chalk.yellow('No active auctions found.'))
            console.log(chalk.gray('\nNote: Auctions only exist for ERC20 tokens that have accumulated fees.'))
            return
        }

        for (const auction of activeAuctions) {
            console.log(chalk.bold.white(`Token: ${auction.tokenSymbol} (${auction.token})`))
            console.log(`  ${chalk.green('Available:')} ${formatTokenAmount(auction.available)} ${auction.tokenSymbol}`)
            console.log(`  ${chalk.blue('Price:')} ${formatFIL(auction.currentPrice)} FIL`)
            if (auction.startTime > 0n) {
                console.log(`  ${chalk.gray('Started:')} ${formatTimeAgo(auction.startTime)}`)
            }
            console.log()
        }
    })

// BID command
program
    .command('bid')
    .description('Place a bid on an auction')
    .requiredOption('--token <address>', 'Token address to bid on')
    .requiredOption('--private-key <key>', 'Private key of the bidder')
    .option('--amount <amount>', 'Amount of tokens to request (default: all available)')
    .option('--pay <amount>', 'FIL amount to pay (default: calculated price)')
    .option('-n, --network <network>', 'Network (mainnet or calibration)', 'mainnet')
    .action(async (options) => {
        const chainId = options.network === 'calibration' ? 314159 : 314
        const networkName = options.network === 'calibration' ? 'Calibration' : 'Mainnet'
        const tokenAddress = options.token as Address

        console.log(chalk.bold.cyan(`\nPlacing Bid on Filecoin ${networkName}`))
        console.log(chalk.gray('━'.repeat(50)))

        const auction = await getAuctionDetails(chainId, tokenAddress)

        if (!auction.hasAuction) {
            console.log(chalk.red('Error: No active auction for this token.'))
            return
        }

        if (auction.available === 0n) {
            console.log(chalk.red('Error: No tokens available in auction.'))
            return
        }

        const requestAmount = options.amount
            ? BigInt(options.amount)
            : auction.available

        let bidValue: bigint
        if (options.pay) {
            bidValue = parseEther(options.pay)
        } else if (requestAmount === auction.available) {
            bidValue = auction.currentPrice
        } else {
            bidValue = (auction.currentPrice * requestAmount) / auction.available
        }

        console.log(chalk.white(`Token: ${tokenAddress}`))
        console.log(chalk.white(`Available: ${formatTokenAmount(auction.available)}`))
        console.log(chalk.white(`Requesting: ${formatTokenAmount(requestAmount)}`))
        console.log(chalk.white(`Price: ${formatFIL(bidValue)} FIL`))
        console.log()

        const chain = getChain(chainId) as Chain
        const account = privateKeyToAccount(options.privateKey as `0x${string}`)
        const walletClient = createWalletClient({
            account,
            chain,
            transport: http(),
        })

        console.log(chalk.gray(`Bidder: ${account.address}`))
        console.log(chalk.yellow('\nSubmitting transaction...'))

        try {
            const paymentsContract = getPaymentsContract(chainId)
            const paymentsAbi = getChain(chainId).contracts.payments.abi

            const hash = await walletClient.writeContract({
                address: paymentsContract,
                abi: paymentsAbi,
                functionName: 'burnForFees',
                args: [tokenAddress, account.address, requestAmount],
                value: bidValue,
            })

            console.log(chalk.green(`\n✓ Transaction submitted: ${hash}`))
            console.log(chalk.gray(`  View: https://${chainId === 314159 ? 'calibration.' : ''}filfox.info/en/tx/${hash}`))

            console.log(chalk.yellow('\nWaiting for confirmation...'))

            const { createPublicClient } = await import('viem')
            const publicClient = createPublicClient({ chain, transport: http() })
            const receipt = await publicClient.waitForTransactionReceipt({ hash })

            if (receipt.status === 'success') {
                console.log(chalk.green.bold('\nBid successful!'))
                console.log(chalk.white(`  Purchased: ${formatTokenAmount(requestAmount)} tokens`))
                console.log(chalk.white(`  Paid: ${formatFIL(bidValue)} FIL (burned)`))
            } else {
                console.log(chalk.red('\nTransaction failed'))
            }
        } catch (error: any) {
            console.log(chalk.red(`\nError: ${error.message || error}`))
            process.exit(1)
        }
    })

program.parse()