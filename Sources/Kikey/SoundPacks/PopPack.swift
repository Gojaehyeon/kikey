import Foundation
import AVFoundation

/// Soft bubble pop — short upward pitch sweep on a sine.
final class PopPack: SoundPack {
    let id = "pop"
    let name = "Pop 🫧"
    let icon = "🫧"
    var audioFormat: AVAudioFormat { Synth.format }

    func bufferForKeyDown(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer {
        let buffer = Synth.makeBuffer(seconds: 0.07)
        let frames = Int(buffer.frameLength)
        let data = buffer.floatChannelData![0]

        let baseShift = Synth.keycodeSemitones(keyCode, range: 6.0)
        let jitter = randomizePitch ? Double.random(in: -2.0...2.0) : 0
        let ratio = Synth.semitonesToRatio(baseShift + jitter)
        let startFreq = 380.0 * ratio
        let endFreq   = 820.0 * ratio

        for i in 0..<frames {
            let t = Double(i) / Synth.sampleRate
            let progress = t / (Double(frames) / Synth.sampleRate)
            let f = startFreq + (endFreq - startFreq) * progress
            let s = Synth.sine(t, f)
            let env = Synth.envelope(at: i, total: frames, attack: 0.003, decay: 0.035)
            data[i] = Float(s) * env * 0.55
        }
        return buffer
    }

    func bufferForKeyUp(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer? {
        nil
    }
}
