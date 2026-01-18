import SwiftUI

/// TestSimulatorView - Developer & QA Testing tool for manual fake daily-income data injection.
/// Allows instant testing of safety-indicator states (Red/Yellow/Green) without waiting multi-day usage.
public struct TestSimulatorView: View {
    @ObservedObject var viewModel: SafetyDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var customDayAmount: String = ""
    @State private var customDaysAgo: Int = 0
    
    public init(viewModel: SafetyDashboardViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            List {
                // Current State Overview Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Current Safety Status:")
                                .font(.subheadline)
                            Spacer()
                            Text(viewModel.analysisResult.status.badgeText)
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            Text("7-Day Avg Income:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(CurrencyFormatter.formatDaily(viewModel.analysisResult.rollingAverage))
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Daily Expense Target:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(CurrencyFormatter.formatDaily(viewModel.analysisResult.dailyRequiredExpense))
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Active Income Entries:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(viewModel.incomeEntries.count) days")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Live Indicator State")
                }
                
                // Quick Test Presets
                Section {
                    Button(action: applyGoodWeekPreset) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Good Week Preset (🟢 Safe Zone)")
                                    .fontWeight(.bold)
                                Text("7 days of strong earnings (~₹900/day)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button(action: applyTightWeekPreset) {
                        HStack {
                            Image(systemName: "exclamationmark.shield.fill")
                                .foregroundColor(.red)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Tight Week Preset (🔴 Danger Zone)")
                                    .fontWeight(.bold)
                                Text("7 days of low earnings (~₹250/day)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button(action: applyZeroIncomeStreakPreset) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Zero-Income 3 Days (🟡 Caution)")
                                    .fontWeight(.bold)
                                Text("4 normal days + 3 zero-income days")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button(action: applyOutlierSpikePreset) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.purple)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Outlier High Day (🟢 Spike)")
                                    .fontWeight(.bold)
                                Text("6 normal days + 1 surge day (₹5,000)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button(action: applyDay1Preset) {
                        HStack {
                            Image(systemName: "1.circle.fill")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Day 1 Onboarding")
                                    .fontWeight(.bold)
                                Text("Single day entry (₹600)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Instant Scenario Presets")
                }
                
                // Manual Single Day Injection
                Section {
                    HStack {
                        TextField("Amount (e.g. 750)", text: $customDayAmount)
                            .keyboardType(.numberPad)
                        
                        Picker("Days Ago", selection: $customDaysAgo) {
                            Text("Today").tag(0)
                            Text("1 Day Ago").tag(1)
                            Text("2 Days Ago").tag(2)
                            Text("3 Days Ago").tag(3)
                            Text("4 Days Ago").tag(4)
                            Text("5 Days Ago").tag(5)
                            Text("6 Days Ago").tag(6)
                        }
                    }
                    
                    Button(action: injectCustomDay) {
                        HStack {
                            Spacer()
                            Image(systemName: "plus.square.fill")
                            Text("Inject Fake Day Record")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .disabled(customDayAmount.isEmpty)
                } header: {
                    Text("Manual Single Day Injection")
                }
                
                // Reset Section
                Section {
                    Button(role: .destructive, action: {
                        viewModel.resetAllData()
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "trash.fill")
                            Text("Clear All Test Data")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Test Simulator 🧪")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Presets Logic
    
    private func applyGoodWeekPreset() {
        viewModel.incomeEntries.removeAll()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let amounts: [Double] = [850, 920, 1100, 780, 950, 1200, 880]
        
        for (offset, amount) in amounts.enumerated() {
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                viewModel.incomeEntries.append(IncomeEntry(amount: amount, date: date, category: .delivery))
            }
        }
        viewModel.refreshAnalysis()
    }
    
    private func applyTightWeekPreset() {
        viewModel.incomeEntries.removeAll()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let amounts: [Double] = [200, 250, 180, 300, 220, 150, 280]
        
        for (offset, amount) in amounts.enumerated() {
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                viewModel.incomeEntries.append(IncomeEntry(amount: amount, date: date, category: .rides))
            }
        }
        viewModel.refreshAnalysis()
    }
    
    private func applyZeroIncomeStreakPreset() {
        viewModel.incomeEntries.removeAll()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let amounts: [Double] = [0, 0, 0, 700, 650, 800, 750] // Today, 1d ago, 2d ago are zero
        
        for (offset, amount) in amounts.enumerated() {
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                viewModel.incomeEntries.append(IncomeEntry(amount: amount, date: date, category: .tips))
            }
        }
        viewModel.refreshAnalysis()
    }
    
    private func applyOutlierSpikePreset() {
        viewModel.incomeEntries.removeAll()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let amounts: [Double] = [5000, 400, 450, 400, 380, 420, 390] // Today is ₹5000 surge
        
        for (offset, amount) in amounts.enumerated() {
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                viewModel.incomeEntries.append(IncomeEntry(amount: amount, date: date, category: .tips))
            }
        }
        viewModel.refreshAnalysis()
    }
    
    private func applyDay1Preset() {
        viewModel.incomeEntries.removeAll()
        let today = Calendar.current.startOfDay(for: Date())
        viewModel.incomeEntries.append(IncomeEntry(amount: 600, date: today, category: .delivery))
        viewModel.refreshAnalysis()
    }
    
    private func injectCustomDay() {
        guard let amount = Double(customDayAmount) else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let targetDate = calendar.date(byAdding: .day, value: -customDaysAgo, to: today) {
            viewModel.incomeEntries.append(IncomeEntry(amount: amount, date: targetDate, category: .other))
            viewModel.refreshAnalysis()
        }
        customDayAmount = ""
    }
}
