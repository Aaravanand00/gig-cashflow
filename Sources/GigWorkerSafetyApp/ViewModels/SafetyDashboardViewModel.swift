import SwiftUI
import Combine

/// Main ViewModel managing dashboard state, income records, fixed expenses,
/// rolling average evaluation, and smart nudges.
@MainActor
public final class SafetyDashboardViewModel: ObservableObject {
    @Published public var incomeEntries: [IncomeEntry] = []
    @Published public var fixedExpenses: [FixedExpense] = []
    @Published public var analysisResult: RollingAverageEngine.AnalysisResult
    @Published public var activeNudge: NudgeMessage? = nil
    @Published public var isEntrySheetPresented: Bool = false
    @Published public var isExpenseSheetPresented: Bool = false
    @Published public var isSimulatorPresented: Bool = false
    
    public init(
        incomeEntries: [IncomeEntry] = [],
        fixedExpenses: [FixedExpense] = FixedExpense.defaultPresets
    ) {
        self.incomeEntries = incomeEntries
        self.fixedExpenses = fixedExpenses
        self.analysisResult = RollingAverageEngine.analyze(
            incomeEntries: incomeEntries,
            fixedExpenses: fixedExpenses
        )
        refreshAnalysis()
    }
    
    /// Recalculates 7-day rolling average and evaluates dynamic nudges.
    public func refreshAnalysis() {
        self.analysisResult = RollingAverageEngine.analyze(
            incomeEntries: incomeEntries,
            fixedExpenses: fixedExpenses
        )
        let todayIncome = todayTotalIncome
        self.activeNudge = NudgeEngine.evaluate(
            analysis: analysisResult,
            todayIncome: todayIncome,
            hasFixedExpenses: !fixedExpenses.isEmpty
        )
    }
    
    /// Total income recorded for the current day.
    public var todayTotalIncome: Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return incomeEntries
            .filter { calendar.startOfDay(for: $0.date) == today }
            .reduce(0.0) { $0 + $1.amount }
    }
    
    /// Adds a new income record (2-tap max flow).
    public func addIncome(amount: Double, category: IncomeEntry.Category = .other, note: String? = nil) {
        guard amount > 0 else { return }
        let newEntry = IncomeEntry(amount: amount, date: Date(), category: category, note: note)
        incomeEntries.append(newEntry)
        incomeEntries.sort(by: { $0.date > $1.date })
        refreshAnalysis()
    }
    
    /// Pre-populates sample data for demonstration.
    public func loadSampleData() {
        self.fixedExpenses = FixedExpense.defaultPresets
        self.incomeEntries = IncomeEntry.sampleEntries(lastNDays: 7, baseAmount: 750)
        refreshAnalysis()
    }
    
    /// Clears all recorded entries (reset for testing).
    public func resetAllData() {
        self.incomeEntries.removeAll()
        refreshAnalysis()
    }
}
