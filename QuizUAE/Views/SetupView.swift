import SwiftUI

struct SetupView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        ZStack {
            Color.darkBase.ignoresSafeArea()

            VStack(spacing: 30) {
                Text("تراثنا")
                    .font(.custom("Tajawal-Bold", size: 60))
                    .foregroundColor(.primaryGold)
                    .padding(.top, 40)

                Text("لعبة المسابقات الإماراتية")
                    .font(.custom("Tajawal-Medium", size: 24))
                    .foregroundColor(.secondarySand)

                VStack(alignment: .leading, spacing: 10) {
                    Text("عدد اللاعبين")
                        .font(.custom("Tajawal-Medium", size: 18))
                        .foregroundColor(.secondarySand)

                    Stepper(value: $gameVM.numberOfPlayers, in: 2...10) {
                        Text("\(gameVM.numberOfPlayers)")
                            .font(.custom("Tajawal-Bold", size: 22))
                            .foregroundColor(.primaryGold)
                    }
                    .padding()
                    .background(Color.secondarySand.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(0..<gameVM.numberOfPlayers, id: \.self) { index in
                            TextField("اسم اللاعب \(index + 1)", text: $gameVM.playerNames[index])
                                .padding()
                                .background(Color.secondarySand)
                                .cornerRadius(10)
                                .foregroundColor(.darkBase)
                                .font(.custom("Tajawal-Regular", size: 18))
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .padding(.horizontal)
                }

                Button(action: {
                    gameVM.startGame()
                }) {
                    Text("ابدأ اللعبة")
                        .font(.custom("Tajawal-Bold", size: 24))
                        .foregroundColor(.darkBase)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.primaryGold)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .disabled(gameVM.playerNames.filter { !$0.isEmpty }.count < 2)
            }
        }
    }
}
