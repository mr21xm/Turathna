import SwiftUI

struct QuestionView: View {
    @ObservedObject var gameVM: GameViewModel
    @State private var selectedAnswer: String?
    @State private var showResult: Bool = false
    @State private var isCorrect: Bool = false
    @State private var removedOptions: Set<String> = []

    var body: some View {
        VStack(spacing: 32) {
            // Points indicator
            if let result = gameVM.wheelResult {
                HStack(spacing: 12) {
                    Circle()
                        .fill(result.color)
                        .frame(width: 12, height: 12)
                    Text("\(result.label) نقطة")
                        .font(.custom(AppTheme.titleFont, size: 28))
                        .foregroundColor(.inkBlack)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 32)
                .background(Color.white)
                .cornerRadius(40)
                .shadow(color: .black.opacity(0.04), radius: 10)
            }

            // Question Card
            VStack(spacing: 40) {
                // Header of card
                HStack {
                    Text(gameVM.currentQuestion?.category ?? "")
                        .font(.custom(AppTheme.mediumFont, size: 14))
                        .foregroundColor(.heritageGold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.heritageGold.opacity(0.1))
                        .cornerRadius(12)

                    Spacer()

                    DifficultyBadge(difficulty: gameVM.currentQuestion?.difficulty ?? .medium)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // Question Text
                Text(gameVM.currentQuestion?.text ?? "")
                    .font(.custom(AppTheme.titleFont, size: 30))
                    .foregroundColor(.inkBlack)
                    .multilineTextAlignment(.center)
                    .lineSpacing(10)
                    .padding(.horizontal, 32)

                // Answers
                if gameVM.currentQuestion?.type == .multipleChoice {
                    VStack(spacing: 16) {
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
                                            .font(.custom(AppTheme.mediumFont, size: 20))
                                        Spacer()
                                        if showResult {
                                            Image(systemName: choice == gameVM.currentQuestion?.correctAnswer ? "checkmark.circle.fill" : (choice == selectedAnswer ? "xmark.circle.fill" : "circle"))
                                                .font(.title2)
                                        }
                                    }
                                    .padding(24)
                                    .background(buttonBackgroundColor(for: choice))
                                    .foregroundColor(buttonTextColor(for: choice))
                                    .cornerRadius(24)
                                    .shadow(color: .black.opacity(choice == selectedAnswer ? 0 : 0.02), radius: 5)
                                }
                                .scaleEffect(choice == selectedAnswer ? 0.98 : 1.0)
                                .animation(.spring(), value: selectedAnswer)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                } else {
                    // Open Question Professional Manual UI
                    VStack(spacing: 32) {
                        Text("شو هي الإجابة؟")
                            .font(.custom(AppTheme.mediumFont, size: 20))
                            .foregroundColor(.inkBlack.opacity(0.4))

                        if showResult {
                            VStack(spacing: 8) {
                                Text("الإجابة الصحيحة:")
                                    .font(.custom(AppTheme.bodyFont, size: 14))
                                    .foregroundColor(.inkBlack.opacity(0.5))
                                Text(gameVM.currentQuestion?.correctAnswer ?? "")
                                    .font(.custom(AppTheme.titleFont, size: 36))
                                    .foregroundColor(.successGreen)
                            }
                            .padding(24)
                            .background(Color.successGreen.opacity(0.05))
                            .cornerRadius(24)
                            .transition(.scale.combined(with: .opacity))
                        }

                        HStack(spacing: 20) {
                            Button(action: { checkAnswer(gameVM.currentQuestion?.correctAnswer ?? "") }) {
                                Text("جاوب صح")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(ModernButtonStyle(backgroundColor: .successGreen))

                            Button(action: { checkAnswer("خطأ") }) {
                                Text("جاوب خطأ")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(ModernButtonStyle(backgroundColor: .dangerRed))
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(AppTheme.cardCornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 30, x: 0, y: 15)
            .padding(.horizontal, 24)

            // Helps row
            HStack(spacing: 24) {
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
                        .frame(width: 240)
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
        return Color.creamBackground.opacity(0.4)
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

// Missing Views that caused compilation errors
struct DifficultyBadge: View {
    let difficulty: Difficulty

    var body: some View {
        Text(label)
            .font(.custom(AppTheme.mediumFont, size: 12))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
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

struct ModernHelpButton: View {
    let title: String
    let icon: String
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.custom(AppTheme.mediumFont, size: 13))
            }
            .frame(width: 120, height: 80)
            .background(isDisabled ? Color.inkBlack.opacity(0.05) : Color.white)
            .foregroundColor(isDisabled ? .inkBlack.opacity(0.2) : .heritageGold)
            .cornerRadius(24)
            .shadow(color: .black.opacity(isDisabled ? 0 : 0.05), radius: 10, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isDisabled ? Color.clear : Color.heritageGold.opacity(0.1), lineWidth: 1)
            )
        }
        .disabled(isDisabled)
    }
}
