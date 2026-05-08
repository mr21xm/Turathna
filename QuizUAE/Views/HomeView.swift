import SwiftUI

struct HomeView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        ZStack {
            Color.creamBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Hero Branding
                VStack(spacing: 24) {
                    Text("تراثنا")
                        .font(.custom(AppTheme.titleFont, size: 100))
                        .foregroundColor(.heritageGold)
                        .shadow(color: .heritageGold.opacity(0.15), radius: 15, x: 0, y: 10)

                    Text("يا حيّ الله من جانا")
                        .font(.custom(AppTheme.mediumFont, size: 24))
                        .foregroundColor(.inkBlack.opacity(0.6))
                        .tracking(3)
                }

                Spacer()

                // Call to Action
                VStack(spacing: 32) {
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            gameVM.gameState = .setup
                        }
                    }) {
                        Text("ادخل اللعبة")
                            .frame(width: 280)
                    }
                    .buttonStyle(ModernButtonStyle())

                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(Color.heritageGold.opacity(0.3))
                            .frame(width: 40, height: 1)
                        Text("لعبة الربع والأهل")
                            .font(.custom(AppTheme.bodyFont, size: 16))
                            .foregroundColor(.inkBlack.opacity(0.4))
                        Rectangle()
                            .fill(Color.heritageGold.opacity(0.3))
                            .frame(width: 40, height: 1)
                    }
                }
                .padding(.bottom, 60)
            }
        }
    }
}
