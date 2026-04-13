import Foundation
import AVFoundation

/// Soft heartbeat thump — low sine pulse with quick attack and a warm tail.
final class HeartPack: SoundPack {
    let id = "heart"
    let name = "Heart 💗"
    let icon = "💗"
    var audioFormat: AVAudioFormat { Synth.format }

    func bufferForKeyDown(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer {
        let buffer = Synth.makeBuffer(seconds: 0.18)
        let frames = Int(buffer.frameLength)
        let data = buffer.floatChannelData![0]

        let baseShift = Synth.keycodeSemitones(keyCode, range: 2.0)
        let jitter = randomizePitch ? Double.random(in: -0.4...0.4) : 0
        let ratio = Synth.semitonesToRatio(baseShift + jitter)
        let f = 95.0 * ratio

        for i in 0..<frames {
            let t = Double(i) / Synth.sampleRate
            // Pitch dips downward for that "thump"
            let pitchEnv = 1.0 + 0.6 * exp(-(t / 0.02))
            let s = Synth.sine(t, f * pitchEnv) * 0.85
            let env = Float(exp(-(t / 0.07))) * Float(min(1.0, t / 0.004))
            data[i] = Float(s) * env * 0.75
        }
        return buffer
    }

    func bufferForKeyUp(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer? {
        nil
    }
}
