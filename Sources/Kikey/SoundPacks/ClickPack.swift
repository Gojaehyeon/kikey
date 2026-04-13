import Foundation
import AVFoundation

/// Crisp mouse-click — very short noise burst with high-passed snap.
final class ClickPack: SoundPack {
    let id = "click"
    let name = "Click 🖱️"
    let icon = "🖱️"
    var audioFormat: AVAudioFormat { Synth.format }

    func bufferForKeyDown(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer {
        let buffer = Synth.makeBuffer(seconds: 0.025)
        let frames = Int(buffer.frameLength)
        let data = buffer.floatChannelData![0]

        var prev: Float = 0
        let attack: Float = randomizePitch ? Float.random(in: 0.85...1.0) : 0.95
        for i in 0..<frames {
            let n = Synth.noise()
            // High-pass to make it snappy
            let hp = n - prev
            prev = n
            let env = Synth.envelope(at: i, total: frames, attack: 0.0005, decay: 0.012)
            data[i] = hp * env * 0.42 * attack
        }
        return buffer
    }

    func bufferForKeyUp(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer? {
        let buffer = Synth.makeBuffer(seconds: 0.018)
        let frames = Int(buffer.frameLength)
        let data = buffer.floatChannelData![0]
        var prev: Float = 0
        for i in 0..<frames {
            let n = Synth.noise() * 0.6
            let hp = n - prev
            prev = n
            let env = Synth.envelope(at: i, total: frames, attack: 0.0005, decay: 0.008)
            data[i] = hp * env * 0.55
        }
        return buffer
    }
}
