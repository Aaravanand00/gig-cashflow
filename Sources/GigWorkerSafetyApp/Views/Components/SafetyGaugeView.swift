import SwiftUI

/// Core UX Feature: Visual Safety Indicator gauge comparing 7-day rolling average
/// against daily required expenses with zero numbers-heavy complexity.
public struct SafetyGaugeView: View {
    public let result: RollingAverageEngine.AnalysisResult
    
    @State private var animatedProgress: CGFloat = 0.0
    
    public init(result: RollingAverageEngine.AnalysisResult) {
        self.result = result
    }
    
    private var progressRatio: Double {
        if result.dailyRequiredExpense <= 0 { return 1.0 }
        return min(1.5, max(0.0, result.rollingAverage / result.dailyRequiredExpense))
    }
    
    private var progressNormalized: CGFloat {
        // Map 0.0 ... 1.5 ratio to 0.0 ... 1.0 progress fill
        return CGFloat(progressRatio / 1.5)
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Arc Gauge Meter
            ZStack {
                // Background Track Arc
                Circle()
                    .trim(from: 0.15, to: 0.85)
                    .stroke(
                        Color.gray.opacity(0.18),
                        style: StrokeStyle(lineWidth: 22, lineCap: .round)
                    )
                    .rotationEffect(.degrees(90))
                
                // Color Progress Fill Arc
                Circle()
                    .trim(from: 0.15, to: 0.15 + (0.70 * animatedProgress))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                result.status.themeColor.opacity(0.7),
                                result.status.themeColor
                            ]),
                            center: .center,
                            startAngle: .degrees(135),
                            endAngle: .degrees(405)
                        ),
                        style: StrokeStyle(lineWidth: 22, lineCap: .round)
                    )
                    .rotationEffect(.degrees(90))
                    .shadow(color: result.status.themeColor.opacity(0.4), radius: 8, x: 0, y: 4)
                
                // Center Status Content
                VStack(spacing: 6) {
                    Image(systemName: result.status.iconName)
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(result.status.themeColor)
                    
                    Text(result.status.badgeText)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(result.status.secondaryColor)
                        .foregroundColor(result.status.themeColor)
                        .cornerRadius(12)
                    
                    VStack(spacing: 2) {
                        Text("7-Day Avg Income")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(CurrencyFormatter.formatDaily(result.rollingAverage))
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 4)
                }
            }
            .frame(width: 220, height: 220)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    animatedProgress = progressNormalized
                }
            }
            .onChange(of: result) { oldValue, newValue in
                withAnimation(.easeInOut(duration: 0.8)) {
                    animatedProgress = progressNormalized
                }
            }
            
            // Status Description Card
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(result.status.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(result.status.themeColor)
                    Spacer()
                }
                
                Text(result.status.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Divider()
                    .padding(.vertical, 4)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daily Expense Target")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(CurrencyFormatter.formatDaily(result.dailyRequiredExpense))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Safety Margin")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        let diff = result.safetyScore
                        Text("\(diff >= 0 ? "+" : "")\(CurrencyFormatter.format(diff))")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(diff >= 0 ? .green : .red)
                    }
                }
            }
            .padding(16)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
    }
}
