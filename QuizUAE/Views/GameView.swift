import SwiftUI

struct GameView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        ZStack {
            Color.sandLight.ignoresSafeArea()

            VStack(spacing: 0) {
                ModernScoreboardView(gameVM: gameVM)

                Spacer()

                if gameVM.gameState == .playing {
                    ModernTurnIntroView(gameVM: gameVM)
                } else if gameVM.gameState == .spinning {
                    WheelView(gameVM: gameVM)
                } else if gameVM.gameState == .question {
                    QuestionView(gameVM: gameVM)
                }

                Spacer()
            }
        }
    }
}

struct ModernScoreboardView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("الجولة")
                        .font(.custom(AppTheme.bodyFont, size: 12))
                        .foregroundColor(.charcoalModern.opacity(0.5))
                    Text("\(gameVM.session?.currentRound ?? 1) / 6")
                        .font(.custom(AppTheme.titleFont, size: 18))
                        .foregroundColor(.heritageGold)
                }

                Spacer()

                Text("تراثنا")
                    .font(.custom(AppTheme.titleFont, size: 24))
                    .foregroundColor(.heritageGold)
            }
            .padding(.horizontal)
            .padding(.top, 10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if let session = gameVM.session {
                        ForEach(session.players.indices, id: \.self) { index in
                            let player = session.players[index]
                            let isCurrent = session.currentPlayerIndex == index

                            HStack(spacing: 10) {
                                Circle()
                                    .fill(isCurrent ? .white : Color.heritageGold.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Text(player.name.prefix(1))
                                            .font(.custom(AppTheme.titleFont, size: 14))
                                            .foregroundColor(isCurrent ? .heritageGold : .charcoalModern)
                                    )

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(player.name)
                                        .font(.custom(AppTheme.mediumFont, size: 14))
                                        .foregroundColor(isCurrent ? .white : .charcoalModern)
                                    Text("\(player.score) نقطة")
                                        .font(.custom(AppTheme.titleFont, size: 12))
                                        .foregroundColor(isCurrent ? .white.opacity(0.9) : .heritageGold)
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(isCurrent ? Color.heritageGold : Color.white)
                            .cornerRadius(20)
                            .shadow(color: isCurrent ? Color.heritageGold.opacity(0.3) : Color.black.opacity(0.05), radius: 5)
                            .scaleEffect(isCurrent ? 1.05 : 1.0)
                            .animation(.spring(), value: isCurrent)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 5)
            }
        }
        .padding(.bottom, 10)
        .background(Color.white.opacity(0.5))
    }
}

struct ModernTurnIntroView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("الحين دور")
                    .font(.custom(AppTheme.mediumFont, size: 20))
                    .foregroundColor(.charcoalModern.opacity(0.6))

                Text(gameVM.session?.currentPlayer.name ?? "")
                    .font(.custom(AppTheme.titleFont, size: 48))
                    .foregroundColor(.heritageGold)
                    .multilineTextAlignment(.center)
            }
            .padding(40)
            .background(
                ZStack {
                    Circle().fill(Color.white).shadow(color: .black.opacity(0.05), radius: 20)
                    Circle().stroke(Color.heritageGold.opacity(0.1), lineWidth: 2)
                }
            )

            Button(action: {
                withAnimation(.spring()) {
                    gameVM.spinWheel()
                }
            }) {
                Text("دِوّر العجلة")
                    .frame(width: 200)
            }
            .buttonStyle(ModernButtonStyle())
        }
    }
}
