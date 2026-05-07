import SwiftUI

struct ResultsView: View {
    @ObservedObject var gameVM: GameViewModel

    var sortedPlayers: [Player] {
        gameVM.session?.players.sorted { $0.score > $1.score } ?? []
    }

    var body: some View {
        ZStack {
            Color.darkBase.ignoresSafeArea()

            // Simple Confetti Placeholder (Circles falling)
            ConfettiEffect()

            VStack(spacing: 30) {
                Text("نهاية اللعبة")
                    .font(.custom("Tajawal-Bold", size: 40))
                    .foregroundColor(.secondarySand)

                VStack(spacing: 10) {
                    Text("الفائز")
                        .font(.custom("Tajawal-Medium", size: 20))
                        .foregroundColor(.primaryGold)

                    Text(sortedPlayers.first?.name ?? "")
                        .font(.custom("Tajawal-Bold", size: 50))
                        .foregroundColor(.primaryGold)
                }
                .padding()
                .background(Color.primaryGold.opacity(0.1))
                .cornerRadius(20)

                VStack(spacing: 15) {
                    Text("الترتيب")
                        .font(.custom("Tajawal-Bold", size: 24))
                        .foregroundColor(.secondarySand)

                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(Array(sortedPlayers.enumerated()), id: \.offset) { index, player in
                                HStack {
                                    Text("\(index + 1)")
                                        .font(.custom("Tajawal-Bold", size: 20))
                                        .foregroundColor(.primaryGold)
                                        .frame(width: 30)

                                    Text(player.name)
                                        .font(.custom("Tajawal-Medium", size: 18))
                                        .foregroundColor(.secondarySand)

                                    Spacer()

                                    Text("\(player.score) نقطة")
                                        .font(.custom("Tajawal-Bold", size: 18))
                                        .foregroundColor(.primaryGold)
                                }
                                .padding()
                                .background(index == 0 ? Color.primaryGold.opacity(0.2) : Color.secondarySand.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 300)
                }

                VStack(spacing: 15) {
                    Button(action: {
                        gameVM.playAgain()
                    }) {
                        Text("العب مجدداً")
                            .font(.custom("Tajawal-Bold", size: 22))
                            .foregroundColor(.darkBase)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryGold)
                            .cornerRadius(15)
                    }

                    Button(action: {
                        gameVM.playAgain() // In this simple app, it goes back to setup
                    }) {
                        Text("الرئيسية")
                            .font(.custom("Tajawal-Bold", size: 20))
                            .foregroundColor(.primaryGold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.primaryGold, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

struct ConfettiEffect: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<50) { i in
                Circle()
                    .fill([Color.primaryGold, Color.accentGreen, Color.blue, Color.red, Color.yellow].randomElement()!)
                    .frame(width: CGFloat.random(in: 5...12), height: CGFloat.random(in: 5...12))
                    .position(
                        x: CGFloat.random(in: 0...400),
                        y: animate ? 800 : -100
                    )
                    .animation(
                        Animation.linear(duration: Double.random(in: 2...5))
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
