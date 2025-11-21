import Foundation

/// Represents a rule-based smart nudge designed to encourage the gig worker
/// without any guilt or shame-based language.
public struct NudgeMessage: Identifiable, Equatable {
    public var id: UUID
    public var title: String
    public var body: String
    public var type: NudgeType
    public var actionTitle: String?
    public var suggestedSavingsAmount: Double?
    
    public enum NudgeType: String, Codable {
        case highIncomeSavings
        case lowIncomeCaution
        case milestoneReached
        case setupExpensesReminder
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        body: String,
        type: NudgeType,
        actionTitle: String? = nil,
        suggestedSavingsAmount: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.type = type
        self.actionTitle = actionTitle
        self.suggestedSavingsAmount = suggestedSavingsAmount
    }
}
