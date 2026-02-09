import SwiftUI

struct RestaurantPickerSheet: View {
    let restaurants: [Restaurant]
    @Binding var selectedRestaurant: Restaurant?
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredRestaurants: [Restaurant] {
        if searchText.isEmpty {
            return restaurants
        }
        return restaurants.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredRestaurants) { restaurant in
                    Button {
                        selectedRestaurant = restaurant
                        dismiss()
                    } label: {
                        HStack(spacing: Theme.spacingM) {
                            ZStack {
                                RoundedRectangle(cornerRadius: Theme.cornerRadiusTiny)
                                    .fill(Theme.accentBackground)
                                    .frame(width: 40, height: 40)

                                Image(systemName: "building.2.fill")
                                    .foregroundStyle(Theme.accent)
                            }

                            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                                Text(restaurant.name)
                                    .font(.headline)
                                    .foregroundStyle(Theme.textPrimary)

                                if restaurant.scanCount > 0 {
                                    Text(String(format: NSLocalizedString("restaurants.scan_count", comment: ""), restaurant.scanCount))
                                        .font(.caption)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                            }

                            Spacer()

                            if selectedRestaurant?.id == restaurant.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.accent)
                            }
                        }
                        .padding(.vertical, Theme.spacingXS)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(String(localized: "scanner.select_restaurant"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, prompt: String(localized: "restaurants.search"))
        }
    }
}

#Preview {
    RestaurantPickerSheet(
        restaurants: [
            Restaurant(name: "La Terraza"),
            Restaurant(name: "El Rincón"),
            Restaurant(name: "Pizzería Mario")
        ],
        selectedRestaurant: .constant(nil)
    )
}
