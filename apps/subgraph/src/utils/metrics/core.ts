import { Address, Bytes, BigInt as GraphBN } from "@graphprotocol/graph-ts";
import {
  DailyMetric,
  PaymentsMetric,
  DailyTokenMetric,
  DailyOperatorMetric,
  WeeklyMetric,
  WeeklyTokenMetric,
} from "../../../generated/schema";
import { DateHelpers, PAYMENTS_NETWORK_STATS_ID, ZERO_BIG_INT } from "./constants";

// Core metric entity creation and loading functions
export class MetricsEntityManager {
  static loadOrCreateDailyMetric(timestamp: GraphBN): DailyMetric {
    const dayStart = DateHelpers.getDayStartTimestamp(timestamp.toI64());
    const id = Bytes.fromI64(dayStart);

    let metric = DailyMetric.load(Bytes.fromByteArray(id));

    if (!metric) {
      metric = new DailyMetric(Bytes.fromByteArray(id));
      metric.timestamp = GraphBN.fromI64(dayStart);
      metric.date = DateHelpers.getDateString(dayStart);

      // Initialize all fields to zero
      metric.filBurned = ZERO_BIG_INT;
      metric.railsCreated = ZERO_BIG_INT;
      metric.totalRailSettlements = ZERO_BIG_INT;
      metric.railsTerminated = ZERO_BIG_INT;
      metric.railsFinalized = ZERO_BIG_INT;
      metric.activeRailsCount = ZERO_BIG_INT;
      metric.uniquePayers = ZERO_BIG_INT;
      metric.uniquePayees = ZERO_BIG_INT;
      metric.uniqueOperators = ZERO_BIG_INT;
      metric.newAccounts = ZERO_BIG_INT;
    }

    return metric;
  }

  static loadOrCreateWeeklyMetric(timestamp: GraphBN): WeeklyMetric {
    const weekStart = DateHelpers.getWeekStartTimestamp(timestamp.toI64());
    const id = Bytes.fromI64(weekStart);

    let metric = WeeklyMetric.load(Bytes.fromByteArray(id));

    if (!metric) {
      metric = new WeeklyMetric(Bytes.fromByteArray(id));
      metric.timestamp = GraphBN.fromI64(weekStart);
      metric.week = DateHelpers.getWeek(weekStart);

      // Initialize all fields to zero
      metric.filBurned = ZERO_BIG_INT;
      metric.railsCreated = ZERO_BIG_INT;
      metric.totalRailSettlements = ZERO_BIG_INT;
      metric.railsTerminated = ZERO_BIG_INT;
      metric.railsFinalized = ZERO_BIG_INT;
      metric.activeRailsCount = ZERO_BIG_INT;
      metric.uniquePayers = ZERO_BIG_INT;
      metric.uniquePayees = ZERO_BIG_INT;
      metric.uniqueOperators = ZERO_BIG_INT;
      metric.newAccounts = ZERO_BIG_INT;
    }

    return metric;
  }

  static loadOrCreateTokenMetric(tokenAddress: Address, timestamp: GraphBN): DailyTokenMetric {
    const dayStart = DateHelpers.getDayStartTimestamp(timestamp.toI64());
    const id = tokenAddress.concat(Bytes.fromByteArray(Bytes.fromI64(dayStart)));

    let metric = DailyTokenMetric.load(Bytes.fromByteArray(id));

    if (!metric) {
      metric = new DailyTokenMetric(Bytes.fromByteArray(id));
      metric.token = tokenAddress;
      metric.timestamp = GraphBN.fromI64(dayStart);
      metric.date = DateHelpers.getDateString(dayStart);

      metric.volume = ZERO_BIG_INT;
      metric.deposit = ZERO_BIG_INT;
      metric.withdrawal = ZERO_BIG_INT;
      metric.settledAmount = ZERO_BIG_INT;
      metric.cumulativeSettledAmount = ZERO_BIG_INT;
      metric.commissionPaid = ZERO_BIG_INT;
      metric.activeRailsCount = ZERO_BIG_INT;
      metric.uniqueHolders = ZERO_BIG_INT;
      metric.totalLocked = ZERO_BIG_INT;
    }

    return metric;
  }

  static loadOrCreateWeeklyTokenMetric(tokenAddress: Address, timestamp: GraphBN): WeeklyTokenMetric {
    const weekStart = DateHelpers.getWeekStartTimestamp(timestamp.toI64());
    const id = tokenAddress.concat(Bytes.fromByteArray(Bytes.fromI64(weekStart)));

    let metric = WeeklyTokenMetric.load(Bytes.fromByteArray(id));

    if (!metric) {
      metric = new WeeklyTokenMetric(Bytes.fromByteArray(id));
      metric.token = tokenAddress;
      metric.timestamp = GraphBN.fromI64(weekStart);
      metric.week = DateHelpers.getWeek(weekStart);

      metric.volume = ZERO_BIG_INT;
      metric.deposit = ZERO_BIG_INT;
      metric.withdrawal = ZERO_BIG_INT;
      metric.settledAmount = ZERO_BIG_INT;
      metric.cumulativeSettledAmount = ZERO_BIG_INT;
      metric.commissionPaid = ZERO_BIG_INT;
      metric.activeRailsCount = ZERO_BIG_INT;
      metric.uniqueHolders = ZERO_BIG_INT;
    }

    return metric;
  }

  static loadOrCreateOperatorMetric(operatorAddress: Address, timestamp: GraphBN): DailyOperatorMetric {
    const dayStart = DateHelpers.getDayStartTimestamp(timestamp.toI64());
    const id = operatorAddress.concat(Bytes.fromByteArray(Bytes.fromI64(dayStart)));

    let metric = DailyOperatorMetric.load(Bytes.fromByteArray(id));

    if (!metric) {
      metric = new DailyOperatorMetric(Bytes.fromByteArray(id));
      metric.operator = operatorAddress;
      metric.timestamp = GraphBN.fromI64(dayStart);
      metric.date = DateHelpers.getDateString(dayStart);

      metric.volume = ZERO_BIG_INT;
      metric.settledAmount = ZERO_BIG_INT;
      metric.commissionEarned = ZERO_BIG_INT;
      metric.railsCreated = ZERO_BIG_INT;
      metric.settlementsProcessed = ZERO_BIG_INT;
      metric.uniqueClients = ZERO_BIG_INT;
      metric.totalApprovals = ZERO_BIG_INT;
    }

    return metric;
  }

  static loadOrCreatePaymentsMetric(): PaymentsMetric {
    const id = Bytes.fromUTF8(PAYMENTS_NETWORK_STATS_ID);
    let metric = PaymentsMetric.load(Bytes.fromByteArray(id));

    if (!metric) {
      metric = new PaymentsMetric(Bytes.fromByteArray(id));
      metric.totalRails = ZERO_BIG_INT;
      metric.totalOperators = ZERO_BIG_INT;
      metric.totalTokens = ZERO_BIG_INT;
      metric.totalAccounts = ZERO_BIG_INT;
      metric.totalFilBurned = ZERO_BIG_INT;
      metric.totalActiveRails = ZERO_BIG_INT;
      metric.totalTerminatedRails = ZERO_BIG_INT;
      metric.totalFinalizedRails = ZERO_BIG_INT;
    }

    return metric;
  }
}
