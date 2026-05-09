import SwiftUI

struct GameView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        ZStack {
            Color.creamBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                CompactScoreboardView(gameVM: gameVM)

                Spacer()

                Group {
                    if gameVM.gameState == .playing {
                        CompactTurnIntroView(gameVM: gameVM)
                    } else if gameVM.gameState == .spinning {
                        WheelView(gameVM: gameVM)
                    } else if gameVM.gameState == .question {
                        QuestionView(gameVM: gameVM)
                    }
                }
                .transition(.asymmetric(insertion: .opacity.combined(with: .scale(0.98)), removal: .opacity))

                Spacer()
            }
        }
    }
}

struct CompactScoreboardView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("الجولة \(gameVM.session?.currentRound ?? 1) / 6")
                    .font(.custom(AppTheme.titleFont, size: 16))
                    .foregroundColor(.heritageGold)

                Spacer()

                Text("تراثنا")
                    .font(.custom(AppTheme.titleFont, size: 20))
                    .foregroundColor(.heritageGold)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    if let session = gameVM.session {
                        ForEach(session.players.indices, id: \.self) { index in
                            let player = session.players[index]
                            let isCurrent = session.currentPlayerIndex == index

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(player.name)
                                    .font(.custom(AppTheme.mediumFont, size: 13))
                                    .foregroundColor(isCurrent ? .white : .inkBlack)
                                    .lineLimit(1)
                                Text("\(player.score)")
                                    .font(.custom(AppTheme.titleFont, size: 12))
                                    .foregroundColor(isCurrent ? .white.opacity(0.8) : .heritageGold)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(isCurrent ? Color.heritageGold : Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.02), radius: 5)
                            .scaleEffect(isCurrent ? 1.02 : 1.0)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
            }
        }
        .background(Color.white.opacity(0.4))
    }
}

struct CompactTurnIntroView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("الدور عند")
                    .font(.custom(AppTheme.mediumFont, size: 18))
                    .foregroundColor(.inkBlack.opacity(0.4))

                Text(gameVM.session?.currentPlayer.name ?? "")
                    .font(.custom(AppTheme.titleFont, size: 36))
                    .foregroundColor(.heritageGold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.vertical, 40)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(AppTheme.cardCornerRadius)
            .padding(.horizontal, 30)

            Button(action: {
                withAnimation {
                    gameVM.spinWheel()
                }
            }) {
                Text("دِوّر العجلة")
                    .frame(width: 180)
            }
            .buttonStyle(ModernButtonStyle())
        }
    }
}
