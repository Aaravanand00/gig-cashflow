import SwiftUI
import SwiftData

/// SwiftUI App Entry Point for GigWorkerSafety (RozgarSafe).
@main
public struct GigWorkerSafetyApp: App {
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            MainDashboardView()
                .modelContainer(for: [IncomeEntry.self, FixedExpense.self])
        }
    }
}
