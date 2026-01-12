import SwiftUI

/// Component rendering rule-based Hinglish nudges with empowering tone.
public struct SmartNudgeCardView: View {
    public let nudge: NudgeMessage
    public var onActionTapped: (() -> Void)? = nil
    
    public init(nudge: NudgeMessage, onActionTapped: (() -> Void)? = nil) {
        self.nudge = nudge
        self.onActionTapped = onActionTapped
    }
    
    private var cardGradientColors: [Color] {
        switch nudge.type {
        case .highIncomeSavings:
            return [Color.green.opacity(0.15), Color.blue.opacity(0.12)]
        case .lowIncomeCaution:
            return [Color.orange.opacity(0.15), Color.yellow.opacity(0.12)]
        case .milestoneReached:
            return [Color.blue.opacity(0.15), Color.purple.opacity(0.12)]
        case .setupExpensesReminder:
            return [Color.purple.opacity(0.15), Color.blue.opacity(0.12)]
        }
    }
    
    private var accentColor: Color {
        switch nudge.type {
        case .highIncomeSavings: return .green
        case .lowIncomeCaution: return .orange
        case .milestoneReached: return .blue
        case .setupExpensesReminder: return .purple
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: nudgeIcon)
                    .font(.title3)
                    .foregroundColor(accentColor)
                
                Text(nudge.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(nudge.body)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            if let actionTitle = nudge.actionTitle {
                Button(action: { onActionTapped?() }) {
                    HStack {
                        Text(actionTitle)
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Image(systemName: "arrow.right")
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: cardGradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(accentColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var nudgeIcon: String {
        switch nudge.type {
        case .highIncomeSavings: return "banknote.fill"
        case .lowIncomeCaution: return "lightbulb.fill"
        case .milestoneReached: return "sparkles"
        case .setupExpensesReminder: return "list.bullet.clipboard.fill"
        }
    }
}
