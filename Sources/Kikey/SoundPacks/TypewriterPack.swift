import Foundation
import AVFoundation

/// Sharp typewriter strike — a metallic click with a brief decaying ring.
final class TypewriterPack: SoundPack {
    let id = "typewriter"
    let name = "Typewriter 📝"
    let icon = "📝"
    var audioFormat: AVAudioFormat { Synth.format }

    func bufferForKeyDown(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer {
        let buffer = Synth.makeBuffer(seconds: 0.09)
        let frames = Int(buffer.frameLength)
        let data = buffer.floatChannelData![0]

        let baseShift = Synth.keycodeSemitones(keyCode, range: 1.5)
        let jitter = randomizePitch ? Double.random(in: -0.6...0.6) : 0
        let ratio = Synth.semitonesToRatio(baseShift + jitter)
        let ringFreq = 2200.0 * ratio

        for i in 0..<frames {
            let t = Double(i) / Synth.sampleRate
            let click = (i < 80) ? Synth.noise() * 0.9 : 0.0
            let ring = Synth.sine(t, ringFreq) * 0.35
            let env = Synth.envelope(at: i, total: frames, attack: 0.0008, decay: 0.04)
            data[i] = Float(Double(click) + ring) * env * 0.6
        }
        return buffer
    }

    func bufferForKeyUp(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer? {
        nil
    }
}
