import Foundation
import SwiftData

/// Represents a daily income record created by the gig worker.
/// Supports offline-first persistence using SwiftData (@Model).
@Model
public final class IncomeEntry: Identifiable {
    public var id: UUID
    public var amount: Double
    public var date: Date
    public var categoryRawValue: String
    public var note: String?
    
    public enum Category: String, Codable, CaseIterable, Identifiable {
        case delivery = "Delivery"
        case rides = "Rides"
        case tips = "Tips"
        case dailyWage = "Daily Wage"
        case other = "Other"
        
        public var id: String { rawValue }
        
        public var label: String {
            switch self {
            case .delivery: return "Delivery (Zomato/Blinkit)"
            case .rides: return "Rides (Ola/Uber)"
            case .tips: return "Tips & Incentives"
            case .dailyWage: return "Daily Wage"
            case .other: return "Other Income"
            }
        }
        
        public var iconName: String {
            switch self {
            case .delivery: return "shippingbox.fill"
            case .rides: return "car.fill"
            case .tips: return "gift.fill"
            case .dailyWage: return "hammer.fill"
            case .other: return "dollarsign.circle.fill"
            }
        }
    }
    
    public var category: Category {
        get { Category(rawValue: categoryRawValue) ?? .other }
        set { categoryRawValue = newValue.rawValue }
    }
    
    public init(
        id: UUID = UUID(),
        amount: Double,
        date: Date = Date(),
        category: Category = .other,
        note: String? = nil
    ) {
        self.id = id
        self.amount = max(0, amount)
        self.date = Calendar.current.startOfDay(for: date)
        self.categoryRawValue = category.rawValue
        self.note = note
    }
}

extension IncomeEntry {
    /// Mock dataset generator for previews and unit tests.
    public static func sampleEntries(lastNDays days: Int, baseAmount: Double = 600) -> [IncomeEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var entries: [IncomeEntry] = []
        
        for dayOffset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            // Add slight realistic variation
            let variation = Double((dayOffset * 137) % 300) - 150.0
            let amount = max(100.0, baseAmount + variation)
            let cat: Category = (dayOffset % 2 == 0) ? .delivery : .rides
            entries.append(IncomeEntry(amount: amount, date: date, category: cat))
        }
        return entries.sorted(by: { $0.date < $1.date })
    }
}
