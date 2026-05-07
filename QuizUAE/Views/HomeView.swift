import SwiftUI

struct HomeView: View {
    @ObservedObject var gameVM: GameViewModel

    var body: some View {
        ZStack {
            Color.darkBase.ignoresSafeArea()

            // Background Pattern (Subtle geometric motifs)
            GeometricPattern()
                .opacity(0.1)

            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 10) {
                    Text("تراثنا")
                        .font(.custom("Tajawal-Bold", size: 80))
                        .foregroundColor(.primaryGold)
                        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 5)

                    Text("مسابقات تراث الإمارات")
                        .font(.custom("Tajawal-Medium", size: 22))
                        .foregroundColor(.secondarySand)
                        .tracking(4)
                }

                Spacer()

                Button(action: {
                    withAnimation {
                        gameVM.gameState = .setup
                    }
                }) {
                    Text("دخول اللعبة")
                        .font(.custom("Tajawal-Bold", size: 24))
                        .foregroundColor(.darkBase)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 60)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.primaryGold, Color(hex: "#AA8A39")]), startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(20)
                        .shadow(color: .primaryGold.opacity(0.3), radius: 10, x: 0, y: 5)
                }

                Spacer().frame(height: 50)
            }
        }
    }
}

struct GeometricPattern: View {
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 40
            for x in stride(from: 0, through: size.width, by: step) {
                for y in stride(from: 0, through: size.height, by: step) {
                    context.stroke(
                        Path { path in
                            path.move(to: CGPoint(x: x, y: y))
                            path.addLine(to: CGPoint(x: x + step, y: y + step))
                            path.move(to: CGPoint(x: x + step, y: y))
                            path.addLine(to: CGPoint(x: x, y: y + step))
                        },
                        with: .color(.primaryGold),
                        lineWidth: 0.5
                    )
                }
            }
        }
    }
}
