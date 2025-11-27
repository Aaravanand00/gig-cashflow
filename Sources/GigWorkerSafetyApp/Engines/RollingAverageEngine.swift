import Foundation

/// Core mathematical engine for GigWorkerSafety.
/// Computes 7-day rolling average income, total daily required expenses, safety score, and status classification.
public struct RollingAverageEngine {
    
    public struct AnalysisResult: Equatable {
        public let rollingAverage: Double
        public let dailyRequiredExpense: Double
        public let safetyScore: Double // rollingAverage - dailyRequiredExpense
        public let coverageRatio: Double // rollingAverage / dailyRequiredExpense
        public let status: SafetyStatus
        public let activeDaysCount: Int
        public let totalEarningsInWindow: Double
        public let hasOutlierSpike: Bool
        public let zeroIncomeDaysCount: Int
    }
    
    /// Calculates rolling safety metrics based on income entries and fixed expenses over a specified window (default 7 days).
    public static func analyze(
        incomeEntries: [IncomeEntry],
        fixedExpenses: [FixedExpense],
        windowDays: Int = 7,
        referenceDate: Date = Date()
    ) -> AnalysisResult {
        let calendar = Calendar.current
        let targetEnd = calendar.startOfDay(for: referenceDate)
        
        // 1. Calculate Daily Required Expense
        let totalDailyExpense = fixedExpenses.reduce(0.0) { $0 + $1.dailyEquivalent }
        
        // 2. Filter entries within the rolling window [referenceDate - (windowDays - 1), referenceDate]
        guard let windowStartDate = calendar.date(byAdding: .day, value: -(windowDays - 1), to: targetEnd) else {
            return fallbackEmptyResult(dailyExpense: totalDailyExpense)
        }
        
        let windowEntries = incomeEntries.filter { entry in
            let entryDay = calendar.startOfDay(for: entry.date)
            return entryDay >= windowStartDate && entryDay <= targetEnd
        }
        
        if windowEntries.isEmpty {
            return fallbackEmptyResult(dailyExpense: totalDailyExpense)
        }
        
        // Group entries by day to calculate daily totals
        var dailyTotals: [Date: Double] = [:]
        for entry in windowEntries {
            let day = calendar.startOfDay(for: entry.date)
            dailyTotals[day, default: 0.0] += entry.amount
        }
        
        let totalEarnings = windowEntries.reduce(0.0) { $0 + $1.amount }
        
        // Edge Case Handling: Number of effective days in divisor
        // If user just started today (Day 1), dividing by 7 immediately would show 1/7th income.
        // We use max(1, min(windowDays, totalUniqueDaysOrSpan)) for onboarding, but full windowDays when history is established.
        let oldestDateInWindow = windowEntries.map { calendar.startOfDay(for: $0.date) }.min() ?? targetEnd
        let daysSpan = (calendar.dateComponents([.day], from: oldestDateInWindow, to: targetEnd).day ?? 0) + 1
        
        // Effective divisor: if user has history spanning 7+ days, divisor is 7.
        // If user is brand new (e.g. 2 days of app usage), divisor is actual span days (1 to 7).
        let effectiveDivisor = max(1, min(windowDays, daysSpan))
        let rollingAvg = totalEarnings / Double(effectiveDivisor)
        
        // Zero-income days count within the active span
        let zeroDays = windowEntries.filter { $0.amount == 0 }.count
        
        // Outlier detection: Any single day earning > 3.0x the average
        let maxSingleDay = dailyTotals.values.max() ?? 0.0
        let hasSpike = maxSingleDay > (rollingAvg * 3.0) && maxSingleDay > 2000.0
        
        // Safety Score & Coverage Ratio
        let score = rollingAvg - totalDailyExpense
        let ratio: Double
        if totalDailyExpense <= 0 {
            ratio = rollingAvg > 0 ? 2.0 : 1.0
        } else {
            ratio = rollingAvg / totalDailyExpense
        }
        
        // Determine Red / Yellow / Green Status
        let status: SafetyStatus
        if totalDailyExpense <= 0 {
            status = .green
        } else if rollingAvg < totalDailyExpense {
            status = .red
        } else if rollingAvg < (totalDailyExpense * 1.25) {
            status = .yellow
        } else {
            status = .green
        }
        
        return AnalysisResult(
            rollingAverage: rollingAvg,
            dailyRequiredExpense: totalDailyExpense,
            safetyScore: score,
            coverageRatio: ratio,
            status: status,
            activeDaysCount: windowEntries.count,
            totalEarningsInWindow: totalEarnings,
            hasOutlierSpike: hasSpike,
            zeroIncomeDaysCount: zeroDays
        )
    }
    
    private static func fallbackEmptyResult(dailyExpense: Double) -> AnalysisResult {
        let status: SafetyStatus = (dailyExpense > 0) ? .red : .yellow
        return AnalysisResult(
            rollingAverage: 0.0,
            dailyRequiredExpense: dailyExpense,
            safetyScore: -dailyExpense,
            coverageRatio: 0.0,
            status: status,
            activeDaysCount: 0,
            totalEarningsInWindow: 0.0,
            hasOutlierSpike: false,
            zeroIncomeDaysCount: 0
        )
    }
}
