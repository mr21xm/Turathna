import SwiftUI

extension Color {
    // Premium Heritage Palette
    static let heritageGold = Color(hex: "#C5A059")
    static let heritageGoldDark = Color(hex: "#9E7E40")
    static let creamBackground = Color(hex: "#FCF9F2")
    static let paperWhite = Color(hex: "#FFFFFF")
    static let inkBlack = Color(hex: "#1C1C1E")
    static let successGreen = Color(hex: "#248A3D")
    static let dangerRed = Color(hex: "#B22222")

    // Compatibility aliases
    static let sandLight = creamBackground
    static let charcoalModern = inkBlack
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

    // Adjusted for better scaling
    static let cardCornerRadius: CGFloat = 24
    static let buttonCornerRadius: CGFloat = 16
    static let shadowRadius: CGFloat = 8
}

struct ModernButtonStyle: ButtonStyle {
    var backgroundColor: Color = .heritageGold
    var foregroundColor: Color = .white
    var height: CGFloat = 54 // Standard height

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom(AppTheme.mediumFont, size: 18))
            .frame(height: height)
            .padding(.horizontal, 30)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                    .fill(backgroundColor)
            )
            .foregroundColor(foregroundColor)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.interactiveSpring(), value: configuration.isPressed)
            .shadow(color: backgroundColor.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}

struct ConfettiEffect: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<40) { i in
                Rectangle()
                    .fill([Color.heritageGold, Color.successGreen, Color.blue, Color.red, Color.yellow].randomElement()!)
                    .frame(width: CGFloat.random(in: 4...8), height: CGFloat.random(in: 4...8))
                    .position(
                        x: CGFloat.random(in: 0...400),
                        y: animate ? 800 : -100
                    )
                    .animation(
                        Animation.linear(duration: Double.random(in: 2...4))
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
