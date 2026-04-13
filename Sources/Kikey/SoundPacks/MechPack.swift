import Foundation
import AVFoundation

/// Mechanical keyboard "thock" — short noise burst shaped by a low-passed envelope.
final class MechPack: SoundPack {
    let id = "mech"
    let name = "Mech ⌨️"
    let icon = "⌨️"
    var audioFormat: AVAudioFormat { Synth.format }

    func bufferForKeyDown(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer {
        let buffer = Synth.makeBuffer(seconds: 0.06)
        let frames = Int(buffer.frameLength)
        let data = buffer.floatChannelData![0]

        let baseShift = Synth.keycodeSemitones(keyCode, range: 2.0)
        let jitter = randomizePitch ? Double.random(in: -1.0...1.0) : 0
        let ratio = Synth.semitonesToRatio(baseShift + jitter)
        let resonance = 180.0 * ratio

        var lp: Float = 0
        let alpha: Float = 0.18
        for i in 0..<frames {
            let t = Double(i) / Synth.sampleRate
            let click = Synth.noise()
            lp += alpha * (click - lp)
            let body = Float(Synth.sine(t, resonance)) * 0.4
            let env = Synth.envelope(at: i, total: frames, attack: 0.001, decay: 0.025)
            data[i] = (lp * 0.9 + body) * env * 0.7
        }
        return buffer
    }

    func bufferForKeyUp(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer? {
        let buffer = Synth.makeBuffer(seconds: 0.04)
        let frames = Int(buffer.frameLength)
        let data = buffer.floatChannelData![0]
        var lp: Float = 0
        for i in 0..<frames {
            let click = Synth.noise()
            lp += 0.25 * (click - lp)
            let env = Synth.envelope(at: i, total: frames, attack: 0.001, decay: 0.018)
            data[i] = lp * env * 0.45
        }
        return buffer
    }
}
