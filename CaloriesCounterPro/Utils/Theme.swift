import SwiftUI

enum Theme {

    // MARK: - Accent Colors

    static let accent = Color.orange
    static let accentSecondary = Color(red: 1.0, green: 0.6, blue: 0.0)

    static let accentGradient = LinearGradient(
        colors: [Color.orange, Color(red: 1.0, green: 0.6, blue: 0.0)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let accentGradientVertical = LinearGradient(
        colors: [Color.orange, Color(red: 1.0, green: 0.6, blue: 0.0)],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Backgrounds

    static let background = Color(.systemBackground)

    static let cardBackground = Color(.secondarySystemBackground)

    static let tertiaryBackground = Color(.tertiarySystemBackground)

    static let accentBackground = Color.orange.opacity(0.12)

    // MARK: - Text

    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)

    // MARK: - Borders & Separators

    static let separator = Color(.separator)
    static let border = Color(.systemGray4)

    // MARK: - Shadows

    static let cardShadowColor = Color(.sRGBLinear, white: 0, opacity: 0.08)
    static let cardShadowRadius: CGFloat = 8
    static let cardShadowY: CGFloat = 4

    // MARK: - Spacing

    static let cornerRadius: CGFloat = 16
    static let cornerRadiusSmall: CGFloat = 12
    static let cornerRadiusTiny: CGFloat = 8

    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 24
    static let spacingXXL: CGFloat = 32
}

// MARK: - View Modifiers

struct PremiumCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .shadow(color: Theme.cardShadowColor, radius: Theme.cardShadowRadius, y: Theme.cardShadowY)
    }
}

struct GradientButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.accentGradient)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
    }
}

struct OutlineButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Theme.accent)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.accentBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall)
                    .stroke(Theme.accent.opacity(0.3), lineWidth: 1)
            )
    }
}

extension View {
    func premiumCard() -> some View {
        modifier(PremiumCardModifier())
    }

    func gradientButton() -> some View {
        modifier(GradientButtonModifier())
    }

    func outlineButton() -> some View {
        modifier(OutlineButtonModifier())
    }
}
