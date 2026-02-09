import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \MenuScan.scanDate, order: .reverse)
    private var scans: [MenuScan]

    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteAll = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !scans.isEmpty {
                    HStack(spacing: 24) {
                        Spacer()
                        statCard(value: scans.count, label: String(localized: "history.stats_scans"), systemImage: "barcode.viewfinder", color: .blue)
                        statCard(value: scans.reduce(0) { $0 + $1.dishes.count }, label: String(localized: "history.stats_dishes"), systemImage: "fork.knife", color: .orange)
                        statCard(value: scans.reduce(0) { $0 + $1.totalCalories }, label: String(localized: "history.stats_calories"), systemImage: "flame.fill", color: .red)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                }
                Group {
                    if scans.isEmpty {
                        emptyState
                    } else {
                        scanList
                    }
                }
            }
            .background(Theme.background)
            .navigationTitle(Text(String(localized: "history.title")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !scans.isEmpty {
                        Button(role: .destructive) {
                            showDeleteAll = true
                        } label: {
                            Label(String(localized: "history.delete_all"), systemImage: "trash")
                        }
                    }
                }
            }
            .alert(String(localized: "history.delete_all"), isPresented: $showDeleteAll) {
                Button(String(localized: "common.cancel"), role: .cancel) {}
                Button(String(localized: "history.delete_all"), role: .destructive) {
                    deleteAllScans()
                }
            } message: {
                Text(String(localized: "history.delete_all_confirm"))
            }
        }
    }

    private func statCard(value: Int, label: String, systemImage: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title3.bold())
                .foregroundColor(color)
            Text("\(value)")
                .font(.title2.bold())
                .foregroundColor(Theme.textPrimary)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundColor(Theme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(width: 70, height: 60)
    }

    private var emptyState: some View {
        VStack(spacing: Theme.spacingL) {
            ZStack {
                Circle()
                    .fill(Theme.accentBackground)
                    .frame(width: 100, height: 100)
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 44))
                    .foregroundStyle(Theme.accent.opacity(0.6))
            }
            VStack(spacing: Theme.spacingS) {
                Text(String(localized: "history.empty_title"))
                    .font(.title3.bold())
                    .foregroundColor(Theme.textPrimary)
                Text(String(localized: "history.empty_subtitle"))
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 40)
    }

    private var scanList: some View {
        List {
            ForEach(scans) { scan in
                NavigationLink {
                    ResultsView(
                        dishes: scan.dishes,
                        restaurantName: scan.restaurantName
                    ) { }
                } label: {
                    HistoryScanRowView(scan: scan)
                }
            }
            .onDelete(perform: deleteScan)
        }
        .listStyle(.insetGrouped)
    }

    private func deleteScan(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(scans[index])
        }
        try? modelContext.save()
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func deleteAllScans() {
        for scan in scans {
            modelContext.delete(scan)
        }
        try? modelContext.save()
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: MenuScan.self, inMemory: true)
}
