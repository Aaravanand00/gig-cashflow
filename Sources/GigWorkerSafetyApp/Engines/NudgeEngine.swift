import Foundation

/// Rule-based engine that evaluates income patterns and produces empowering, guilt-free nudges.
public struct NudgeEngine {
    
    /// Evaluates current metrics and returns an actionable NudgeMessage, if applicable.
    public static func evaluate(
        analysis: RollingAverageEngine.AnalysisResult,
        todayIncome: Double?,
        hasFixedExpenses: Bool
    ) -> NudgeMessage? {
        
        // 1. Setup Fixed Expenses Prompt
        if !hasFixedExpenses {
            return NudgeMessage(
                title: "First Step: Set Up Expenses 📋",
                body: "Enter your rent, EMI, and fuel costs so we can calculate your exact daily safety target.",
                type: .setupExpensesReminder,
                actionTitle: "Set Up Expenses"
            )
        }
        
        // 2. High Income Day Nudge (Positive Reinforcement)
        if let today = todayIncome, today >= 1000.0 && today > (analysis.rollingAverage * 1.4) {
            let surplus = today - analysis.rollingAverage
            let suggestedSavings = min(500.0, max(100.0, (surplus * 0.25).roundedToNearestFifty()))
            
            return NudgeMessage(
                title: "Great Day Today! 🎉",
                body: "Today you earned \(CurrencyFormatter.format(surplus)) above your 7-day average! Would you like to save \(CurrencyFormatter.format(suggestedSavings)) into your emergency fund?",
                type: .highIncomeSavings,
                actionTitle: "Save \(CurrencyFormatter.format(suggestedSavings))",
                suggestedSavingsAmount: suggestedSavings
            )
        }
        
        // 3. Low Income Trend Nudge (Supportive & Non-Guilt)
        if analysis.status == .red && analysis.activeDaysCount >= 3 {
            return NudgeMessage(
                title: "Tight Situation This Week 💡",
                body: "Gig work has natural ups and downs, no stress! Holding off on non-essential spending for the next 2-3 days will help bring you back to the safe zone.",
                type: .lowIncomeCaution,
                actionTitle: "Review Expenses"
            )
        }
        
        // 4. Milestone Buffer Nudge
        if analysis.coverageRatio >= 1.4 && analysis.activeDaysCount >= 5 {
            return NudgeMessage(
                title: "Strong Financial Buffer! 🛡️",
                body: "Your 7-day income is well ahead of your required expenses. You are comfortably safe for upcoming days!",
                type: .milestoneReached,
                actionTitle: "Savings Trend"
            )
        }
        
        return nil
    }
}

private extension Double {
    func roundedToNearestFifty() -> Double {
        return (self / 50.0).rounded() * 50.0
    }
}
