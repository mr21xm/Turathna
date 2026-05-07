import SwiftUI

struct GameView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        ZStack {
            Color.darkBase.ignoresSafeArea()

            VStack(spacing: 0) {
                ScoreboardView(gameVM: gameVM)

                Spacer()

                if gameVM.gameState == .playing {
                    TurnIntroView(gameVM: gameVM)
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

struct ScoreboardView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("الجولة \(gameVM.session?.currentRound ?? 1) / 6")
                    .font(.custom("Tajawal-Bold", size: 18))
                    .foregroundColor(.primaryGold)

                Spacer()

                Text("تراثنا")
                    .font(.custom("Tajawal-Bold", size: 24))
                    .foregroundColor(.primaryGold)
            }
            .padding(.horizontal)
            .padding(.top, 10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    if let session = gameVM.session {
                        ForEach(session.players.indices, id: \.self) { index in
                            let player = session.players[index]
                            let isCurrent = session.currentPlayerIndex == index

                            VStack {
                                Text(player.name)
                                    .font(.custom("Tajawal-Medium", size: 16))
                                Text("\(player.score)")
                                    .font(.custom("Tajawal-Bold", size: 18))
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 15)
                            .background(isCurrent ? Color.primaryGold : Color.secondarySand.opacity(0.2))
                            .foregroundColor(isCurrent ? Color.darkBase : Color.secondarySand)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isCurrent ? Color.secondarySand : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 10)
        .background(Color.darkBase.opacity(0.8))
        .shadow(color: .black.opacity(0.3), radius: 5, y: 5)
    }
}

struct TurnIntroView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        VStack(spacing: 40) {
            Text("دور اللاعب:")
                .font(.custom("Tajawal-Medium", size: 28))
                .foregroundColor(.secondarySand)

            Text(gameVM.session?.currentPlayer.name ?? "")
                .font(.custom("Tajawal-Bold", size: 50))
                .foregroundColor(.primaryGold)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                withAnimation {
                    gameVM.spinWheel()
                }
            }) {
                Text("أدر العجلة")
                    .font(.custom("Tajawal-Bold", size: 30))
                    .foregroundColor(.darkBase)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 60)
                    .background(Color.primaryGold)
                    .cornerRadius(20)
                    .shadow(radius: 10)
            }
        }
    }
}
