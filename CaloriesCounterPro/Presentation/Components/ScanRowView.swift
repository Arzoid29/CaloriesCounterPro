import SwiftUI

struct ScanRowView: View {
    let scan: MenuScan

    var body: some View {
        HStack(spacing: Theme.spacingM) {
            Image(systemName: "fork.knife")
                .font(.title2)
                .foregroundColor(Theme.accent)

            VStack(alignment: .leading, spacing: 4) {
                Text(scan.restaurantName.isEmpty ? String(localized: "history.default_name") : scan.restaurantName)
                    .font(.headline)

                HStack(spacing: 8) {
                    Text(String(format: NSLocalizedString("history.dishes_count", comment: ""), scan.dishes.count))
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)

                    Text(String(format: NSLocalizedString("history.calories", comment: ""), scan.totalCalories))
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
            }

            Spacer()

            Text(scan.date, style: .date)
                .font(.caption)
                .foregroundColor(Theme.textTertiary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        ScanRowView(scan: MenuScan(
            restaurantName: "La Terraza",
            rawText: "Pizza Margherita, Pasta Carbonara",
            dishes: []
        ))
    }
}
