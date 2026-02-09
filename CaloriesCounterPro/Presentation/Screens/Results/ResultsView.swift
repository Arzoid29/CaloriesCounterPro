import SwiftUI

struct ResultsView: View {
    let dishes: [Dish]
    let restaurantName: String
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedDish: Dish?

    var totalCalories: Int {
        dishes.reduce(0) { $0 + $1.estimatedCalories }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingXL) {
                summaryCard
                dishList
                disclaimerText
            }
            .padding()
        }
        .background(Theme.background)
        .navigationTitle(String(localized: "results.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onDismiss()
                    dismiss()
                } label: {
                    Text(String(localized: "results.new_scan"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                }
            }
        }
        .sheet(item: $selectedDish) { dish in
            DishDetailSheet(dish: dish)
                .presentationDetents([.medium, .large])
        }
    }

    private var summaryCard: some View {
        VStack(spacing: Theme.spacingM) {
            if !restaurantName.isEmpty {
                HStack(spacing: Theme.spacingXS) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(Theme.accent)
                    Text(restaurantName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.textSecondary)
                }
            }

            Text("\(totalCalories)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.accentGradient)

            Text(String(localized: "results.total_calories"))
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)

            HStack(spacing: Theme.spacingS) {
                Image(systemName: "fork.knife")
                    .font(.caption)
                Text(String(format: NSLocalizedString("results.dishes_detected", comment: ""), dishes.count))
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(Theme.textTertiary)
            .padding(.horizontal, Theme.spacingM)
            .padding(.vertical, Theme.spacingXS)
            .background(Theme.tertiaryBackground)
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.spacingXL)
        .background(Theme.accentBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }

    private var dishList: some View {
        VStack(spacing: Theme.spacingM) {
            ForEach(dishes) { dish in
                DishCardView(dish: dish)
                    .onTapGesture {
                        selectedDish = dish
                    }
            }
        }
    }

    private var disclaimerText: some View {
        HStack(spacing: Theme.spacingS) {
            Image(systemName: "info.circle")
                .font(.caption2)
            Text(String(localized: "results.disclaimer"))
                .font(.caption2)
        }
        .foregroundStyle(Theme.textTertiary)
        .multilineTextAlignment(.leading)
        .padding(Theme.spacingM)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusTiny))
    }
}

struct DishDetailSheet: View {
    let dish: Dish

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingL) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Theme.separator)
                    .frame(width: 36, height: 5)
                    .padding(.top, Theme.spacingS)

                Text(dish.name)
                    .font(.title2.bold())

                CalorieGaugeView(calories: dish.estimatedCalories)

                VStack(alignment: .leading, spacing: Theme.spacingM) {
                    if !dish.description.isEmpty {
                        DetailRow(icon: "text.alignleft", label: String(localized: "detail.description"), value: dish.description)
                    }
                    DetailRow(icon: "chart.bar.fill", label: String(localized: "detail.confidence"), value: dish.confidence.label)
                    if !dish.notes.isEmpty {
                        DetailRow(icon: "note.text", label: String(localized: "detail.notes"), value: dish.notes)
                    }
                }
                .padding(Theme.spacingL)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
            }
            .padding()
        }
        .background(Theme.background)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: Theme.spacingM) {
            Image(systemName: icon)
                .foregroundStyle(Theme.accent)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Theme.textTertiary)
                Text(value)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ResultsView(
            dishes: [
                Dish(name: "Tacos al Pastor", description: "3 tacos con piña y cilantro", estimatedCalories: 450, confidence: .high, notes: "Incluye tortilla de maíz"),
                Dish(name: "Enchiladas Suizas", description: "Con crema y queso gratinado", estimatedCalories: 620, confidence: .medium, notes: "Porción estándar con arroz"),
                Dish(name: "Agua de Horchata", estimatedCalories: 180, confidence: .high, notes: "Vaso de 500ml")
            ],
            restaurantName: "El Mexicano"
        ) { }
    }
}
