import SwiftUI

struct QuestionView: View {
    @ObservedObject var gameVM: GameViewModel
    @State private var selectedAnswer: String?
    @State private var showResult: Bool = false
    @State private var isCorrect: Bool = false
    @State private var removedOptions: Set<String> = []

    var body: some View {
        VStack(spacing: 24) {
            // Points Value Badge
            if let result = gameVM.wheelResult {
                HStack(spacing: 8) {
                    Image(systemName: result.type == .jackpot ? "star.fill" : "circle.fill")
                    Text("\(result.label) نقطة")
                }
                .font(.custom(AppTheme.titleFont, size: 24))
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 24)
                .background(result.color)
                .cornerRadius(30)
                .shadow(color: result.color.opacity(0.3), radius: 10)
            }

            // Question Card
            VStack(spacing: 30) {
                HStack {
                    Text(gameVM.currentQuestion?.category ?? "")
                        .font(.custom(AppTheme.mediumFont, size: 14))
                        .foregroundColor(.heritageGold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.heritageGold.opacity(0.1))
                        .cornerRadius(8)
                    Spacer()
                    DifficultyBadge(difficulty: gameVM.currentQuestion?.difficulty ?? .medium)
                }
                .padding(.horizontal)

                Text(gameVM.currentQuestion?.text ?? "")
                    .font(.custom(AppTheme.titleFont, size: 26))
                    .foregroundColor(.charcoalModern)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
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
                                    HStack {
                                        Text(choice)
                                            .font(.custom(AppTheme.mediumFont, size: 18))
                                        Spacer()
                                        if showResult {
                                            Image(systemName: choice == gameVM.currentQuestion?.correctAnswer ? "checkmark.circle.fill" : (choice == selectedAnswer ? "xmark.circle.fill" : "circle"))
                                        }
                                    }
                                    .padding()
                                    .background(buttonBackgroundColor(for: choice))
                                    .foregroundColor(buttonTextColor(for: choice))
                                    .cornerRadius(AppTheme.buttonCornerRadius)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                            .stroke(choice == selectedAnswer ? Color.clear : Color.black.opacity(0.05), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                } else {
                    // Open Question
                    VStack(spacing: 24) {
                        Text("شو الإجابة؟ قولها بصوت عالي")
                            .font(.custom(AppTheme.mediumFont, size: 18))
                            .foregroundColor(.charcoalModern.opacity(0.6))

                        if showResult {
                            Text(gameVM.currentQuestion?.correctAnswer ?? "")
                                .font(.custom(AppTheme.titleFont, size: 32))
                                .foregroundColor(.successGreen)
                                .padding()
                                .background(Color.successGreen.opacity(0.1))
                                .cornerRadius(16)
                                .transition(.scale.combined(with: .opacity))
                        }

                        HStack(spacing: 16) {
                            Button(action: { checkAnswer(gameVM.currentQuestion?.correctAnswer ?? "") }) {
                                Text("صح")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(ModernButtonStyle(backgroundColor: .successGreen))

                            Button(action: { checkAnswer("خطأ") }) {
                                Text("خطأ")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(ModernButtonStyle(backgroundColor: .dangerRed))
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical, 30)
            .background(Color.white)
            .cornerRadius(AppTheme.cardCornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 20)
            .padding(.horizontal)

            // Helps
            HStack(spacing: 20) {
                ModernHelpButton(
                    title: "حذف خيارين",
                    icon: "2.circle.fill",
                    isDisabled: gameVM.session?.currentPlayer.usedHelpRemoveTwo ?? true || gameVM.currentQuestion?.type != .multipleChoice || gameVM.session?.currentPlayer.hasUsedHelpThisTurn ?? true,
                    action: { useRemoveTwoHelp() }
                )

                ModernHelpButton(
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
                        .frame(width: 200)
                }
                .buttonStyle(ModernButtonStyle())
                .transition(.move(edge: .bottom).combined(with: .opacity))
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

        withAnimation(.spring()) {
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
        return Color.sandLight.opacity(0.5)
    }

    private func buttonTextColor(for choice: String) -> Color {
        if showResult {
            if choice == gameVM.currentQuestion?.correctAnswer || choice == selectedAnswer {
                return .white
            }
        }
        return .charcoalModern
    }
}

struct DifficultyBadge: View {
    let difficulty: Difficulty

    var body: some View {
        Text(label)
            .font(.custom(AppTheme.mediumFont, size: 12))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color)
            .cornerRadius(4)
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

struct ModernHelpButton: View {
    let title: String
    let icon: String
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.custom(AppTheme.mediumFont, size: 12))
            }
            .frame(width: 110, height: 74)
            .background(isDisabled ? Color.charcoalModern.opacity(0.05) : Color.white)
            .foregroundColor(isDisabled ? .charcoalModern.opacity(0.2) : .heritageGold)
            .cornerRadius(20)
            .shadow(color: .black.opacity(isDisabled ? 0 : 0.05), radius: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isDisabled ? Color.clear : Color.heritageGold.opacity(0.2), lineWidth: 1)
            )
        }
        .disabled(isDisabled)
    }
}
