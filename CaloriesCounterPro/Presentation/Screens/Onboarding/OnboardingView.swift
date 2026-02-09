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
                Text("¡Bienvenido a Calories Counter Pro!")
                    .font(.title)
                    .bold()
                Text("Escanea menús de restaurantes y obtén estimaciones de calorías al instante.")
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
                Text("1 escaneo gratis al día")
                    .font(.title2)
                    .bold()
                Text("Suscríbete para escaneos ilimitados y más funciones premium.")
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
                Text("Tu privacidad es lo primero")
                    .font(.title2)
                    .bold()
                Text("Tus datos se guardan solo en tu dispositivo. No compartimos tu información.")
                    .multilineTextAlignment(.center)
                Button("¡Empezar!") {
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
