import SwiftUI

extension Color {
    // Modern Lighter Palette
    static let heritageGold = Color(hex: "#D4AF37")
    static let sandLight = Color(hex: "#F9F6F0")
    static let sandMedium = Color(hex: "#F0EAD6")
    static let charcoalModern = Color(hex: "#2C2C2E")
    static let successGreen = Color(hex: "#34C759")
    static let dangerRed = Color(hex: "#FF3B30")
    static let glassBackground = Color.white.opacity(0.8)

    // Compatibility aliases for ViewModel
    static let primaryGold = heritageGold
    static let errorRed = dangerRed

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct AppTheme {
    static let titleFont = "Tajawal-Bold"
    static let bodyFont = "Tajawal-Regular"
    static let mediumFont = "Tajawal-Medium"

    static let cardCornerRadius: CGFloat = 24
    static let buttonCornerRadius: CGFloat = 16
    static let shadowRadius: CGFloat = 12
}

struct ModernButtonStyle: ButtonStyle {
    var backgroundColor: Color = .heritageGold
    var foregroundColor: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom(AppTheme.mediumFont, size: 18))
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(AppTheme.buttonCornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
            .shadow(color: backgroundColor.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct ConfettiEffect: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<50) { i in
                Circle()
                    .fill([Color.heritageGold, Color.successGreen, Color.blue, Color.red, Color.yellow].randomElement()!)
                    .frame(width: CGFloat.random(in: 5...12), height: CGFloat.random(in: 5...12))
                    .position(
                        x: CGFloat.random(in: 0...400),
                        y: animate ? 800 : -100
                    )
                    .animation(
                        Animation.linear(duration: Double.random(in: 2...5))
                            .repeatForever(autoreverses: false)
                            .delay(Double.random(in: 0...2)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}
