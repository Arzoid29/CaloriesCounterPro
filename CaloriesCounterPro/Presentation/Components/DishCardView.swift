import SwiftUI

struct DishCardView: View {
    let dish: Dish

    var confidenceColor: Color {
        switch dish.confidence {
        case .high: return .green
        case .medium: return .orange
        case .low: return .red
        }
    }

    var body: some View {
        HStack(spacing: Theme.spacingM) {
            Circle()
                .fill(confidenceColor.gradient)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(dish.name)
                    .font(.headline)
                    .lineLimit(2)

                if !dish.description.isEmpty {
                    Text(dish.description)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(dish.estimatedCalories)")
                    .font(.title3.bold())
                    .foregroundStyle(Theme.accent)

                Text(String(localized: "calories.unit"))
                    .font(.caption2)
                    .foregroundStyle(Theme.textTertiary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Theme.textTertiary)
        }
        .padding(Theme.spacingL)
        .premiumCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(dish.name), \(dish.estimatedCalories) \(String(localized: "calories.unit")), \(confidenceAccessibilityLabel)")
    }

    private var confidenceAccessibilityLabel: String {
        switch dish.confidence {
        case .high: return String(localized: "accessibility.confidence_high")
        case .medium: return String(localized: "accessibility.confidence_medium")
        case .low: return String(localized: "accessibility.confidence_low")
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        DishCardView(dish: Dish(
            name: "Tacos al Pastor",
            description: "3 tacos con piña y cilantro",
            estimatedCalories: 450,
            confidence: .high,
            notes: ""
        ))
        DishCardView(dish: Dish(
            name: "Enchiladas Suizas",
            description: "Con crema y queso gratinado",
            estimatedCalories: 620,
            confidence: .medium,
            notes: ""
        ))
        DishCardView(dish: Dish(
            name: "Postre del día",
            estimatedCalories: 350,
            confidence: .low,
            notes: ""
        ))
    }
    .padding()
}
