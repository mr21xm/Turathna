import SwiftUI

struct SetupView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        ZStack {
            Color.creamBackground.ignoresSafeArea()

            VStack(spacing: 32) {
                // Header
                HStack {
                    Button(action: { gameVM.gameState = .home }) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.heritageGold)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 10)
                    }
                    Spacer()
                    Text("منو ويانا اليوم؟")
                        .font(.custom(AppTheme.titleFont, size: 32))
                        .foregroundColor(.inkBlack)
                    Spacer()
                    // Balance circle
                    Circle().fill(Color.clear).frame(width: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // Player Count Selector
                VStack(alignment: .leading, spacing: 16) {
                    Text("كم عددكم؟")
                        .font(.custom(AppTheme.mediumFont, size: 18))
                        .foregroundColor(.inkBlack.opacity(0.6))
                        .padding(.horizontal, 8)

                    HStack {
                        Text("\(gameVM.numberOfPlayers)")
                            .font(.custom(AppTheme.titleFont, size: 28))
                            .foregroundColor(.heritageGold)
                        Spacer()
                        Stepper("", value: $gameVM.numberOfPlayers, in: 2...10)
                            .labelsHidden()
                            .scaleEffect(1.1)
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(AppTheme.buttonCornerRadius)
                    .shadow(color: .black.opacity(0.03), radius: 15)
                }
                .padding(.horizontal, 24)

                // Player Names List
                VStack(alignment: .leading, spacing: 16) {
                    Text("أسماء اللاعبين")
                        .font(.custom(AppTheme.mediumFont, size: 18))
                        .foregroundColor(.inkBlack.opacity(0.6))
                        .padding(.horizontal, 8)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(0..<gameVM.numberOfPlayers, id: \.self) { index in
                                HStack(spacing: 16) {
                                    Text("\(index + 1)")
                                        .font(.custom(AppTheme.titleFont, size: 16))
                                        .foregroundColor(.white)
                                        .frame(width: 28, height: 28)
                                        .background(Color.heritageGold)
                                        .clipShape(Circle())

                                    TextField("اكتب الاسم هني", text: $gameVM.playerNames[index])
                                        .font(.custom(AppTheme.bodyFont, size: 18))
                                        .multilineTextAlignment(.trailing)
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(AppTheme.buttonCornerRadius)
                                .shadow(color: .black.opacity(0.02), radius: 10)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 24)

                Button(action: {
                    gameVM.startGame()
                }) {
                    Text("يا الله نبدأ")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ModernButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                .disabled(gameVM.playerNames.filter { !$0.isEmpty }.count < 2)
            }
        }
    }
}
