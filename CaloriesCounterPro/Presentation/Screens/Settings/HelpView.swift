import MessageUI
import SwiftUI

struct HelpView: View {
    @State private var showMail = false
    @State private var result: Result<MFMailComposeResult, Error>? = nil

    var body: some View {
        List {
            Section(header: Text(String(localized: "help.faq"))) {
                Text(String(localized: "help.q1"))
                Text(String(localized: "help.q2"))
            }
            Section(header: Text(String(localized: "help.contact"))) {
                Button(String(localized: "help.contact_button")) {
                    showMail = true
                }
            }
        }
        .sheet(isPresented: $showMail) {
            MailView(result: $result)
        }
        .navigationTitle(String(localized: "help.title"))
    }
}

struct MailView: UIViewControllerRepresentable {
    @Binding var result: Result<MFMailComposeResult, Error>?

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(["arzoid29@gmail.com"])
        vc.setSubject("Soporte Calories Counter Pro")
        vc.setMessageBody("Hola, necesito ayuda con la app.", isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailView
        init(_ parent: MailView) { self.parent = parent }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.result = error == nil ? .success(result) : .failure(error!)
            controller.dismiss(animated: true)
        }
    }
}