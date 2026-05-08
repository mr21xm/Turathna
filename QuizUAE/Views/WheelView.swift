import SwiftUI

struct WheelView: View {
    @ObservedObject var gameVM: GameViewModel
    @State private var rotation: Double = 0
    @State private var isSpinning: Bool = false
    @State private var showResultOverlay: Bool = false

    // Pointer is at the top (270 degrees)
    private let pointerAngle: Double = 270.0

    var body: some View {
        VStack(spacing: 50) {
            ZStack {
                // Background Glow
                Circle()
                    .fill(
                        RadialGradient(colors: [.heritageGold.opacity(0.15), .clear], center: .center, startRadius: 0, endRadius: 200)
                    )
                    .frame(width: 400, height: 400)

                // Decorative Outer Ring
                Circle()
                    .stroke(Color.heritageGold.opacity(0.2), lineWidth: 2)
                    .frame(width: 350, height: 350)

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

                        // Professional vibrant colors
                        context.fill(path, with: .color(segment.color))
                        context.stroke(path, with: .color(.white.opacity(0.4)), lineWidth: 1.5)

                        // Minimalist Labels
                        let midAngle = Double(index) * angleStep + angleStep / 2
                        let textRadius = radius * 0.72
                        let x = center.x + cos(midAngle) * textRadius
                        let y = center.y + sin(midAngle) * textRadius

                        context.draw(
                            Text(segment.label)
                                .font(.custom(AppTheme.titleFont, size: 14))
                                .foregroundColor(.white),
                            at: CGPoint(x: x, y: y)
                        )
                    }

                    // Center Hub
                    let hubRadius: CGFloat = 24
                    var hubPath = Path()
                    hubPath.addEllipse(in: CGRect(x: center.x - hubRadius, y: center.y - hubRadius, width: hubRadius * 2, height: hubRadius * 2))
                    context.fill(hubPath, with: .color(.white))
                    context.stroke(hubPath, with: .color(.heritageGold), lineWidth: 5)
                }
                .rotationEffect(Angle(degrees: rotation))
                .frame(width: 320, height: 320)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)

                // The Pointer (At 270 degrees)
                Image(systemName: "arrowtriangle.down.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                    .foregroundColor(.heritageGold)
                    .offset(y: -170)
                    .shadow(color: .black.opacity(0.1), radius: 5)
            }

            // Interaction State
            VStack(spacing: 20) {
                if !isSpinning && !showResultOverlay {
                    Button(action: {
                        startSpinning()
                    }) {
                        Text("دِوّرها الحين!")
                            .frame(width: 240)
                    }
                    .buttonStyle(ModernButtonStyle())
                } else if showResultOverlay {
                    VStack(spacing: 12) {
                        Text("وقفت على")
                            .font(.custom(AppTheme.mediumFont, size: 20))
                            .foregroundColor(.inkBlack.opacity(0.4))

                        Text(gameVM.wheelResult?.label ?? "")
                            .font(.custom(AppTheme.titleFont, size: 48))
                            .foregroundColor(.heritageGold)
                            .scaleEffect(1.2)
                    }
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                } else {
                    Text("جاري التدوير...")
                        .font(.custom(AppTheme.mediumFont, size: 24))
                        .foregroundColor(.heritageGold)
                }
            }
        }
        .onAppear {
            // Give user 1 second to see the wheel then auto-spin
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                if !isSpinning && !showResultOverlay {
                    startSpinning()
                }
            }
        }
    }

    func startSpinning() {
        guard !isSpinning else { return }
        isSpinning = true
        showResultOverlay = false

        let extraRotations = Double.random(in: 10...15) * 360
        let targetRotation = rotation + extraRotations + Double.random(in: 0...360)

        withAnimation(.timingCurve(0.1, 0.4, 0.1, 1, duration: 6)) {
            rotation = targetRotation
        }

        AudioManager.shared.playSound(named: "spin")
        HapticManager.shared.triggerSelection()

        DispatchQueue.main.asyncAfter(deadline: .now() + 6.1) {
            isSpinning = false
            determineResult()
            withAnimation(.spring()) {
                showResultOverlay = true
            }

            // Ample time to see the result
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                gameVM.proceedFromWheel()
            }
        }
    }

    func determineResult() {
        // Pointer is at 270 degrees
        let normalizedRotation = rotation.truncatingRemainder(dividingBy: 360)

        // Exact Calculation
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
