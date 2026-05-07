import Foundation
import AVFoundation
import CoreHaptics

class AudioManager {
    static let shared = AudioManager()
    private var audioPlayer: AVAudioPlayer?

    func playSound(named name: String) {
        // Placeholder for playing sound
        print("Playing sound: \(name)")
        /*
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Could not play sound file: \(error)")
        }
        */
    }
}

class HapticManager {
    static let shared = HapticManager()

    func triggerSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    func triggerSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func triggerImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
