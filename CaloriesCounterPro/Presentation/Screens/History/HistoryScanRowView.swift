import SwiftUI

struct HistoryScanRowView: View {
    let scan: MenuScan
    @State private var isFavorite: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.accentBackground)
                    .frame(width: 44, height: 44)
                Image(systemName: "fork.knife")
                    .font(.title2)
                    .foregroundStyle(Theme.accent)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(scan.restaurantName.isEmpty ? String(localized: "history.unknown_restaurant") : scan.restaurantName)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                Text(scan.scanDate, style: .date)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                HStack(spacing: 8) {
                    Label("\(scan.dishes.count)", systemImage: "fork.knife")
                        .font(.caption2)
                        .foregroundColor(Theme.textSecondary)
                    Label("\(scan.totalCalories) kcal", systemImage: "flame.fill")
                        .font(.caption2)
                        .foregroundColor(Theme.textSecondary)
                }
            }
            Spacer()
            Button(action: { isFavorite.toggle() }) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundColor(isFavorite ? .yellow : .gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Theme.cardShadowColor.opacity(0.08), radius: 2, y: 1)
    }
}

#Preview {
    HistoryScanRowView(scan: MenuScan(restaurantName: "Ejemplo", rawText: "Menu", dishes: [], restaurant: nil))
}
