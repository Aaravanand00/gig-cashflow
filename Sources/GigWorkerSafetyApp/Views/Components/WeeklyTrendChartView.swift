import SwiftUI
import Charts

/// Step 6 - Weekly/Trend View using SwiftUI Charts.
/// Displays daily income pattern vs required daily expense threshold line.
public struct WeeklyTrendChartView: View {
    public let entries: [IncomeEntry]
    public let dailyRequiredExpense: Double
    
    public init(entries: [IncomeEntry], dailyRequiredExpense: Double) {
        self.entries = entries
        self.dailyRequiredExpense = dailyRequiredExpense
    }
    
    private var chartData: [DailyTrendPoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var points: [DailyTrendPoint] = []
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let total = entries
                .filter { calendar.startOfDay(for: $0.date) == date }
                .reduce(0.0) { $0 + $1.amount }
            
            let label = dayLabel(for: date)
            points.append(DailyTrendPoint(date: date, dayLabel: label, amount: total))
        }
        return points
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEE" // Short day name e.g. Mon, Tue
        return formatter.string(from: date)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Last 7 Days Pattern")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Daily income vs expense target baseline")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            if chartData.allSatisfy({ $0.amount == 0 }) {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No income data recorded for the last 7 days")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 160)
            } else {
                Chart {
                    // Daily Income Bars
                    ForEach(chartData) { point in
                        BarMark(
                            x: .value("Day", point.dayLabel),
                            y: .value("Income", point.amount)
                        )
                        .cornerRadius(6)
                        .foregroundStyle(
                            point.amount >= dailyRequiredExpense ?
                            Color.green.gradient : Color.orange.gradient
                        )
                    }
                    
                    // Required Expense Target Baseline RuleMark
                    if dailyRequiredExpense > 0 {
                        RuleMark(
                            y: .value("Daily Expense Target", dailyRequiredExpense)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .foregroundStyle(Color.red)
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Target: \(CurrencyFormatter.format(dailyRequiredExpense))")
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.12))
                                .foregroundColor(.red)
                                .cornerRadius(4)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        if let amount = value.as(Double.self) {
                            AxisValueLabel {
                                Text("₹\(Int(amount))")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .frame(height: 180)
            }
            
            // Legend Footer
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Circle().fill(Color.green).frame(width: 8, height: 8)
                    Text("Target Covered")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                HStack(spacing: 6) {
                    Circle().fill(Color.orange).frame(width: 8, height: 8)
                    Text("Target Low")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                HStack(spacing: 6) {
                    Rectangle().fill(Color.red).frame(width: 12, height: 2)
                    Text("Daily Target")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

public struct DailyTrendPoint: Identifiable {
    public var id: Date { date }
    public let date: Date
    public let dayLabel: String
    public let amount: Double
}
