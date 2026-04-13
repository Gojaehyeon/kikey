import Foundation
import AVFoundation

/// Glass-bell chime — fundamental + a couple of harmonics with long decay.
final class BellPack: SoundPack {
    let id = "bell"
    let name = "Bell 🔔"
    let icon = "🔔"
    var audioFormat: AVAudioFormat { Synth.format }

    func bufferForKeyDown(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer {
        let buffer = Synth.makeBuffer(seconds: 0.35)
        let frames = Int(buffer.frameLength)
        let data = buffer.floatChannelData![0]

        let baseShift = Synth.keycodeSemitones(keyCode, range: 7.0)
        let jitter = randomizePitch ? Double.random(in: -0.5...0.5) : 0
        let ratio = Synth.semitonesToRatio(baseShift + jitter)
        let f0 = 880.0 * ratio

        for i in 0..<frames {
            let t = Double(i) / Synth.sampleRate
            let s = Synth.sine(t, f0) * 0.55
                + Synth.sine(t, f0 * 2.76) * 0.30
                + Synth.sine(t, f0 * 5.40) * 0.15
            let env = Float(exp(-(t / 0.18))) * Float(min(1.0, t / 0.003))
            data[i] = Float(s) * env * 0.5
        }
        return buffer
    }

    func bufferForKeyUp(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer? {
        nil
    }
}
