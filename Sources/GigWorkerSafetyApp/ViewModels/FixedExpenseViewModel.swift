import SwiftUI
import Combine

/// ViewModel for managing fixed recurring expense obligations (Rent, EMI, Fuel, etc.).
@MainActor
public final class FixedExpenseViewModel: ObservableObject {
    @Published public var expenses: [FixedExpense] = []
    @Published public var newTitle: String = ""
    @Published public var newAmountString: String = ""
    @Published public var selectedFrequency: FixedExpense.Frequency = .monthly
    @Published public var selectedCategory: FixedExpense.Category = .rent
    
    public init(expenses: [FixedExpense] = FixedExpense.defaultPresets) {
        self.expenses = expenses
    }
    
    /// Total calculated daily required expense across all items.
    public var totalDailyExpense: Double {
        expenses.reduce(0.0) { $0 + $1.dailyEquivalent }
    }
    
    /// Total calculated monthly required expense across all items.
    public var totalMonthlyExpense: Double {
        totalDailyExpense * 30.4167
    }
    
    /// Adds a new expense item.
    public func addExpense() {
        guard let amount = Double(newAmountString), amount > 0, !newTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        let newExpense = FixedExpense(
            title: newTitle.trimmingCharacters(in: .whitespaces),
            amount: amount,
            frequency: selectedFrequency,
            category: selectedCategory
        )
        expenses.append(newExpense)
        resetForm()
    }
    
    /// Removes expense items at specified offsets.
    public func deleteExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
    }
    
    private func resetForm() {
        newTitle = ""
        newAmountString = ""
        selectedFrequency = .monthly
        selectedCategory = .rent
    }
}
