import Foundation
import AVFoundation

/// Music box pack — each keystroke advances through a predefined melody,
/// playing the next note as a chime. Keycode is ignored. Cycles forever
/// and resets when you switch to this pack.
class MusicBoxPack: SoundPack {
    let id: String
    let name: String
    let icon: String
    var audioFormat: AVAudioFormat { Synth.format }

    /// MIDI note numbers making up the melody.
    private let melody: [Int]
    private var index: Int = 0
    private let lock = NSLock()

    init(id: String, name: String, icon: String, melody: [Int]) {
        self.id = id
        self.name = name
        self.icon = icon
        self.melody = melody
    }

    func bufferForKeyDown(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer {
        lock.lock()
        let midi = melody[index % melody.count]
        index += 1
        lock.unlock()
        return Self.synthesizeChime(midiNote: midi)
    }

    func bufferForKeyUp(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer? {
        nil
    }

    func reset() {
        lock.lock()
        index = 0
        lock.unlock()
    }

    /// Kalimba / music-box timbre: fundamental + odd harmonics with long decay.
    static func synthesizeChime(midiNote: Int) -> AVAudioPCMBuffer {
        let buffer = Synth.makeBuffer(seconds: 0.8)
        let frames = Int(buffer.frameLength)
        let data = buffer.floatChannelData![0]

        let freq = 440.0 * pow(2.0, (Double(midiNote) - 69.0) / 12.0)

        for i in 0..<frames {
            let t = Double(i) / Synth.sampleRate
            let s = Synth.sine(t, freq) * 0.60
                + Synth.sine(t, freq * 2.01) * 0.22
                + Synth.sine(t, freq * 3.98) * 0.10
                + Synth.sine(t, freq * 5.42) * 0.05
            // Short percussive attack, long exponential tail
            let env = Float(exp(-(t / 0.32))) * Float(min(1.0, t / 0.004))
            data[i] = Float(s) * env * 0.48
        }
        return buffer
    }
}

// MARK: - Built-in melodies

enum Melodies {
    /// Twinkle Twinkle Little Star (C major).
    static let twinkle: [Int] = [
        60, 60, 67, 67, 69, 69, 67,
        65, 65, 64, 64, 62, 62, 60,
        67, 67, 65, 65, 64, 64, 62,
        67, 67, 65, 65, 64, 64, 62,
        60, 60, 67, 67, 69, 69, 67,
        65, 65, 64, 64, 62, 62, 60,
    ]

    /// Ode to Joy (Beethoven, Symphony No. 9).
    static let odeToJoy: [Int] = [
        64, 64, 65, 67, 67, 65, 64, 62,
        60, 60, 62, 64, 64, 62, 62,
        64, 64, 65, 67, 67, 65, 64, 62,
        60, 60, 62, 64, 62, 60, 60,
    ]

    /// Pachelbel's Canon in D — opening phrase.
    static let canon: [Int] = [
        74, 66, 67, 62, 64, 57, 59, 54,
        62, 54, 55, 50, 52, 45, 47, 42,
        74, 66, 67, 62, 64, 57, 59, 54,
    ]
}

// Convenience factories kept as instances the registry can reuse.
func makeTwinklePack() -> MusicBoxPack {
    MusicBoxPack(id: "twinkle", name: "Twinkle ⭐", icon: "⭐", melody: Melodies.twinkle)
}

func makeOdeToJoyPack() -> MusicBoxPack {
    MusicBoxPack(id: "ode", name: "Ode to Joy 🎶", icon: "🎶", melody: Melodies.odeToJoy)
}

func makeCanonPack() -> MusicBoxPack {
    MusicBoxPack(id: "canon", name: "Canon 🎼", icon: "🎼", melody: Melodies.canon)
}
