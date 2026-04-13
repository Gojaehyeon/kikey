import Foundation
import AVFoundation

/// Tiny "meow"-ish chirp built from two formant sines with a downward pitch glide.
final class CatPack: SoundPack {
    let id = "cat"
    let name = "Cat 🐱"
    let icon = "🐱"
    var audioFormat: AVAudioFormat { Synth.format }

    func bufferForKeyDown(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer {
        let buffer = Synth.makeBuffer(seconds: 0.18)
        let frames = Int(buffer.frameLength)
        let data = buffer.floatChannelData![0]

        let baseShift = Synth.keycodeSemitones(keyCode, range: 5.0)
        let jitter = randomizePitch ? Double.random(in: -1.5...1.5) : 0
        let ratio = Synth.semitonesToRatio(baseShift + jitter)

        // Two formants of a cat-like vocalization.
        let f1Start = 700.0 * ratio
        let f1End   = 480.0 * ratio
        let f2Start = 1500.0 * ratio
        let f2End   = 1100.0 * ratio

        for i in 0..<frames {
            let t = Double(i) / Synth.sampleRate
            let progress = t / (Double(frames) / Synth.sampleRate)
            let f1 = f1Start + (f1End - f1Start) * progress
            let f2 = f2Start + (f2End - f2Start) * progress
            let vibrato = 1.0 + 0.02 * sin(2 * .pi * 22 * t)
            let s = (Synth.sine(t, f1 * vibrato) * 0.6 + Synth.sine(t, f2 * vibrato) * 0.4)
            let env = Synth.envelope(at: i, total: frames, attack: 0.012, decay: 0.09)
            data[i] = Float(s) * env * 0.55
        }
        return buffer
    }

    func bufferForKeyUp(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer? {
        let buffer = Synth.makeBuffer(seconds: 0.05)
        let frames = Int(buffer.frameLength)
        let data = buffer.floatChannelData![0]
        for i in 0..<frames {
            let t = Double(i) / Synth.sampleRate
            let env = Synth.envelope(at: i, total: frames, attack: 0.002, decay: 0.025)
            let s = Synth.sine(t, 320) * 0.5 + Double(Synth.noise()) * 0.05
            data[i] = Float(s) * env * 0.25
        }
        return buffer
    }
}
