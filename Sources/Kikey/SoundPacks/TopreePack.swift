import Foundation
import AVFoundation

/// Topre-style "thock" — soft low-passed click with a warm body resonance.
/// No sharp transient, rounder decay than MechPack.
final class TopreePack: SoundPack {
    let id = "topre"
    let name = "Topre 🎹"
    let icon = "🎹"
    var audioFormat: AVAudioFormat { Synth.format }

    func bufferForKeyDown(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer {
        let buffer = Synth.makeBuffer(seconds: 0.11)
        let frames = Int(buffer.frameLength)
        let data = buffer.floatChannelData![0]

        let baseShift = Synth.keycodeSemitones(keyCode, range: 1.8)
        let jitter = randomizePitch ? Double.random(in: -0.8...0.8) : 0
        let ratio = Synth.semitonesToRatio(baseShift + jitter)
        let body = 115.0 * ratio
        let overtone = body * 2.7

        // Heavy low-pass filter for softness
        var lp1: Float = 0
        var lp2: Float = 0
        let alpha: Float = 0.08

        for i in 0..<frames {
            let t = Double(i) / Synth.sampleRate
            // Soft noise click window (first ~3ms only)
            let clickWindow: Float = (t < 0.003) ? 1.0 : 0.0
            let click = Synth.noise() * 0.9 * clickWindow
            lp1 += alpha * (click - lp1)
            lp2 += alpha * (lp1 - lp2)

            // Warm body — fundamental + quiet overtone
            let bodyTone = Synth.sine(t, body) * 0.55 + Synth.sine(t, overtone) * 0.18

            // Round envelope: slow attack, long exponential decay
            let env = Float(exp(-(t / 0.055))) * Float(min(1.0, t / 0.002))

            data[i] = (lp2 * 0.65 + Float(bodyTone) * 0.9) * env * 0.55
        }
        return buffer
    }

    func bufferForKeyUp(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer? {
        let buffer = Synth.makeBuffer(seconds: 0.05)
        let frames = Int(buffer.frameLength)
        let data = buffer.floatChannelData![0]
        var lp: Float = 0
        for i in 0..<frames {
            let t = Double(i) / Synth.sampleRate
            let click: Float = (t < 0.002) ? Synth.noise() * 0.7 : 0
            lp += 0.1 * (click - lp)
            let body = Float(Synth.sine(t, 95.0)) * 0.3
            let env = Float(exp(-(t / 0.03))) * Float(min(1.0, t / 0.001))
            data[i] = (lp * 0.5 + body) * env * 0.4
        }
        return buffer
    }
}
