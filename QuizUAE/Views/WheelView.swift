import SwiftUI

struct WheelView: View {
    @ObservedObject var gameVM: GameViewModel
    @State private var rotation: Double = 0
    @State private var isSpinning: Bool = false
    @State private var showResultOverlay: Bool = false

    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                // Outer Glow/Border
                Circle()
                    .stroke(Color.heritageGold.opacity(0.3), lineWidth: 10)
                    .frame(width: 340, height: 340)
                    .shadow(color: .heritageGold.opacity(0.2), radius: 20)

                // The Wheel
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let radius = size.width / 2
                    let angleStep = 2 * Double.pi / Double(gameVM.wheelSegments.count)

                    for (index, segment) in gameVM.wheelSegments.enumerated() {
                        var path = Path()
                        path.move(to: center)
                        path.addArc(center: center, radius: radius,
                                   startAngle: Angle(radians: Double(index) * angleStep),
                                   endAngle: Angle(radians: Double(index + 1) * angleStep),
                                   clockwise: false)
                        path.closeSubpath()

                        context.fill(path, with: .color(segment.color.opacity(0.8)))
                        context.stroke(path, with: .color(.white.opacity(0.5)), lineWidth: 1)

                        // Labels
                        let midAngle = Double(index) * angleStep + angleStep / 2
                        let textRadius = radius * 0.75
                        let x = center.x + cos(midAngle) * textRadius
                        let y = center.y + sin(midAngle) * textRadius

                        context.draw(
                            Text(segment.label)
                                .font(.custom(AppTheme.titleFont, size: 12))
                                .foregroundColor(.white),
                            at: CGPoint(x: x, y: y)
                        )
                    }

                    // Center Piece
                    let innerRadius: CGFloat = 20
                    var innerPath = Path()
                    innerPath.addEllipse(in: CGRect(x: center.x - innerRadius, y: center.y - innerRadius, width: innerRadius * 2, height: innerRadius * 2))
                    context.fill(innerPath, with: .color(.white))
                    context.stroke(innerPath, with: .color(.heritageGold), lineWidth: 4)
                }
                .rotationEffect(Angle(degrees: rotation))
                .frame(width: 320, height: 320)

                // Pointer at the TOP (270 degrees)
                Image(systemName: "arrowtriangle.down.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.heritageGold)
                    .offset(y: -165)
                    .shadow(radius: 5)
            }
            .scaleEffect(isSpinning ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.5), value: isSpinning)

            if !isSpinning && !showResultOverlay {
                Button(action: {
                    startSpinning()
                }) {
                    Text("دِوّرها!")
                        .frame(width: 200)
                }
                .buttonStyle(ModernButtonStyle())
            } else if showResultOverlay {
                VStack(spacing: 10) {
                    Text("مبروك!")
                        .font(.custom(AppTheme.mediumFont, size: 18))
                        .foregroundColor(.heritageGold)
                    Text(gameVM.wheelResult?.label ?? "")
                        .font(.custom(AppTheme.titleFont, size: 36))
                        .foregroundColor(.charcoalModern)
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                Text("جاري التدوير...")
                    .font(.custom(AppTheme.mediumFont, size: 20))
                    .foregroundColor(.heritageGold)
            }
        }
        .onAppear {
            // Automatically start spinning after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                startSpinning()
            }
        }
    }

    func startSpinning() {
        guard !isSpinning else { return }
        isSpinning = true
        showResultOverlay = false

        let extraRotations = Double.random(in: 8...12) * 360
        let targetRotation = rotation + extraRotations + Double.random(in: 0...360)

        withAnimation(.timingCurve(0.15, 0.5, 0.2, 1, duration: 5)) {
            rotation = targetRotation
        }

        AudioManager.shared.playSound(named: "spin")
        HapticManager.shared.triggerSelection()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.1) {
            isSpinning = false
            determineResult()
            withAnimation {
                showResultOverlay = true
            }

            // Delay before moving to question
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                gameVM.proceedFromWheel()
            }
        }
    }

    func determineResult() {
        // Pointer is at the top (270 degrees)
        let normalizedRotation = rotation.truncatingRemainder(dividingBy: 360)

        // Calculation: (PointerAngle - TotalRotation) % 360
        let pointerAngle = 270.0
        var angleAtPointer = (pointerAngle - normalizedRotation).truncatingRemainder(dividingBy: 360)
        if angleAtPointer < 0 { angleAtPointer += 360 }

        let angleStep = 360.0 / Double(gameVM.wheelSegments.count)
        let segmentIndex = Int(angleAtPointer / angleStep) % gameVM.wheelSegments.count

        let result = gameVM.wheelSegments[segmentIndex]
        AudioManager.shared.playSound(named: "land")
        HapticManager.shared.triggerImpact()
        gameVM.landOnSegment(result)
    }
}
