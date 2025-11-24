import Foundation

/// Utility for formatting currency values according to Indian Numbering System (Lakhs, Thousands).
public struct CurrencyFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    /// Formats a double value to Indian Rupee string representation (e.g. ₹1,250 or ₹1,00,000).
    public static func format(_ amount: Double) -> String {
        let rounded = round(amount)
        if let formatted = formatter.string(from: NSNumber(value: rounded)) {
            return formatted
        }
        return "₹\(Int(rounded))"
    }

    /// Formats a daily required rate with a '/day' suffix.
    public static func formatDaily(_ amount: Double) -> String {
        return "\(format(amount))/day"
    }
}
