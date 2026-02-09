import SwiftUI

struct LegalView: View {
    let title: String
    let fileName: String
    @State private var text: String = ""

    var body: some View {
        ScrollView {
            Text(text)
                .padding()
        }
        .navigationTitle(title)
        .onAppear {
            let locale = Locale.current.languageCode ?? "es"
            let localizedFile = locale == "en" ? fileName + "_en" : fileName
            if let path = Bundle.main.path(forResource: localizedFile, ofType: "txt"),
               let content = try? String(contentsOfFile: path) {
                text = content
            } else {
                text = "No se pudo cargar el texto legal."
            }
        }
    }
}

struct PrivacyView: View {
    var body: some View {
        LegalView(title: "Política de Privacidad", fileName: "Privacy")
    }
}

struct TermsView: View {
    var body: some View {
        LegalView(title: "Términos de Servicio", fileName: "Terms")
    }
}
