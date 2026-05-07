import SwiftUI

struct QuestionView: View {
    @ObservedObject var gameVM: GameViewModel
    @State private var selectedAnswer: String?
    @State private var showResult: Bool = false
    @State private var isCorrect: Bool = false
    @State private var removedOptions: Set<String> = []

    var body: some View {
        VStack(spacing: 20) {
            // Points Value
            if let result = gameVM.wheelResult {
                Text("\(result.label) نقطة")
                    .font(.custom("Tajawal-Bold", size: 30))
                    .foregroundColor(.primaryGold)
                    .padding()
                    .background(Color.primaryGold.opacity(0.1))
                    .cornerRadius(15)
            }

            // Question Card
            VStack(spacing: 25) {
                Text(gameVM.currentQuestion?.category ?? "")
                    .font(.custom("Tajawal-Medium", size: 16))
                    .foregroundColor(.primaryGold)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background(Color.primaryGold.opacity(0.2))
                    .cornerRadius(10)

                Text(gameVM.currentQuestion?.text ?? "")
                    .font(.custom("Tajawal-Bold", size: 24))
                    .foregroundColor(.secondarySand)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if gameVM.currentQuestion?.type == .multipleChoice {
                    VStack(spacing: 12) {
                        let choices = gameVM.currentQuestion?.choices ?? []
                        ForEach(choices, id: \.self) { choice in
                            if !removedOptions.contains(choice) {
                                Button(action: {
                                    if !showResult {
                                        checkAnswer(choice)
                                    }
                                }) {
                                    Text(choice)
                                        .font(.custom("Tajawal-Medium", size: 18))
                                        .foregroundColor(buttonTextColor(for: choice))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(buttonBackgroundColor(for: choice))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.primaryGold.opacity(0.5), lineWidth: 1)
                                        )
                                }
                            } else {
                                // Invisible but takes space to keep layout consistent?
                                // Actually, better to just hide it as per "Remove 2 wrong answers"
                                Spacer().frame(height: 0)
                            }
                        }
                    }
                    .padding(.horizontal)
                } else {
                    // Open Question
                    VStack(spacing: 20) {
                        Text("قل الإجابة بصوت عالٍ")
                            .font(.custom("Tajawal-Medium", size: 18))
                            .foregroundColor(.secondarySand.opacity(0.7))

                        if showResult {
                            Text(gameVM.currentQuestion?.correctAnswer ?? "")
                                .font(.custom("Tajawal-Bold", size: 26))
                                .foregroundColor(.accentGreen)
                                .padding()
                                .background(Color.accentGreen.opacity(0.1))
                                .cornerRadius(10)
                        }

                        HStack(spacing: 20) {
                            Button(action: { checkAnswer(gameVM.currentQuestion?.correctAnswer ?? "") }) {
                                Text("صح")
                                    .font(.custom("Tajawal-Bold", size: 20))
                                    .foregroundColor(.darkBase)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentGreen)
                                    .cornerRadius(12)
                            }

                            Button(action: { checkAnswer("خطأ") }) {
                                Text("خطأ")
                                    .font(.custom("Tajawal-Bold", size: 20))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.errorRed)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical, 30)
            .background(Color.secondarySand.opacity(0.05))
            .cornerRadius(25)
            .padding(.horizontal)

            // Helps
            HStack(spacing: 20) {
                HelpButton(
                    title: "حذف خيارين",
                    icon: "2.circle",
                    isDisabled: gameVM.session?.currentPlayer.usedHelpRemoveTwo ?? true || gameVM.currentQuestion?.type != .multipleChoice || gameVM.session?.currentPlayer.hasUsedHelpThisTurn ?? true,
                    action: { useRemoveTwoHelp() }
                )

                HelpButton(
                    title: "عرض الخيارات",
                    icon: "list.bullet",
                    isDisabled: gameVM.session?.currentPlayer.usedHelpShowOptions ?? true || gameVM.currentQuestion?.type != .open || gameVM.session?.currentPlayer.hasUsedHelpThisTurn ?? true,
                    action: { gameVM.useHelp(.showOptions) }
                )
            }
            .padding(.top, 10)

            if showResult {
                Button(action: {
                    gameVM.submitAnswer(isCorrect)
                }) {
                    Text("التالي")
                        .font(.custom("Tajawal-Bold", size: 22))
                        .foregroundColor(.darkBase)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 50)
                        .background(Color.primaryGold)
                        .cornerRadius(15)
                }
                .padding(.top, 20)
                .transition(.scale)
            }
        }
    }

    private func useRemoveTwoHelp() {
        guard let current = gameVM.currentQuestion, let choices = current.choices else { return }
        let wrongChoices = choices.filter { $0 != current.correctAnswer }
        let toRemove = Array(wrongChoices.shuffled().prefix(2))
        removedOptions = Set(toRemove)
        gameVM.useHelp(.removeTwo)
    }

    private func checkAnswer(_ answer: String) {
        selectedAnswer = answer
        isCorrect = (answer == gameVM.currentQuestion?.correctAnswer)

        if isCorrect {
            AudioManager.shared.playSound(named: "correct")
            HapticManager.shared.triggerSuccess()
        } else {
            AudioManager.shared.playSound(named: "wrong")
            HapticManager.shared.triggerImpact()
        }

        withAnimation {
            showResult = true
        }
    }

    private func buttonBackgroundColor(for choice: String) -> Color {
        if showResult {
            if choice == gameVM.currentQuestion?.correctAnswer {
                return Color.accentGreen
            } else if choice == selectedAnswer {
                return Color.errorRed
            }
        }
        return Color.secondarySand.opacity(0.1)
    }

    private func buttonTextColor(for choice: String) -> Color {
        if showResult {
            if choice == gameVM.currentQuestion?.correctAnswer || choice == selectedAnswer {
                return .white
            }
        }
        return .secondarySand
    }
}

struct HelpButton: View {
    let title: String
    let icon: String
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.custom("Tajawal-Medium", size: 12))
            }
            .frame(width: 100, height: 70)
            .background(isDisabled ? Color.gray.opacity(0.3) : Color.primaryGold.opacity(0.2))
            .foregroundColor(isDisabled ? .gray : .primaryGold)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isDisabled ? Color.gray.opacity(0.5) : Color.primaryGold, lineWidth: 1)
            )
        }
        .disabled(isDisabled)
    }
}
