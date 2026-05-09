import SwiftUI

struct ResultsView: View {
    @ObservedObject var gameVM: GameViewModel

    var sortedPlayers: [Player] {
        gameVM.session?.players.sorted { $0.score > $1.score } ?? []
    }

    var body: some View {
        ZStack {
            Color.creamBackground.ignoresSafeArea()

            ConfettiEffect()

            VStack(spacing: 30) {
                VStack(spacing: 8) {
                    Text("انتهت اللعبة")
                        .font(.custom(AppTheme.titleFont, size: 32))
                        .foregroundColor(.charcoalModern)

                    Text("كفيتوا ووفيتوا")
                        .font(.custom(AppTheme.mediumFont, size: 16))
                        .foregroundColor(.charcoalModern.opacity(0.5))
                }
                .padding(.top, 30)

                VStack(spacing: 12) {
                    Text(sortedPlayers.first?.name ?? "")
                        .font(.custom(AppTheme.titleFont, size: 40))
                        .foregroundColor(.heritageGold)

                    Text("الفائز")
                        .font(.custom(AppTheme.mediumFont, size: 14))
                        .foregroundColor(.charcoalModern.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(Color.white)
                .cornerRadius(AppTheme.cardCornerRadius)
                .padding(.horizontal, 40)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(Array(sortedPlayers.enumerated()), id: \.offset) { index, player in
                            HStack {
                                Text("\(index + 1)")
                                    .font(.custom(AppTheme.titleFont, size: 14))
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(index == 0 ? Color.heritageGold : Color.heritageGold.opacity(0.3))
                                    .clipShape(Circle())

                                Text(player.name)
                                    .font(.custom(AppTheme.mediumFont, size: 16))
                                    .foregroundColor(.inkBlack)

                                Spacer()

                                Text("\(player.score) نقطة")
                                    .font(.custom(AppTheme.titleFont, size: 14))
                                    .foregroundColor(.heritageGold)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 24)
                }

                VStack(spacing: 12) {
                    Button(action: {
                        gameVM.playAgain()
                    }) {
                        Text("نلعب مرة ثانية؟")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ModernButtonStyle())

                    Button(action: {
                        gameVM.gameState = .home
                    }) {
                        Text("الرئيسية")
                            .font(.custom(AppTheme.mediumFont, size: 16))
                            .foregroundColor(.heritageGold)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
    }
}
