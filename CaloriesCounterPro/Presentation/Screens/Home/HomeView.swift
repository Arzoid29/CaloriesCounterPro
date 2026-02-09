import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            MenuScannerView()
                .tabItem {
                    Label(String(localized: "tab.scan"), systemImage: "camera.viewfinder")
                }
                .tag(0)

            RestaurantsView()
                .tabItem {
                    Label(String(localized: "tab.restaurants"), systemImage: "building.2")
                }
                .tag(1)

            HistoryView()
                .tabItem {
                    Label(String(localized: "tab.history"), systemImage: "clock.arrow.circlepath")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label(String(localized: "tab.settings"), systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(Theme.accent)
    }
}

#Preview {
    HomeView()
}
