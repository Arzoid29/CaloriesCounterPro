import SwiftUI

struct CalorieGaugeView: View {
    let calories: Int

    var body: some View {
        VStack(spacing: Theme.spacingS) {
            ZStack {
                Circle()
                    .stroke(Theme.border.opacity(0.5), lineWidth: 12)

                Circle()
                    .trim(from: 0, to: min(CGFloat(calories) / 1200, 1))
                    .stroke(
                        Theme.accent,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: calories)

                VStack(spacing: 2) {
                    Text("\(calories)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.accent)

                    Text(String(localized: "calories.unit"))
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .frame(width: 120, height: 120)

            Text(calorieLabel)
                .font(.caption.weight(.semibold))
                .foregroundColor(Theme.textTertiary)
                .padding(.horizontal, Theme.spacingM)
                .padding(.vertical, Theme.spacingXS)
                .background(Theme.accent.opacity(0.12))
                .clipShape(Capsule())
        }
    }

    private var calorieLabel: String {
        switch calories {
        case 0..<200: return String(localized: "calories.low")
        case 200..<500: return String(localized: "calories.moderate")
        case 500..<800: return String(localized: "calories.high")
        default: return String(localized: "calories.very_high")
        }
    }
}

#Preview {
    HStack(spacing: 24) {
        CalorieGaugeView(calories: 150)
        CalorieGaugeView(calories: 450)
        CalorieGaugeView(calories: 850)
    }
    .padding()
}
