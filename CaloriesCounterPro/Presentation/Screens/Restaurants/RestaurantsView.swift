import SwiftUI
import SwiftData

struct RestaurantsView: View {
    @Query(sort: \Restaurant.name, order: .forward)
    private var restaurants: [Restaurant]

    @Environment(\.modelContext) private var modelContext
    @State private var showAddSheet = false
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
            VStack(spacing: Theme.spacingL) {
                if restaurants.isEmpty {
                    VStack(spacing: Theme.spacingM) {
                        Image(systemName: "building.2")
                            .font(.system(size: 48))
                            .foregroundColor(Theme.textTertiary)

                        Text(String(localized: "restaurants.empty_title"))
                            .font(.title2.bold())
                            .foregroundColor(Theme.textSecondary)

                        Text(String(localized: "restaurants.empty_subtitle"))
                            .font(.subheadline)
                            .foregroundColor(Theme.textTertiary)
                            .multilineTextAlignment(.center)

                        Button(String(localized: "restaurants.add_first")) {
                            showAddSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, Theme.spacingXXL)
                } else {
                    List {
                        ForEach(filteredRestaurants) { restaurant in
                            NavigationLink {
                                RestaurantDetailView(restaurant: restaurant)
                            } label: {
                                HStack(spacing: Theme.spacingM) {
                                    Image(systemName: "fork.knife")
                                        .font(.title2)
                                        .foregroundColor(Theme.accent)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(restaurant.name)
                                            .font(.headline)

                                        HStack(spacing: 8) {
                                            Text(String(format: NSLocalizedString("restaurants.scan_count", comment: ""), restaurant.scanCount))
                                                .font(.caption)
                                                .foregroundColor(Theme.textSecondary)

                                            Text(String(format: NSLocalizedString("restaurants.total_cal", comment: ""), restaurant.totalCalories))
                                                .font(.caption)
                                                .foregroundColor(Theme.textSecondary)
                                        }
                                    }

                                    Spacer()

                                    if let lastDate = restaurant.lastScanDate {
                                        Text(String(format: NSLocalizedString("restaurants.last_scan", comment: ""), lastDate.formatted(date: .abbreviated, time: .omitted)))
                                            .font(.caption)
                                            .foregroundColor(Theme.textTertiary)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Theme.background)
            .navigationTitle(String(localized: "restaurants.title"))
            .searchable(text: $searchText, prompt: String(localized: "restaurants.search"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddRestaurantSheet()
            }
        }
    }
}

#Preview {
    RestaurantsView()
        .modelContainer(for: [Restaurant.self, MenuScan.self], inMemory: true)
}
