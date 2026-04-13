import Foundation
import AVFoundation

/// Water drop — a downward sweep with a soft tail.
final class DropPack: SoundPack {
    let id = "drop"
    let name = "Drop 💧"
    let icon = "💧"
    var audioFormat: AVAudioFormat { Synth.format }

    func bufferForKeyDown(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer {
        let buffer = Synth.makeBuffer(seconds: 0.14)
        let frames = Int(buffer.frameLength)
        let data = buffer.floatChannelData![0]

        let baseShift = Synth.keycodeSemitones(keyCode, range: 5.0)
        let jitter = randomizePitch ? Double.random(in: -1.5...1.5) : 0
        let ratio = Synth.semitonesToRatio(baseShift + jitter)
        let startFreq = 1200.0 * ratio
        let endFreq   = 540.0 * ratio

        for i in 0..<frames {
            let t = Double(i) / Synth.sampleRate
            let progress = t / (Double(frames) / Synth.sampleRate)
            let f = startFreq + (endFreq - startFreq) * progress
            let s = Synth.sine(t, f) * 0.7 + Synth.sine(t, f * 2) * 0.15
            let env = Synth.envelope(at: i, total: frames, attack: 0.004, decay: 0.07)
            data[i] = Float(s) * env * 0.5
        }
        return buffer
    }

    func bufferForKeyUp(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer? {
        nil
    }
}
