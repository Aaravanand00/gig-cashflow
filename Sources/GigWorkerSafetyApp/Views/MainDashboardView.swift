import SwiftUI

/// Main App Screen - Gig Worker Financial Safety Dashboard (RozgarSafe).
public struct MainDashboardView: View {
    @StateObject private var viewModel = SafetyDashboardViewModel()
    @StateObject private var expenseViewModel = FixedExpenseViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Date & Subtitle
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("RozgarSafe 🛡️")
                                .font(.title)
                                .fontWeight(.black)
                                .foregroundColor(.primary)
                            Text("Gig Worker Financial Safety Indicator")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Test Simulator Quick Button (Developer / Evaluator Mode)
                        Button(action: { viewModel.isSimulatorPresented = true }) {
                            HStack(spacing: 4) {
                                Text("🧪 Test Mode")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.purple.opacity(0.12))
                            .foregroundColor(.purple)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Core UX: Visual Safety Indicator Gauge (Red / Yellow / Green)
                    SafetyGaugeView(result: viewModel.analysisResult)
                        .padding(.horizontal, 20)
                    
                    // Step 1: Big 2-Tap Income Entry Trigger Button
                    Button(action: { viewModel.isEntrySheetPresented = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Enter Today's Income")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text(viewModel.todayTotalIncome > 0 ? "Today Total: \(CurrencyFormatter.format(viewModel.todayTotalIncome))" : "2-tap fast entry, single tap save")
                                    .font(.caption)
                                    .opacity(0.9)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color(red: 0.1, green: 0.4, blue: 0.9)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(18)
                        .shadow(color: Color.blue.opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    
                    // Smart Nudges Card (If Active)
                    if let nudge = viewModel.activeNudge {
                        SmartNudgeCardView(nudge: nudge) {
                            handleNudgeAction(nudge)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Step 6: Weekly Trend Chart (SwiftUI Charts)
                    WeeklyTrendChartView(
                        entries: viewModel.incomeEntries,
                        dailyRequiredExpense: viewModel.analysisResult.dailyRequiredExpense
                    )
                    .padding(.horizontal, 20)
                    
                    // Quick Action Setup Cards
                    HStack(spacing: 14) {
                        Button(action: { viewModel.isExpenseSheetPresented = true }) {
                            VStack(alignment: .leading, spacing: 8) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                                Text("Fixed Expenses")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Text(CurrencyFormatter.formatDaily(viewModel.analysisResult.dailyRequiredExpense))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(14)
                        }
                        
                        Button(action: { viewModel.loadSampleData() }) {
                            VStack(alignment: .leading, spacing: 8) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                Text("Demo Sample Data")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Text("Load 7-day dummy data")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(14)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.isEntrySheetPresented) {
                QuickIncomeEntryView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.isExpenseSheetPresented) {
                FixedExpensesView(viewModel: expenseViewModel) {
                    viewModel.fixedExpenses = expenseViewModel.expenses
                    viewModel.refreshAnalysis()
                }
            }
            .sheet(isPresented: $viewModel.isSimulatorPresented) {
                TestSimulatorView(viewModel: viewModel)
            }
        }
    }
    
    private func handleNudgeAction(_ nudge: NudgeMessage) {
        switch nudge.type {
        case .setupExpensesReminder, .lowIncomeCaution:
            viewModel.isExpenseSheetPresented = true
        case .highIncomeSavings:
            if let amount = nudge.suggestedSavingsAmount {
                // Record a virtual emergency savings log or acknowledge savings
                viewModel.activeNudge = nil
            }
        case .milestoneReached:
            break
        }
    }
}
