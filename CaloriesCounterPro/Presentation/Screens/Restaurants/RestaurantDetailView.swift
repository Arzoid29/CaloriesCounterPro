import SwiftUI
import SwiftData

struct RestaurantDetailView: View {
    @Bindable var restaurant: Restaurant
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var showErrorAlert = false
    @State private var errorAlertMessage = ""

    var body: some View {
        List {
            Section {
                restaurantHeader
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            if !restaurant.address.isEmpty || !restaurant.notes.isEmpty {
                Section(String(localized: "restaurant.info_section")) {
                    if !restaurant.address.isEmpty {
                        Label(restaurant.address, systemImage: "mappin.and.ellipse")
                            .foregroundStyle(Theme.textSecondary)
                    }
                    if !restaurant.notes.isEmpty {
                        Label(restaurant.notes, systemImage: "note.text")
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }

            Section(String(localized: "restaurant.stats_section")) {
                HStack {
                    StatItemView(
                        icon: "doc.text.viewfinder",
                        value: "\(restaurant.scanCount)",
                        label: String(localized: "restaurant.total_scans")
                    )

                    Divider()

                    StatItemView(
                        icon: "flame.fill",
                        value: "\(restaurant.totalCalories)",
                        label: String(localized: "restaurant.total_calories")
                    )

                    Divider()

                    StatItemView(
                        icon: "calendar",
                        value: restaurant.dateAdded.formatted(date: .abbreviated, time: .omitted),
                        label: String(localized: "restaurant.date_added")
                    )
                }
                .padding(.vertical, Theme.spacingS)
            }

            Section(String(localized: "restaurant.scans_section")) {
                if restaurant.scans.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: Theme.spacingS) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.largeTitle)
                                .foregroundStyle(Theme.textTertiary)
                            Text(String(localized: "restaurant.no_scans"))
                                .font(.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .padding(.vertical, Theme.spacingXL)
                        Spacer()
                    }
                } else {
                    ForEach(sortedScans) { scan in
                        NavigationLink {
                            ResultsView(
                                dishes: scan.dishes,
                                restaurantName: scan.restaurantName
                            ) { }
                        } label: {
                            ScanRowView(scan: scan)
                        }
                    }
                    .onDelete(perform: deleteScan)
                }
            }
        }
        .listStyle(.insetGrouped)
        .background(Theme.background)
        .navigationTitle(restaurant.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showEditSheet = true
                    } label: {
                        Label(String(localized: "restaurant.edit"), systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label(String(localized: "restaurant.delete"), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditRestaurantSheet(restaurant: restaurant)
        }
        .alert(String(localized: "restaurant.delete_title"), isPresented: $showDeleteAlert) {
            Button(String(localized: "common.cancel"), role: .cancel) { }
            Button(String(localized: "restaurant.delete"), role: .destructive) {
                deleteRestaurant()
            }
        } message: {
            Text(String(localized: "restaurant.delete_message"))
        }
        .alert(String(localized: "error.title"), isPresented: $showErrorAlert) {
            Button(String(localized: "common.ok"), role: .cancel) { }
        } message: {
            Text(errorAlertMessage)
        }
    }

    private var sortedScans: [MenuScan] {
        restaurant.scans.sorted { $0.date > $1.date }
    }

    private var restaurantHeader: some View {
        VStack(spacing: Theme.spacingM) {
            ZStack {
                Circle()
                    .fill(Theme.accentBackground)
                    .frame(width: 80, height: 80)

                Image(systemName: "building.2.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Theme.accent)
            }

            Text(restaurant.name)
                .font(.title2.bold())

            if let lastDate = restaurant.lastScanDate {
                Text(String(format: NSLocalizedString("restaurants.last_scan", comment: ""), lastDate.formatted(date: .abbreviated, time: .omitted)))
                    .font(.caption)
                    .foregroundStyle(Theme.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingL)
    }

    private func deleteScan(at offsets: IndexSet) {
        let scansToDelete = offsets.map { sortedScans[$0] }
        for scan in scansToDelete {
            modelContext.delete(scan)
        }
        do {
            try modelContext.save()
        } catch {
            errorAlertMessage = String(localized: "error.delete_scan")
            showErrorAlert = true
        }
    }

    private func deleteRestaurant() {
        modelContext.delete(restaurant)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorAlertMessage = String(localized: "error.delete_restaurant")
            showErrorAlert = true
        }
    }
}

struct StatItemView: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: Theme.spacingXS) {
            Image(systemName: icon)
                .foregroundStyle(Theme.accent)
                .font(.title3)

            Text(value)
                .font(.headline)

            Text(label)
                .font(.caption2)
                .foregroundStyle(Theme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct EditRestaurantSheet: View {
    @Bindable var restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var address: String = ""
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "restaurant.name_section")) {
                    TextField(String(localized: "restaurant.name_placeholder"), text: $name)
                }

                Section(String(localized: "restaurant.address_section")) {
                    TextField(String(localized: "restaurant.address_placeholder"), text: $address)
                }

                Section(String(localized: "restaurant.notes_section")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(String(localized: "restaurant.edit_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common.save")) {
                        saveChanges()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                name = restaurant.name
                address = restaurant.address
                notes = restaurant.notes
            }
        }
    }

    private func saveChanges() {
        restaurant.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        restaurant.address = address.trimmingCharacters(in: .whitespacesAndNewlines)
        restaurant.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailView(restaurant: Restaurant(name: "La Terraza"))
    }
    .modelContainer(for: [Restaurant.self, MenuScan.self], inMemory: true)
}
