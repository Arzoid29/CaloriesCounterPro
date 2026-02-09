import SwiftUI
import SwiftData

struct AddRestaurantSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var address: String = ""
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: Theme.spacingM) {
                        ZStack {
                            Circle()
                                .fill(Theme.accentBackground)
                                .frame(width: 70, height: 70)

                            Image(systemName: "building.2.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(Theme.accent)
                        }

                        Text(String(localized: "restaurant.add_header"))
                            .font(.headline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingM)
                }
                .listRowBackground(Color.clear)

                Section(String(localized: "restaurant.name_section")) {
                    TextField(String(localized: "restaurant.name_placeholder"), text: $name)
                        .textContentType(.organizationName)
                }

                Section(String(localized: "restaurant.address_section")) {
                    TextField(String(localized: "restaurant.address_placeholder"), text: $address)
                        .textContentType(.fullStreetAddress)
                }

                Section(String(localized: "restaurant.notes_section")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                        .overlay(alignment: .topLeading) {
                            if notes.isEmpty {
                                Text(String(localized: "restaurant.notes_placeholder"))
                                    .foregroundStyle(Theme.textTertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                }
            }
            .navigationTitle(String(localized: "restaurant.add_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common.save")) {
                        saveRestaurant()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .interactiveDismissDisabled(!name.isEmpty || !address.isEmpty || !notes.isEmpty)
    }

    private func saveRestaurant() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let restaurant = Restaurant(
            name: trimmedName,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            address: address.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        modelContext.insert(restaurant)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddRestaurantSheet()
        .modelContainer(for: Restaurant.self, inMemory: true)
}
