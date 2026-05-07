import SwiftUI

struct WheelView: View {
    @ObservedObject var gameVM: GameViewModel
    @State private var rotation: Double = 0
    @State private var isSpinning: Bool = false

    var body: some View {
        VStack(spacing: 50) {
            ZStack {
                // The Wheel
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let radius = min(size.width, size.height) / 2
                    let angleStep = 2 * Double.pi / Double(gameVM.wheelSegments.count)

                    for (index, segment) in gameVM.wheelSegments.enumerated() {
                        var path = Path()
                        path.move(to: center)
                        path.addArc(center: center, radius: radius, startAngle: Angle(radians: Double(index) * angleStep), endAngle: Angle(radians: Double(index + 1) * angleStep), clockwise: false)
                        path.closeSubpath()

                        context.fill(path, with: .color(segment.color))
                        context.stroke(path, with: .color(.white.opacity(0.3)), lineWidth: 1)

                        // Labels
                        let midAngle = Double(index) * angleStep + angleStep / 2
                        let textRadius = radius * 0.7
                        let x = center.x + cos(midAngle) * textRadius
                        let y = center.y + sin(midAngle) * textRadius

                        context.draw(Text(segment.label).font(.custom("Tajawal-Bold", size: 14)).foregroundColor(.white), at: CGPoint(x: x, y: y))
                    }

                    // Inner Circle
                    let innerRadius = radius * 0.15
                    var innerPath = Path()
                    innerPath.addEllipse(in: CGRect(x: center.x - innerRadius, y: center.y - innerRadius, width: innerRadius * 2, height: innerRadius * 2))
                    context.fill(innerPath, with: .color(.darkBase))
                    context.stroke(innerPath, with: .color(.primaryGold), lineWidth: 3)
                }
                .rotationEffect(Angle(degrees: rotation))
                .frame(width: 320, height: 320)

                // Pointer
                Image(systemName: "triangle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.primaryGold)
                    .offset(y: -170)
                    .shadow(radius: 2)
            }

            if !isSpinning {
                Button(action: {
                    startSpinning()
                }) {
                    Text("اضغط للتدوير")
                        .font(.custom("Tajawal-Bold", size: 24))
                        .foregroundColor(.darkBase)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 40)
                        .background(Color.primaryGold)
                        .cornerRadius(15)
                }
            } else {
                Text("جاري التدوير...")
                    .font(.custom("Tajawal-Medium", size: 24))
                    .foregroundColor(.secondarySand)
            }
        }
        .onAppear {
            // Auto spin or wait for button? The prompt said "Player taps Spin the Wheel button"
            // In GameView I already have a button that switches to .spinning state.
            // Let's make this view handle the animation.
        }
    }

    func startSpinning() {
        guard !isSpinning else { return }
        isSpinning = true

        let extraRotations = Double.random(in: 5...10) * 360
        let targetRotation = rotation + extraRotations + Double.random(in: 0...360)

        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 4)) {
            rotation = targetRotation
        }

        // Haptic Feedback & Sound
        AudioManager.shared.playSound(named: "spin")
        HapticManager.shared.triggerSelection()

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.1) {
            isSpinning = false
            determineResult()
        }
    }

    func determineResult() {
        // Pointer is at the top (270 degrees in standard circle where 0 is East)
        // Normalized rotation (how much the wheel has been rotated clockwise)
        let normalizedRotation = rotation.truncatingRemainder(dividingBy: 360)

        // When rotation is 0, segment 0 starts at 0 degrees (East).
        // The segment at the pointer (Top/270 degrees) is:
        // (PointerAngle - normalizedRotation) % 360
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
