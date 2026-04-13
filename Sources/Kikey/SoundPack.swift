import Foundation
import AVFoundation

/// A SoundPack synthesizes (or loads) PCM buffers for keystrokes. All built-in
/// packs are procedurally generated so the app ships with zero audio assets and
/// loads instantly.
protocol SoundPack: AnyObject {
    var id: String { get }
    var name: String { get }
    var icon: String { get }
    var audioFormat: AVAudioFormat { get }

    func bufferForKeyDown(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer
    func bufferForKeyUp(keyCode: UInt16, randomizePitch: Bool) -> AVAudioPCMBuffer?
}

/// Shared helpers for procedural synthesis.
enum Synth {
    static let sampleRate: Double = 44_100

    static var format: AVAudioFormat {
        AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
    }

    static func makeBuffer(seconds: Double) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(seconds * sampleRate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        return buffer
    }

    /// Fast attack, exponential decay envelope.
    static func envelope(at frame: Int, total: Int, attack: Double = 0.005, decay: Double = 0.08) -> Float {
        let t = Double(frame) / sampleRate
        let attackEnv = min(1.0, t / attack)
        let decayEnv = exp(-(t / decay))
        return Float(attackEnv * decayEnv)
    }

    static func sine(_ phase: Double, _ freq: Double) -> Double {
        sin(2 * .pi * freq * phase)
    }

    /// Cheap deterministic-ish noise for clicks.
    static func noise() -> Float {
        Float.random(in: -1...1)
    }

    /// Hash a keycode into a stable pitch-shift factor (semitones).
    static func keycodeSemitones(_ keyCode: UInt16, range: Double = 4.0) -> Double {
        let normalized = (Double(keyCode % 24) / 24.0) * 2.0 - 1.0
        return normalized * range
    }

    static func semitonesToRatio(_ semitones: Double) -> Double {
        pow(2.0, semitones / 12.0)
    }
}
