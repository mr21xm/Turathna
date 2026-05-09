import SwiftUI

struct HomeView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        ZStack {
            Color.creamBackground.ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                VStack(spacing: 12) {
                    Text("تراثنا")
                        .font(.custom(AppTheme.titleFont, size: 80))
                        .foregroundColor(.heritageGold)

                    Text("يا حيّ الله من جانا")
                        .font(.custom(AppTheme.mediumFont, size: 18))
                        .foregroundColor(.inkBlack.opacity(0.5))
                }

                Spacer()

                Button(action: {
                    withAnimation {
                        gameVM.gameState = .setup
                    }
                }) {
                    Text("ادخل اللعبة")
                        .frame(width: 220)
                }
                .buttonStyle(ModernButtonStyle())
                .padding(.bottom, 50)
            }
        }
    }
}
