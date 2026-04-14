import Foundation
import AVFoundation

/// Polyphonic playback engine. Holds a pool of AVAudioPlayerNodes so fast typing
/// never drops a voice, and asks the active SoundPack for buffers per keystroke.
final class AudioEngine {
    static let shared = AudioEngine()

    private let engine = AVAudioEngine()
    private let mixer = AVAudioMixerNode()
    private var voices: [AVAudioPlayerNode] = []
    private let voiceCount = 16
    private var nextVoice = 0
    private let queue = DispatchQueue(label: "kikey.audio", qos: .userInteractive)

    private(set) var pack: SoundPack
    private var gain: Float = VolumeLevel.balanced.gain

    private init() {
        self.pack = SoundPackRegistry.defaultPack
    }

    // MARK: - Lifecycle

    func start() {
        queue.sync {
            guard !engine.isRunning else { return }
            engine.attach(mixer)
            engine.connect(mixer, to: engine.mainMixerNode, format: pack.audioFormat)

            voices.removeAll(keepingCapacity: true)
            for _ in 0..<voiceCount {
                let node = AVAudioPlayerNode()
                engine.attach(node)
                engine.connect(node, to: mixer, format: pack.audioFormat)
                voices.append(node)
            }

            mixer.outputVolume = gain
            engine.mainMixerNode.outputVolume = 1.0
            do {
                try engine.start()
                voices.forEach { $0.play() }
                NSLog("Kikey[audio]: engine started, voices=\(voices.count) gain=\(gain) pack=\(pack.id)")
            } catch {
                NSLog("Kikey[audio]: FAILED to start: \(error)")
            }
        }
    }

    func stop() {
        queue.sync {
            voices.forEach { $0.stop() }
            engine.stop()
        }
    }

    // MARK: - Configuration

    func apply(settings: Settings) {
        if let p = SoundPackRegistry.pack(id: settings.soundPackID) {
            self.pack = p
        }
        self.gain = settings.volume.gain
    }

    func setVolume(_ level: VolumeLevel) {
        queue.async {
            self.gain = level.gain
            self.mixer.outputVolume = level.gain
        }
    }

    func setPack(_ pack: SoundPack) {
        // All built-in packs share the same mono 44.1kHz format, so we just
        // swap the reference — no reconnect required. Doing an actual
        // disconnect/reconnect here previously left voice nodes in a stopped
        // state that scheduleBuffer(_:.interrupts) could not revive.
        queue.async {
            pack.reset()
            self.pack = pack
            NSLog("Kikey[audio]: switched pack → \(pack.id)")
        }
    }

    // MARK: - Playback

    func playKeyDown(keyCode: UInt16) {
        let buffer = pack.bufferForKeyDown(keyCode: keyCode, randomizePitch: Settings.shared.randomizePitch)
        NSLog("Kikey[audio]: playKeyDown keyCode=\(keyCode) frames=\(buffer.frameLength) running=\(engine.isRunning)")
        schedule(buffer: buffer)
    }

    func playKeyUp(keyCode: UInt16) {
        guard Settings.shared.playKeyUp else { return }
        guard let buffer = pack.bufferForKeyUp(keyCode: keyCode, randomizePitch: Settings.shared.randomizePitch) else { return }
        schedule(buffer: buffer)
    }

    private func schedule(buffer: AVAudioPCMBuffer) {
        queue.async {
            guard !self.voices.isEmpty else { return }
            let node = self.voices[self.nextVoice]
            self.nextVoice = (self.nextVoice + 1) % self.voices.count
            node.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        }
    }
}
