import SwiftUI

struct ResultsView: View {
    @ObservedObject var gameVM: GameViewModel

    var sortedPlayers: [Player] {
        gameVM.session?.players.sorted { $0.score > $1.score } ?? []
    }

    var body: some View {
        ZStack {
            Color.sandLight.ignoresSafeArea()

            ConfettiEffect()

            VStack(spacing: 40) {
                VStack(spacing: 12) {
                    Text("انتهت اللعبة")
                        .font(.custom(AppTheme.titleFont, size: 40))
                        .foregroundColor(.charcoalModern)

                    Text("كفيتوا ووفيتوا")
                        .font(.custom(AppTheme.mediumFont, size: 20))
                        .foregroundColor(.charcoalModern.opacity(0.6))
                }
                .padding(.top, 40)

                VStack(spacing: 20) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.heritageGold)
                        .shadow(color: .heritageGold.opacity(0.3), radius: 10)

                    VStack(spacing: 8) {
                        Text("المركز الأول")
                            .font(.custom(AppTheme.mediumFont, size: 18))
                            .foregroundColor(.charcoalModern.opacity(0.5))

                        Text(sortedPlayers.first?.name ?? "")
                            .font(.custom(AppTheme.titleFont, size: 48))
                            .foregroundColor(.heritageGold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.white)
                .cornerRadius(AppTheme.cardCornerRadius)
                .shadow(color: .black.opacity(0.05), radius: 20)
                .padding(.horizontal)

                VStack(spacing: 16) {
                    Text("ترتيب اللاعبين")
                        .font(.custom(AppTheme.titleFont, size: 20))
                        .foregroundColor(.charcoalModern.opacity(0.8))

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(sortedPlayers.enumerated()), id: \.offset) { index, player in
                                HStack {
                                    Text("\(index + 1)")
                                        .font(.custom(AppTheme.titleFont, size: 18))
                                        .foregroundColor(.heritageGold)
                                        .frame(width: 40, height: 40)
                                        .background(Color.heritageGold.opacity(0.1))
                                        .clipShape(Circle())

                                    Text(player.name)
                                        .font(.custom(AppTheme.mediumFont, size: 18))
                                        .foregroundColor(.charcoalModern)

                                    Spacer()

                                    Text("\(player.score) نقطة")
                                        .font(.custom(AppTheme.titleFont, size: 16))
                                        .foregroundColor(.heritageGold)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                    }
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
                            .font(.custom(AppTheme.mediumFont, size: 18))
                            .foregroundColor(.heritageGold)
                            .padding()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }
}
