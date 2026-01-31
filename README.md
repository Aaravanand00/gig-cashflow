# RozgarSafe 🛡️ - Gig Worker Financial Safety & Income Tracker

[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS 17](https://img.shields.io/badge/iOS-17.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![SwiftData](https://img.shields.io/badge/SwiftData-Offline--First-green.svg)](https://developer.apple.com/xcode/swiftdata/)

> **Cash-Flow Safety Indicator for Gig Economy Workers in India**
> (Zomato/Swiggy Delivery Partners, Ola/Uber Drivers, Freelancers & Daily Wage Workers)

---

## 📋 Problem Statement

Millions of gig workers in India do not have a fixed monthly salary. They earn unpredictable daily income depending on surge hours, weather, and demand. 

Existing budgeting apps (YNAB, MoneyView, Walnut) fail because:
1. **Fixed Monthly Budget Concept Fails**: When income is volatile, monthly budgeting is meaningless.
2. **Irrelevant Categorization**: "Shopping", "Entertainment" categories do not solve their daily survival question: *"How much did I earn today, and can I cover tomorrow's fuel/rent?"*
3. **Cash-Flow Anxiety**: Real problem is day-to-day certainty, not long-term wealth management.

---

## 🚀 Core Solution & MVP Scope

**RozgarSafe** replaces complex monthly budgets with a **7-day rolling average income engine** and a simple visual **Red / Yellow / Green Safety Indicator**:

1. **Step 1 - Daily Income Entry (2-Tap Max)**: Large keypad with quick single-tap entry. Optional category tags (Delivery, Rides, Tips) are default skippable.
2. **Step 2 - Fixed Expense Setup**: One-time setup of recurring costs (Rent, Bike EMI, Petrol, Mobile Recharge) with automatic daily equivalent calculation ($E_{daily}$).
3. **Step 3 - 7-Day Rolling Average Engine**: Computes rolling average income $I_{avg} = \frac{\sum \text{Last 7 Days}}{7}$ and compares against daily required expense baseline.
4. **Step 4 - Visual Safety Indicator (Core UX)**:
   - 🔴 **Red**: $I_{avg} < E_{daily}$ (Danger Zone / Deficit warning)
   - 🟡 **Yellow**: $E_{daily} \le I_{avg} < 1.25 \times E_{daily}$ (Caution / Barely covering)
   - 🟢 **Green**: $I_{avg} \ge 1.25 \times E_{daily}$ (Safe Zone / Comfortably covering)
5. **Step 5 - Smart Empowering Nudges**: Empowering rule-based nudges ("Great day today! Would you like to save ₹100?") without any guilt or shame language.
6. **Step 6 - Weekly Trend Chart**: SwiftUI `Charts` bar chart showing daily income vs required target baseline.
7. **TestSimulatorView 🧪**: Developer simulator allowing instant injection of fake multi-day datasets (Good Week, Tight Week, Zero Income, Outlier Day) to verify safety indicator behavior without multi-day wait.

---

## 🛠️ Project Architecture

```
GigWorkerSafety/
├── Package.swift
├── README.md
├── Docs/
│   └── ARCHITECTURE.md
├── Sources/
│   └── GigWorkerSafetyApp/
│       ├── GigWorkerSafetyApp.swift
│       ├── Models/
│       │   ├── IncomeEntry.swift
│       │   ├── FixedExpense.swift
│       │   ├── SafetyStatus.swift
│       │   └── NudgeMessage.swift
│       ├── Engines/
│       │   ├── RollingAverageEngine.swift
│       │   ├── NudgeEngine.swift
│       │   └── CurrencyFormatter.swift
│       ├── ViewModels/
│       │   ├── SafetyDashboardViewModel.swift
│       │   └── FixedExpenseViewModel.swift
│       └── Views/
│           ├── MainDashboardView.swift
│           ├── FixedExpensesView.swift
│           ├── TestSimulatorView.swift
│           └── Components/
│               ├── SafetyGaugeView.swift
│               ├── QuickIncomeEntryView.swift
│               ├── WeeklyTrendChartView.swift
│               └── SmartNudgeCardView.swift
└── Tests/
    └── GigWorkerSafetyAppTests/
        └── RollingAverageEngineTests.swift
```

---

## 🧪 Testing & Validation

### Automated Unit Tests (`XCTest`)
Run the test suite in Xcode or via Swift Package Manager:

- **`testRollingAverageStandard7Days`**: Verifies 7-day rolling mean computation.
- **`testEdgeCaseDay1NoHistory`**: Onboarding fallback gracefully handling 0 history and 1-day entry.
- **`testEdgeCaseZeroIncomeDaysCounted`**: Verifies 3 consecutive zero-income days drop the 7-day average accurately into Red status.
- **`testEdgeCaseOutlierHighIncomeDay`**: Single day spike (₹5,000 surge) detection.
- **`testFixedExpenseDailyEquivalent`**: Conversion of monthly/weekly expenses to daily equivalent.
- **`testCurrencyFormatterIndianCommas`**: Indian Rupee formatting (`₹1,250`, `₹1,00,000`).

### TestSimulatorView
Open the app and tap **🧪 Test Mode** in the top right header to inject test presets:
- **Good Week Preset**: Sets green status.
- **Tight Week Preset**: Sets red danger zone status.
- **Zero-Income 3 Days**: Verifies caution behavior.
- **Outlier High Day**: Injects ₹5,000 surge day.
