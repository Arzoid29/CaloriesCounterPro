import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var page = 0

    var body: some View {
        TabView(selection: $page) {
            VStack(spacing: 24) {
                Image(systemName: "camera.viewfinder")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .foregroundColor(.accentColor)
                Text(String(localized: "onboarding.welcome_title"))
                    .font(.title)
                    .bold()
                Text(String(localized: "onboarding.welcome_subtitle"))
                    .multilineTextAlignment(.center)
            }
            .padding()
            .tag(0)

            VStack(spacing: 24) {
                Image(systemName: "star.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .foregroundColor(.yellow)
                Text(String(localized: "onboarding.free_scan_title"))
                    .font(.title2)
                    .bold()
                Text(String(localized: "onboarding.free_scan_subtitle"))
                    .multilineTextAlignment(.center)
            }
            .padding()
            .tag(1)

            VStack(spacing: 24) {
                Image(systemName: "lock.shield")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .foregroundColor(.blue)
                Text(String(localized: "onboarding.privacy_title"))
                    .font(.title2)
                    .bold()
                Text(String(localized: "onboarding.privacy_subtitle"))
                    .multilineTextAlignment(.center)
                Button(String(localized: "onboarding.get_started")) {
                    hasSeenOnboarding = true
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 16)
            }
            .padding()
            .tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}
