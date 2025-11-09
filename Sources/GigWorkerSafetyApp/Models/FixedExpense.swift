import Foundation
import SwiftData

/// Represents recurring fixed financial obligations set up by the user.
/// Automatically calculates daily required expense equivalent.
@Model
public final class FixedExpense: Identifiable {
    public var id: UUID
    public var title: String
    public var amount: Double
    public var frequencyRawValue: String
    public var categoryRawValue: String
    
    public enum Frequency: String, Codable, CaseIterable, Identifiable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        
        public var id: String { rawValue }
        
        public var label: String {
            switch self {
            case .daily: return "Daily"
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            }
        }
        
        public var daysMultiplier: Double {
            switch self {
            case .daily: return 1.0
            case .weekly: return 7.0
            case .monthly: return 30.4167 // Standard average days in a month
            }
        }
    }
    
    public enum Category: String, Codable, CaseIterable, Identifiable {
        case rent = "Room Rent"
        case emi = "Vehicle EMI"
        case fuel = "Fuel & Maintenance"
        case recharge = "Mobile & Data"
        case family = "Family Support"
        case food = "Daily Meals"
        case other = "Other Expenses"
        
        public var id: String { rawValue }
        
        public var label: String {
            switch self {
            case .rent: return "Room Rent"
            case .emi: return "Vehicle EMI"
            case .fuel: return "Fuel & Maintenance"
            case .recharge: return "Mobile & Data"
            case .family: return "Family Support"
            case .food: return "Daily Meals"
            case .other: return "Other Expenses"
            }
        }
        
        public var iconName: String {
            switch self {
            case .rent: return "house.fill"
            case .emi: return "creditcard.fill"
            case .fuel: return "fuelpump.fill"
            case .recharge: return "antenna.radiowaves.left.and.right"
            case .family: return "figure.2.and.child.holdinghands"
            case .food: return "fork.knife"
            case .other: return "list.bullet.rectangle.fill"
            }
        }
    }
    
    public var frequency: Frequency {
        get { Frequency(rawValue: frequencyRawValue) ?? .monthly }
        set { frequencyRawValue = newValue.rawValue }
    }
    
    public var category: Category {
        get { Category(rawValue: categoryRawValue) ?? .other }
        set { categoryRawValue = newValue.rawValue }
    }
    
    /// Calculates the daily equivalent expense for this recurring item.
    public var dailyEquivalent: Double {
        guard frequency.daysMultiplier > 0 else { return amount }
        return amount / frequency.daysMultiplier
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        frequency: Frequency = .monthly,
        category: Category = .other
    ) {
        self.id = id
        self.amount = max(0, amount)
        self.frequencyRawValue = frequency.rawValue
        self.categoryRawValue = category.rawValue
    }
}

extension FixedExpense {
    /// Default setup sample expenses for a typical gig worker in India.
    /// E.g. Room Rent ₹6000/mo (₹197/day), Fuel ₹2100/wk (₹300/day), Bike EMI ₹2500/mo (₹82/day), Mobile ₹300/mo (₹10/day)
    public static var defaultPresets: [FixedExpense] {
        [
            FixedExpense(title: "Room Rent", amount: 6000, frequency: .monthly, category: .rent),
            FixedExpense(title: "Fuel & Maintenance", amount: 2100, frequency: .weekly, category: .fuel),
            FixedExpense(title: "Vehicle EMI", amount: 2500, frequency: .monthly, category: .emi),
            FixedExpense(title: "Mobile Recharge", amount: 300, frequency: .monthly, category: .recharge)
        ]
    }
}
