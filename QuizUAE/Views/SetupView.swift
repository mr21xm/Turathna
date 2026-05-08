import SwiftUI

struct SetupView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        ZStack {
            Color.sandLight.ignoresSafeArea()

            VStack(spacing: 30) {
                HStack {
                    Button(action: { gameVM.gameState = .home }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.heritageGold)
                    }
                    Spacer()
                    Text("منو بيلعب؟")
                        .font(.custom(AppTheme.titleFont, size: 28))
                        .foregroundColor(.charcoalModern)
                    Spacer()
                    // Placeholder for balance
                    Circle().fill(Color.clear).frame(width: 40)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("كم عددكم؟")
                        .font(.custom(AppTheme.mediumFont, size: 18))
                        .foregroundColor(.charcoalModern.opacity(0.8))

                    HStack {
                        Text("\(gameVM.numberOfPlayers)")
                            .font(.custom(AppTheme.titleFont, size: 24))
                            .foregroundColor(.heritageGold)
                        Spacer()
                        Stepper("", value: $gameVM.numberOfPlayers, in: 2...10)
                            .labelsHidden()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(AppTheme.buttonCornerRadius)
                    .shadow(color: .black.opacity(0.05), radius: 10)
                }
                .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(0..<gameVM.numberOfPlayers, id: \.self) { index in
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.heritageGold.opacity(0.5))
                                TextField("اسم اللاعب \(index + 1)", text: $gameVM.playerNames[index])
                                    .font(.custom(AppTheme.bodyFont, size: 18))
                                    .multilineTextAlignment(.trailing)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(AppTheme.buttonCornerRadius)
                            .shadow(color: .black.opacity(0.03), radius: 5)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }

                Button(action: {
                    gameVM.startGame()
                }) {
                    Text("يا الله نبدأ")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ModernButtonStyle())
                .padding(.horizontal)
                .padding(.bottom, 30)
                .disabled(gameVM.playerNames.filter { !$0.isEmpty }.count < 2)
            }
        }
    }
}
