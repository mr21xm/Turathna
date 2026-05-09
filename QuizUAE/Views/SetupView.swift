import SwiftUI

struct SetupView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        ZStack {
            Color.creamBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Button(action: { gameVM.gameState = .home }) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.heritageGold)
                    }
                    Spacer()
                    Text("منو بيلعب؟")
                        .font(.custom(AppTheme.titleFont, size: 24))
                        .foregroundColor(.inkBlack)
                    Spacer()
                    Color.clear.frame(width: 30)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)

                VStack(alignment: .leading, spacing: 10) {
                    Text("كم عددكم؟")
                        .font(.custom(AppTheme.mediumFont, size: 16))
                        .foregroundColor(.inkBlack.opacity(0.6))

                    HStack {
                        Text("\(gameVM.numberOfPlayers)")
                            .font(.custom(AppTheme.titleFont, size: 22))
                            .foregroundColor(.heritageGold)
                        Spacer()
                        Stepper("", value: $gameVM.numberOfPlayers, in: 2...10)
                            .labelsHidden()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(AppTheme.buttonCornerRadius)
                }
                .padding(.horizontal, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(0..<gameVM.numberOfPlayers, id: \.self) { index in
                            HStack(spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.custom(AppTheme.titleFont, size: 14))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.heritageGold)
                                    .clipShape(Circle())

                                TextField("الاسم", text: $gameVM.playerNames[index])
                                    .font(.custom(AppTheme.bodyFont, size: 16))
                                    .multilineTextAlignment(.trailing)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(AppTheme.buttonCornerRadius)
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Button(action: {
                    gameVM.startGame()
                }) {
                    Text("يا الله نبدأ")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ModernButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .disabled(gameVM.playerNames.filter { !$0.isEmpty }.count < 2)
            }
        }
    }
}
