/**
 * Auction utilities for fetching and formatting auction data
 */
import { createPublicClient, http, type Address, type Chain } from 'viem'
import { getChain } from '@filoz/synapse-core/chains'
import { auctionInfo, auctionFunds, auctionPriceAt, type AuctionInfo } from '@filoz/synapse-core/auction'

export interface AuctionDetails {
    token: Address
    tokenSymbol: string
    available: bigint
    currentPrice: bigint
    startPrice: bigint
    startTime: bigint
    hasAuction: boolean
}

// Known tokens to check for auctions
const KNOWN_TOKENS: Record<number, Array<{ address: Address; symbol: string }>> = {
    314: [
        { address: '0x80B98d3aa09ffff255c3ba4A241111Ff1262F045', symbol: 'USDFC' },
    ],
    314159: [
        { address: '0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0', symbol: 'USDFC' },
    ],
}

export function getClient(chainId: number) {
    const chain = getChain(chainId) as Chain
    return createPublicClient({
        chain,
        transport: http(),
    })
}

export function getPaymentsContract(chainId: number): Address {
    const chain = getChain(chainId)
    return chain.contracts.payments.address
}

export async function getAuctionDetails(
    chainId: number,
    tokenAddress: Address,
    tokenSymbol: string = 'UNKNOWN'
): Promise<AuctionDetails> {
    const client = getClient(chainId)

    try {
        const info = await auctionInfo(client, tokenAddress)
        const funds = await auctionFunds(client, tokenAddress)
        const now = BigInt(Math.floor(Date.now() / 1000))
        const currentPrice = auctionPriceAt(info, now)

        return {
            token: tokenAddress,
            tokenSymbol,
            available: funds,
            currentPrice,
            startPrice: info.startPrice,
            startTime: info.startTime,
            hasAuction: info.startPrice > 0n,
        }
    } catch (error) {
        return {
            token: tokenAddress,
            tokenSymbol,
            available: 0n,
            currentPrice: 0n,
            startPrice: 0n,
            startTime: 0n,
            hasAuction: false,
        }
    }
}

export async function listAllAuctions(chainId: number): Promise<AuctionDetails[]> {
    const tokens = KNOWN_TOKENS[chainId] || []
    const results: AuctionDetails[] = []

    for (const token of tokens) {
        const details = await getAuctionDetails(chainId, token.address, token.symbol)
        if (details.hasAuction || details.available > 0n) {
            results.push(details)
        }
    }

    return results
}

export function formatFIL(wei: bigint): string {
    const fil = Number(wei) / 1e18
    if (fil === 0) return '0'
    if (fil < 0.000001) return `${wei.toString()} wei`
    return fil.toFixed(6)
}

export function formatTokenAmount(wei: bigint, decimals: number = 18): string {
    const amount = Number(wei) / Math.pow(10, decimals)
    if (amount === 0) return '0'
    return amount.toLocaleString(undefined, { maximumFractionDigits: 6 })
}

export function formatTimeAgo(timestamp: bigint): string {
    const now = BigInt(Math.floor(Date.now() / 1000))
    const elapsed = now - timestamp

    if (elapsed < 60n) return `${elapsed}s ago`
    if (elapsed < 3600n) return `${elapsed / 60n}m ago`
    if (elapsed < 86400n) return `${elapsed / 3600n}h ago`
    return `${elapsed / 86400n}d ago`
}
