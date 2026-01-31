# Architecture Reference - RozgarSafe (Gig Worker Financial Safety App)

## Overview
**RozgarSafe** is an offline-first iOS application designed specifically for gig economy workers (Zomato/Swiggy delivery partners, Ola/Uber driver partners, daily-wage freelancers) in India.

Instead of traditional monthly budgets (which fail due to volatile daily income), RozgarSafe operates on a **7-Day Rolling Average Engine** and presents financial standing as a **Visual Safety Indicator (Red/Yellow/Green)**.

---

## 1. Technical Stack

| Component | Framework / Tool | Purpose |
| :--- | :--- | :--- |
| **Language** | Swift 5.9+ | Primary programming language |
| **UI Framework** | SwiftUI (iOS 17+) | Modern declarative UI layout |
| **Persistence** | SwiftData (`@Model`) | Offline-first local data storage |
| **Charts** | SwiftUI `Charts` | Declarative 7-day trend visualization |
| **Testing** | XCTest + TestSimulatorView | Logic unit tests + interactive simulator view |

---

## 2. Core Engines & Mathematical Models

### 2.1 Fixed Expense Daily Equivalent Conversion
All user fixed expenses are converted into a standardized **Daily Required Expense Target** ($E_{daily}$):

$$E_{daily} = \sum \left( \frac{\text{Amount}_{monthly}}{30.4167} \right) + \sum \left( \frac{\text{Amount}_{weekly}}{7} \right) + \sum \text{Amount}_{daily}$$

*Example*: Rent ₹6,000/month ($\approx ₹197.26$/day) + Fuel ₹2,100/week ($₹300.00$/day) = $E_{daily} = ₹497.26/\text{day}$.

### 2.2 7-Day Rolling Average Calculation
Given income records within a 7-day window $[t-6, t]$:

$$I_{avg} = \frac{\sum_{i=t-6}^{t} \text{Income}_i}{\text{EffectiveDivisor}}$$

*Onboarding Handling*: For brand new users with history span $< 7$ days, $\text{EffectiveDivisor} = \max(1, \text{DaysSpan})$ to avoid artificial early deficit penalties. For established users, $\text{EffectiveDivisor} = 7$.

### 2.3 Safety Status Classification
The Coverage Ratio $R = \frac{I_{avg}}{E_{daily}}$ determines the Visual Safety Indicator state:

| Status | Threshold | Color Token | Meaning |
| :--- | :--- | :--- | :--- |
| 🔴 **Red** | $R < 1.0$ ($I_{avg} < E_{daily}$) | `#E13838` | Danger Zone: 7-day average is below daily target |
| 🟡 **Yellow** | $1.0 \le R < 1.25$ | `#F2A61F` | Caution Zone: Daily expenses are barely covered |
| 🟢 **Green** | $R \ge 1.25$ | `#26B361` | Safe Zone: Financial buffer is comfortably strong |

---

## 3. UI & Design Principles

1. **2-Tap Max Income Entry**: Big touch keypad, single tap save, skippable categories.
2. **Empowering, Non-Guilt Nudges**: No shame language ("you overspent"). Always positive reinforcement ("Great day today! Would you like to save ₹100?").
3. **Offline-First Persistence**: No signups, no login friction, no internet dependency.
4. **Developer Test Simulator (`TestSimulatorView`)**: Built-in developer tab allowing 1-tap loading of test scenarios (Good Week, Tight Week, Zero-Income Streak, Surge Day).

---

## 4. Model Schemas

```swift
@Model
final class IncomeEntry {
    var id: UUID
    var amount: Double
    var date: Date
    var categoryRawValue: String
    var note: String?
}

@Model
final class FixedExpense {
    var id: UUID
    var title: String
    var amount: Double
    var frequencyRawValue: String // Daily, Weekly, Monthly
    var categoryRawValue: String
}
```
