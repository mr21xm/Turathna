import SwiftUI

struct HomeView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        ZStack {
            Color.sandLight.ignoresSafeArea()

            // Modern Background Elements
            VStack {
                Circle()
                    .fill(Color.heritageGold.opacity(0.1))
                    .frame(width: 400, height: 400)
                    .offset(x: 200, y: -200)
                Spacer()
                Circle()
                    .fill(Color.heritageGold.opacity(0.05))
                    .frame(width: 300, height: 300)
                    .offset(x: -150, y: 150)
            }
            .ignoresSafeArea()

            VStack(spacing: 60) {
                Spacer()

                VStack(spacing: 16) {
                    Text("تراثنا")
                        .font(.custom(AppTheme.titleFont, size: 84))
                        .foregroundColor(.heritageGold)
                        .shadow(color: .heritageGold.opacity(0.2), radius: 10, x: 0, y: 10)

                    Text("يا مرحبّا بكم في مسابقاتنا")
                        .font(.custom(AppTheme.mediumFont, size: 20))
                        .foregroundColor(.charcoalModern.opacity(0.7))
                        .tracking(2)
                }

                Spacer()

                VStack(spacing: 20) {
                    Button(action: {
                        withAnimation(.spring()) {
                            gameVM.gameState = .setup
                        }
                    }) {
                        Text("ادخل اللعبة")
                            .frame(width: 240)
                    }
                    .buttonStyle(ModernButtonStyle())

                    Text("لعبة تجمع الأهل والربع")
                        .font(.custom(AppTheme.bodyFont, size: 14))
                        .foregroundColor(.charcoalModern.opacity(0.5))
                }

                Spacer().frame(height: 40)
            }
        }
    }
}
