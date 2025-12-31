import SwiftUI

/// Step 1 - Daily Income Entry (2-tap max) UI.
/// Designed for low friction single-hand usage by gig workers.
public struct QuickIncomeEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SafetyDashboardViewModel
    
    @State private var amountText: String = ""
    @State private var selectedCategory: IncomeEntry.Category = .delivery
    @State private var note: String = ""
    
    public init(viewModel: SafetyDashboardViewModel) {
        self.viewModel = viewModel
    }
    
    private var amount: Double {
        Double(amountText) ?? 0.0
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header & Amount Display
                VStack(spacing: 8) {
                    Text("Today's Earnings")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text("₹")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(amountText.isEmpty ? "0" : amountText)
                            .font(.system(size: 52, weight: .heavy, design: .rounded))
                            .foregroundColor(amountText.isEmpty ? .secondary.opacity(0.5) : .primary)
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(16)
                
                // Quick Increment Chips (+₹100, +₹200, +₹500, +₹1000)
                HStack(spacing: 10) {
                    ForEach([100, 200, 500, 1000], id: \.self) { increment in
                        Button(action: { addIncrement(increment) }) {
                            Text("+\(increment)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(0.12))
                                .foregroundColor(.blue)
                                .cornerRadius(20)
                        }
                    }
                }
                
                // Category Chips (Optional / Default Skippable)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Income Source (Optional):")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(IncomeEntry.Category.allCases) { category in
                                Button(action: { selectedCategory = category }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: category.iconName)
                                        Text(category.label)
                                    }
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.blue : Color(uiColor: .tertiarySystemFill))
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(16)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
                
                // Custom Number Keypad
                KeypadView(amountText: $amountText)
                
                Spacer()
                
                // Tap 2: Save Button ("Save Income")
                Button(action: saveEntry) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Income")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(amount > 0 ? Color.green : Color.gray.opacity(0.4))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: amount > 0 ? Color.green.opacity(0.4) : Color.clear, radius: 8, x: 0, y: 4)
                }
                .disabled(amount <= 0)
            }
            .padding(20)
            .navigationTitle("Add Daily Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func addIncrement(_ value: Int) {
        let current = Double(amountText) ?? 0
        amountText = String(Int(current) + value)
    }
    
    private func saveEntry() {
        guard amount > 0 else { return }
        viewModel.addIncome(amount: amount, category: selectedCategory, note: note.isEmpty ? nil : note)
        dismiss()
    }
}

/// Custom touch keypad for zero-friction numeric entry.
struct KeypadView: View {
    @Binding var amountText: String
    
    let buttons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["C", "0", "⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 16) {
                    ForEach(row, id: \.self) { key in
                        Button(action: { keyTapped(key) }) {
                            Text(key)
                                .font(.system(size: 26, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity, minHeight: 54)
                                .background(keyColor(key))
                                .foregroundColor(keyTextColor(key))
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
    }
    
    private func keyTapped(_ key: String) {
        switch key {
        case "C":
            amountText = ""
        case "⌫":
            if !amountText.isEmpty {
                amountText.removeLast()
            }
        default:
            if amountText.count < 6 {
                if amountText == "0" {
                    amountText = key
                } else {
                    amountText += key
                }
            }
        }
    }
    
    private func keyColor(_ key: String) -> Color {
        if key == "C" || key == "⌫" {
            return Color.red.opacity(0.12)
        }
        return Color(uiColor: .secondarySystemFill)
    }
    
    private func keyTextColor(_ key: String) -> Color {
        if key == "C" || key == "⌫" {
            return .red
        }
        return .primary
    }
}
