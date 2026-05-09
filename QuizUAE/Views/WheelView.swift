import SwiftUI

struct WheelView: View {
    @ObservedObject var gameVM: GameViewModel
    @State private var rotation: Double = 0
    @State private var isSpinning: Bool = false
    @State private var showResultOverlay: Bool = false
    @State private var selectedSegmentIndex: Int = 0

    // Pointer is at the top (270 degrees in standard polar coords where 0 is East)
    private let pointerAngle: Double = 270.0

    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                // Background Glow
                Circle()
                    .fill(RadialGradient(colors: [.heritageGold.opacity(0.1), .clear], center: .center, startRadius: 0, endRadius: 150))
                    .frame(width: 300, height: 300)

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

                        context.fill(path, with: .color(segment.color))
                        context.stroke(path, with: .color(.white.opacity(0.3)), lineWidth: 1)

                        let midAngle = Double(index) * angleStep + angleStep / 2
                        let textRadius = radius * 0.7
                        let x = center.x + cos(midAngle) * textRadius
                        let y = center.y + sin(midAngle) * textRadius

                        context.draw(
                            Text(segment.label)
                                .font(.custom(AppTheme.titleFont, size: 10))
                                .foregroundColor(.white),
                            at: CGPoint(x: x, y: y)
                        )
                    }

                    let hubRadius: CGFloat = 18
                    var hubPath = Path()
                    hubPath.addEllipse(in: CGRect(x: center.x - hubRadius, y: center.y - hubRadius, width: hubRadius * 2, height: hubRadius * 2))
                    context.fill(hubPath, with: .color(.white))
                    context.stroke(hubPath, with: .color(.heritageGold), lineWidth: 4)
                }
                .rotationEffect(Angle(degrees: rotation))
                .frame(width: 260, height: 260)
                .shadow(color: .black.opacity(0.08), radius: 15)

                // The Pointer
                Image(systemName: "arrowtriangle.down.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundColor(.heritageGold)
                    .offset(y: -140)
            }

            VStack(spacing: 16) {
                if !isSpinning && !showResultOverlay {
                    Button(action: {
                        startSpinning()
                    }) {
                        Text("دِوّرها!")
                            .frame(width: 180)
                    }
                    .buttonStyle(ModernButtonStyle())
                } else if showResultOverlay {
                    VStack(spacing: 8) {
                        Text("وقفت على")
                            .font(.custom(AppTheme.mediumFont, size: 16))
                            .foregroundColor(.inkBlack.opacity(0.4))

                        Text(gameVM.wheelSegments[selectedSegmentIndex].label)
                            .font(.custom(AppTheme.titleFont, size: 32))
                            .foregroundColor(.heritageGold)
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Text("جاري التدوير...")
                        .font(.custom(AppTheme.mediumFont, size: 18))
                        .foregroundColor(.heritageGold)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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

        // 1. Pick the result segment FIRST
        selectedSegmentIndex = Int.random(in: 0..<gameVM.wheelSegments.count)
        let result = gameVM.wheelSegments[selectedSegmentIndex]

        // 2. Calculate the target rotation
        // Angle of the center of the selected segment
        let angleStep = 360.0 / Double(gameVM.wheelSegments.count)
        let segmentCenterAngle = (Double(selectedSegmentIndex) * angleStep) + (angleStep / 2.0)

        // To align segmentCenterAngle with the pointerAngle (270), we need:
        // (segmentCenterAngle + totalRotation) % 360 = pointerAngle
        // totalRotation = pointerAngle - segmentCenterAngle
        let baseRotation = (pointerAngle - segmentCenterAngle).truncatingRemainder(dividingBy: 360)
        let extraRotations = Double.random(in: 8...12) * 360
        let targetRotation = extraRotations + (baseRotation >= 0 ? baseRotation : baseRotation + 360)

        withAnimation(.timingCurve(0.1, 0.4, 0.1, 1, duration: 5)) {
            rotation = targetRotation
        }

        AudioManager.shared.playSound(named: "spin")
        HapticManager.shared.triggerSelection()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.1) {
            isSpinning = false
            // 3. Award the points based on the PRE-SELECTED segment
            gameVM.landOnSegment(result)

            withAnimation(.spring()) {
                showResultOverlay = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                gameVM.proceedFromWheel()
            }
        }
    }
}
