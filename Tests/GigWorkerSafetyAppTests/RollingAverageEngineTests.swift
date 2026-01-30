import XCTest
@testable import GigWorkerSafetyApp

final class RollingAverageEngineTests: XCTestCase {
    
    private var defaultExpenses: [FixedExpense] {
        [
            FixedExpense(title: "Rent", amount: 6000, frequency: .monthly, category: .rent), // ~197.26 / day
            FixedExpense(title: "Fuel", amount: 2100, frequency: .weekly, category: .fuel)   // 300.00 / day
            // Total daily required ~ 497.26 / day
        ]
    }
    
    func testFixedExpenseDailyEquivalent() {
        let rent = FixedExpense(title: "Rent", amount: 6000, frequency: .monthly)
        let fuel = FixedExpense(title: "Fuel", amount: 2100, frequency: .weekly)
        let dailyFood = FixedExpense(title: "Food", amount: 150, frequency: .daily)
        
        XCTAssertEqual(rent.dailyEquivalent, 6000.0 / 30.4167, accuracy: 0.1)
        XCTAssertEqual(fuel.dailyEquivalent, 300.0, accuracy: 0.01)
        XCTAssertEqual(dailyFood.dailyEquivalent, 150.0, accuracy: 0.01)
    }
    
    func testRollingAverageStandard7Days() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var entries: [IncomeEntry] = []
        let dailyAmounts: [Double] = [700, 800, 600, 750, 900, 650, 800] // Total: 5200
        
        for (offset, amt) in dailyAmounts.enumerated() {
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            entries.append(IncomeEntry(amount: amt, date: date))
        }
        
        let result = RollingAverageEngine.analyze(
            incomeEntries: entries,
            fixedExpenses: defaultExpenses,
            windowDays: 7,
            referenceDate: today
        )
        
        let expectedAverage = 5200.0 / 7.0 // 742.857
        XCTAssertEqual(result.rollingAverage, expectedAverage, accuracy: 0.1)
        XCTAssertGreaterThan(result.rollingAverage, result.dailyRequiredExpense)
        XCTAssertEqual(result.status, .green)
    }
    
    func testEdgeCaseDay1NoHistory() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // 1. Completely empty entries
        let resultEmpty = RollingAverageEngine.analyze(
            incomeEntries: [],
            fixedExpenses: defaultExpenses,
            referenceDate: today
        )
        XCTAssertEqual(resultEmpty.rollingAverage, 0.0)
        XCTAssertEqual(resultEmpty.status, .red)
        
        // 2. Day 1 single entry (e.g. ₹600)
        let singleEntry = [IncomeEntry(amount: 600, date: today)]
        let resultDay1 = RollingAverageEngine.analyze(
            incomeEntries: singleEntry,
            fixedExpenses: defaultExpenses,
            referenceDate: today
        )
        // Day 1 divisor is 1 day span -> 600 / 1 = 600
        XCTAssertEqual(resultDay1.rollingAverage, 600.0, accuracy: 0.1)
        XCTAssertEqual(resultDay1.status, .green) // 600 > 497.26
    }
    
    func testEdgeCaseZeroIncomeDaysCounted() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var entries: [IncomeEntry] = []
        // 4 normal days (800) + 3 zero income days (0, 0, 0)
        let dailyAmounts: [Double] = [0, 0, 0, 800, 800, 800, 800] // Total: 3200
        
        for (offset, amt) in dailyAmounts.enumerated() {
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            entries.append(IncomeEntry(amount: amt, date: date))
        }
        
        let result = RollingAverageEngine.analyze(
            incomeEntries: entries,
            fixedExpenses: defaultExpenses,
            referenceDate: today
        )
        
        let expectedAverage = 3200.0 / 7.0 // ~457.14
        XCTAssertEqual(result.rollingAverage, expectedAverage, accuracy: 0.1)
        XCTAssertEqual(result.zeroIncomeDaysCount, 3)
        // 457.14 < 497.26 daily required -> RED status
        XCTAssertEqual(result.status, .red)
    }
    
    func testEdgeCaseOutlierHighIncomeDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var entries: [IncomeEntry] = []
        // 6 days of ₹400 + 1 surge day of ₹5,000
        let dailyAmounts: [Double] = [5000, 400, 400, 400, 400, 400, 400] // Total: 7400
        
        for (offset, amt) in dailyAmounts.enumerated() {
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            entries.append(IncomeEntry(amount: amt, date: date))
        }
        
        let result = RollingAverageEngine.analyze(
            incomeEntries: entries,
            fixedExpenses: defaultExpenses,
            referenceDate: today
        )
        
        let expectedAverage = 7400.0 / 7.0 // ~1057.14
        XCTAssertEqual(result.rollingAverage, expectedAverage, accuracy: 0.1)
        XCTAssertTrue(result.hasOutlierSpike)
        XCTAssertEqual(result.status, .green)
    }
    
    func testSafetyStatusThresholds() {
        let dailyExpense = 500.0
        let expenses = [FixedExpense(title: "Daily", amount: dailyExpense, frequency: .daily)]
        let today = Calendar.current.startOfDay(for: Date())
        
        // Scenario A: Income 400 < 500 -> Red
        let redEntries = (0..<7).map { i in
            IncomeEntry(amount: 400, date: Calendar.current.date(byAdding: .day, value: -i, to: today)!)
        }
        let resRed = RollingAverageEngine.analyze(incomeEntries: redEntries, fixedExpenses: expenses, referenceDate: today)
        XCTAssertEqual(resRed.status, .red)
        
        // Scenario B: Income 550 (1.1x cover) -> Yellow (between 1.0x and 1.25x)
        let yellowEntries = (0..<7).map { i in
            IncomeEntry(amount: 550, date: Calendar.current.date(byAdding: .day, value: -i, to: today)!)
        }
        let resYellow = RollingAverageEngine.analyze(incomeEntries: yellowEntries, fixedExpenses: expenses, referenceDate: today)
        XCTAssertEqual(resYellow.status, .yellow)
        
        // Scenario C: Income 700 (1.4x cover) -> Green (>= 1.25x)
        let greenEntries = (0..<7).map { i in
            IncomeEntry(amount: 700, date: Calendar.current.date(byAdding: .day, value: -i, to: today)!)
        }
        let resGreen = RollingAverageEngine.analyze(incomeEntries: greenEntries, fixedExpenses: expenses, referenceDate: today)
        XCTAssertEqual(resGreen.status, .green)
    }
    
    func testCurrencyFormatterIndianCommas() {
        let small = CurrencyFormatter.format(1250)
        let lakh = CurrencyFormatter.format(100000)
        
        XCTAssertTrue(small.contains("1,250") || small.contains("1250"))
        XCTAssertTrue(small.contains("₹"))
        XCTAssertTrue(lakh.contains("1,00,000") || lakh.contains("100000"))
    }
    
    func testNudgeEngineTriggers() {
        let result = RollingAverageEngine.AnalysisResult(
            rollingAverage: 600,
            dailyRequiredExpense: 500,
            safetyScore: 100,
            coverageRatio: 1.2,
            status: .yellow,
            activeDaysCount: 7,
            totalEarningsInWindow: 4200,
            hasOutlierSpike: false,
            zeroIncomeDaysCount: 0
        )
        
        // High income surge day nudge
        let surgeNudge = NudgeEngine.evaluate(analysis: result, todayIncome: 1200, hasFixedExpenses: true)
        XCTAssertNotNil(surgeNudge)
        XCTAssertEqual(surgeNudge?.type, .highIncomeSavings)
        XCTAssertTrue(surgeNudge?.actionTitle?.contains("Save") ?? false)
    }
}
