import SwiftUI

/// Visual Safety Indicator state comparing rolling 7-day average income against total daily required expenses.
public enum SafetyStatus: String, Codable, CaseIterable, Identifiable {
    case red = "Red"
    case yellow = "Yellow"
    case green = "Green"
    
    public var id: String { rawValue }
    
    /// Primary status title statement.
    public var title: String {
        switch self {
        case .red:
            return "Danger Zone: Income is Low"
        case .yellow:
            return "Caution Zone: Barely Covering Expenses"
        case .green:
            return "Safe Zone: Everything Looks Good!"
        }
    }
    
    /// Empowering status subtitle (supportive, non-guilt tone).
    public var subtitle: String {
        switch self {
        case .red:
            return "Your 7-day average is below required expenses. Consider extra hours or reducing fuel costs."
        case .yellow:
            return "You are covering basic expenses. Hold off on non-essential spending for now."
        case .green:
            return "Your earnings are comfortably covering expenses! Consider saving extra into an emergency fund."
        }
    }
    
    /// SwiftUI Color token.
    public var themeColor: Color {
        switch self {
        case .red: return Color(red: 0.88, green: 0.22, blue: 0.22)
        case .yellow: return Color(red: 0.95, green: 0.65, blue: 0.12)
        case .green: return Color(red: 0.15, green: 0.70, blue: 0.38)
        }
    }
    
    /// Secondary accent color for gradients and backgrounds.
    public var secondaryColor: Color {
        switch self {
        case .red: return Color.red.opacity(0.12)
        case .yellow: return Color.yellow.opacity(0.15)
        case .green: return Color.green.opacity(0.15)
        }
    }
    
    /// Icon system image name.
    public var iconName: String {
        switch self {
        case .red: return "exclamationmark.shield.fill"
        case .yellow: return "exclamationmark.triangle.fill"
        case .green: return "checkmark.shield.fill"
        }
    }
    
    /// Short status badge text.
    public var badgeText: String {
        switch self {
        case .red: return "🔴 High Risk"
        case .yellow: return "🟡 Caution"
        case .green: return "🟢 Safe Zone"
        }
    }
}
