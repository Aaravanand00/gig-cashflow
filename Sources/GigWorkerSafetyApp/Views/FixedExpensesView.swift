import SwiftUI

/// Step 2 - Fixed Expense Setup View.
/// Manage recurring obligations (Rent, EMI, Fuel, etc.) and calculate daily target.
public struct FixedExpensesView: View {
    @ObservedObject var viewModel: FixedExpenseViewModel
    var onSaved: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: FixedExpenseViewModel, onSaved: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onSaved = onSaved
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // Summary Card Section
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Total Daily Required Target")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(CurrencyFormatter.formatDaily(viewModel.totalDailyExpense))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Approx Monthly")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(CurrencyFormatter.format(viewModel.totalMonthlyExpense))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        Text("💡 Covering this daily target is your primary financial goal.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Daily Target Summary")
                }
                
                // Add New Expense Section
                Section {
                    TextField("Expense Name (e.g. Rent, Vehicle EMI)", text: $viewModel.newTitle)
                    
                    HStack {
                        Text("Amount ₹")
                            .foregroundColor(.secondary)
                        TextField("e.g. 6000", text: $viewModel.newAmountString)
                            .keyboardType(.numberPad)
                    }
                    
                    Picker("Frequency", selection: $viewModel.selectedFrequency) {
                        ForEach(FixedExpense.Frequency.allCases) { freq in
                            Text(freq.label).tag(freq)
                        }
                    }
                    
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(FixedExpense.Category.allCases) { cat in
                            HStack {
                                Image(systemName: cat.iconName)
                                Text(cat.label)
                            }.tag(cat)
                        }
                    }
                    
                    Button(action: {
                        viewModel.addExpense()
                        onSaved?()
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                            Text("Add Recurring Expense")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .disabled(viewModel.newTitle.isEmpty || viewModel.newAmountString.isEmpty)
                } header: {
                    Text("Add Recurring Expense")
                }
                
                // Active Expenses List
                Section {
                    if viewModel.expenses.isEmpty {
                        Text("No fixed expenses added yet.")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(viewModel.expenses) { expense in
                            HStack {
                                Image(systemName: expense.category.iconName)
                                    .foregroundColor(.blue)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(expense.title)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                    Text("\(CurrencyFormatter.format(expense.amount)) / \(expense.frequency.label.lowercased())")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(CurrencyFormatter.formatDaily(expense.dailyEquivalent))
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    Text("Daily share")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onDelete { offsets in
                            viewModel.deleteExpense(at: offsets)
                            onSaved?()
                        }
                    }
                } header: {
                    Text("Your Fixed Expenses")
                }
            }
            .navigationTitle("Fixed Expense Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSaved?()
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
