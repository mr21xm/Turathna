import SwiftUI

struct GameView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        ZStack {
            Color.creamBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Professional Header
                PremiumScoreboardView(gameVM: gameVM)

                Spacer()

                // Content Area with consistent padding
                ZStack {
                    if gameVM.gameState == .playing {
                        PremiumTurnIntroView(gameVM: gameVM)
                    } else if gameVM.gameState == .spinning {
                        WheelView(gameVM: gameVM)
                    } else if gameVM.gameState == .question {
                        QuestionView(gameVM: gameVM)
                    }
                }
                .transition(.asymmetric(insertion: .opacity.combined(with: .scale(0.95)), removal: .opacity))

                Spacer()
            }
        }
    }
}

struct PremiumScoreboardView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("الجولة")
                        .font(.custom(AppTheme.mediumFont, size: 14))
                        .foregroundColor(.inkBlack.opacity(0.4))
                    Text("\(gameVM.session?.currentRound ?? 1) / 6")
                        .font(.custom(AppTheme.titleFont, size: 20))
                        .foregroundColor(.heritageGold)
                }

                Spacer()

                Text("تراثنا")
                    .font(.custom(AppTheme.titleFont, size: 28))
                    .foregroundColor(.heritageGold)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    if let session = gameVM.session {
                        ForEach(session.players.indices, id: \.self) { index in
                            let player = session.players[index]
                            let isCurrent = session.currentPlayerIndex == index

                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(isCurrent ? .white : Color.heritageGold.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Text(player.name.prefix(1))
                                        .font(.custom(AppTheme.titleFont, size: 16))
                                        .foregroundColor(isCurrent ? .heritageGold : .inkBlack)
                                }

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(player.name)
                                        .font(.custom(AppTheme.mediumFont, size: 16))
                                        .foregroundColor(isCurrent ? .white : .inkBlack)
                                    Text("\(player.score) نقطة")
                                        .font(.custom(AppTheme.titleFont, size: 14))
                                        .foregroundColor(isCurrent ? .white.opacity(0.9) : .heritageGold)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(isCurrent ? Color.heritageGold : Color.white)
                                    .shadow(color: isCurrent ? Color.heritageGold.opacity(0.3) : Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                            )
                            .scaleEffect(isCurrent ? 1.05 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isCurrent)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
            }
        }
        .background(Color.white.opacity(0.6))
        .shadow(color: .black.opacity(0.02), radius: 10, y: 5)
    }
}

struct PremiumTurnIntroView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        VStack(spacing: 48) {
            VStack(spacing: 16) {
                Text("الدور عند")
                    .font(.custom(AppTheme.mediumFont, size: 24))
                    .foregroundColor(.inkBlack.opacity(0.5))

                Text(gameVM.session?.currentPlayer.name ?? "")
                    .font(.custom(AppTheme.titleFont, size: 56))
                    .foregroundColor(.heritageGold)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
            .background(
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.06), radius: 30)
                    Circle()
                        .stroke(Color.heritageGold.opacity(0.1), lineWidth: 1)
                }
                .padding(.horizontal, 20)
            )

            Button(action: {
                withAnimation(.spring()) {
                    gameVM.spinWheel()
                }
            }) {
                Text("دِوّر العجلة")
                    .frame(width: 240)
            }
            .buttonStyle(ModernButtonStyle())
        }
        .padding(.horizontal, 24)
    }
}
