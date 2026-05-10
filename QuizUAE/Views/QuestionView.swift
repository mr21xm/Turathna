import SwiftUI

struct QuestionView: View {
    @ObservedObject var gameVM: GameViewModel
    @State private var selectedAnswer: String?
    @State private var showResult: Bool = false
    @State private var isCorrect: Bool = false
    @State private var removedOptions: Set<String> = []

    var body: some View {
        VStack(spacing: 20) {
            // Points indicator
            if let result = gameVM.wheelResult {
                Text("\(result.label) نقطة")
                    .font(.custom(AppTheme.titleFont, size: 22))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 24)
                    .background(result.color)
                    .cornerRadius(20)
            }

            // Question Card
            VStack(spacing: 20) {
                HStack {
                    Text(gameVM.currentQuestion?.category ?? "")
                        .font(.custom(AppTheme.mediumFont, size: 12))
                        .foregroundColor(.heritageGold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.heritageGold.opacity(0.1))
                        .cornerRadius(8)
                    Spacer()
                    DifficultyBadge(difficulty: gameVM.currentQuestion?.difficulty ?? .medium)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Text(gameVM.currentQuestion?.text ?? "")
                    .font(.custom(AppTheme.titleFont, size: 22))
                    .foregroundColor(.inkBlack)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                if gameVM.currentQuestion?.type == .multipleChoice {
                    VStack(spacing: 10) {
                        let choices = gameVM.currentQuestion?.choices ?? []
                        ForEach(choices, id: \.self) { choice in
                            if !removedOptions.contains(choice) {
                                Button(action: {
                                    if !showResult {
                                        checkAnswer(choice)
                                    }
                                }) {
                                    HStack {
                                        Text(choice)
                                            .font(.custom(AppTheme.mediumFont, size: 16))
                                            .lineLimit(1)
                                        Spacer()
                                        if showResult {
                                            Image(systemName: choice == gameVM.currentQuestion?.correctAnswer ? "checkmark.circle.fill" : (choice == selectedAnswer ? "xmark.circle.fill" : "circle"))
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(buttonBackgroundColor(for: choice))
                                    .foregroundColor(buttonTextColor(for: choice))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                } else {
                    // Open Question
                    VStack(spacing: 20) {
                        Text("شو الإجابة؟")
                            .font(.custom(AppTheme.mediumFont, size: 16))
                            .foregroundColor(.inkBlack.opacity(0.4))

                        if showResult {
                            Text(gameVM.currentQuestion?.correctAnswer ?? "")
                                .font(.custom(AppTheme.titleFont, size: 24))
                                .foregroundColor(.successGreen)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        HStack(spacing: 12) {
                            Button(action: { checkAnswer(gameVM.currentQuestion?.correctAnswer ?? "") }) {
                                Text("صح")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(ModernButtonStyle(backgroundColor: .successGreen, height: 44))

                            Button(action: { checkAnswer("خطأ") }) {
                                Text("خطأ")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(ModernButtonStyle(backgroundColor: .dangerRed, height: 44))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(AppTheme.cardCornerRadius)
            .shadow(color: .black.opacity(0.04), radius: 10)
            .padding(.horizontal, 24)

            // Helps
            HStack(spacing: 16) {
                CompactHelpButton(
                    title: "حذف خيارين",
                    icon: "2.circle.fill",
                    isDisabled: gameVM.session?.currentPlayer.usedHelpRemoveTwo ?? true || gameVM.currentQuestion?.type != .multipleChoice || gameVM.session?.currentPlayer.hasUsedHelpThisTurn ?? true,
                    action: { useRemoveTwoHelp() }
                )

                CompactHelpButton(
                    title: "عرض الخيارات",
                    icon: "list.bullet.circle.fill",
                    isDisabled: gameVM.session?.currentPlayer.usedHelpShowOptions ?? true || gameVM.currentQuestion?.type != .open || gameVM.session?.currentPlayer.hasUsedHelpThisTurn ?? true,
                    action: { gameVM.useHelp(.showOptions) }
                )
            }

            if showResult {
                Button(action: {
                    gameVM.submitAnswer(isCorrect)
                }) {
                    Text("اللي بعده")
                        .frame(width: 160)
                }
                .buttonStyle(ModernButtonStyle())
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
                return Color.successGreen
            } else if choice == selectedAnswer {
                return Color.dangerRed
            }
        }
        return Color.creamBackground.opacity(0.6)
    }

    private func buttonTextColor(for choice: String) -> Color {
        if showResult {
            if choice == gameVM.currentQuestion?.correctAnswer || choice == selectedAnswer {
                return .white
            }
        }
        return .inkBlack
    }
}

struct DifficultyBadge: View {
    let difficulty: Difficulty

    var body: some View {
        Text(label)
            .font(.custom(AppTheme.mediumFont, size: 10))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color)
            .clipShape(Capsule())
    }

    var label: String {
        switch difficulty {
        case .easy: return "سهل"
        case .medium: return "متوسط"
        case .hard: return "صعب"
        }
    }

    var color: Color {
        switch difficulty {
        case .easy: return .successGreen
        case .medium: return .heritageGold
        case .hard: return .dangerRed
        }
    }
}

struct CompactHelpButton: View {
    let title: String
    let icon: String
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.custom(AppTheme.mediumFont, size: 11))
            }
            .frame(width: 90, height: 60)
            .background(isDisabled ? Color.inkBlack.opacity(0.05) : Color.white)
            .foregroundColor(isDisabled ? .inkBlack.opacity(0.2) : .heritageGold)
            .cornerRadius(12)
            .shadow(color: .black.opacity(isDisabled ? 0 : 0.02), radius: 5)
        }
        .disabled(isDisabled)
    }
}
