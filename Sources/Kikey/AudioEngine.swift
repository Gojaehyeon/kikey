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
            do {
                try engine.start()
                voices.forEach { $0.play() }
            } catch {
                NSLog("Kikey: failed to start audio engine: \(error)")
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
        queue.async {
            let wasRunning = self.engine.isRunning
            if wasRunning {
                self.voices.forEach { self.engine.disconnectNodeOutput($0) }
                self.engine.disconnectNodeOutput(self.mixer)
            }
            self.pack = pack
            if wasRunning {
                self.engine.connect(self.mixer, to: self.engine.mainMixerNode, format: pack.audioFormat)
                for node in self.voices {
                    self.engine.connect(node, to: self.mixer, format: pack.audioFormat)
                }
            }
        }
    }

    // MARK: - Playback

    func playKeyDown(keyCode: UInt16) {
        let buffer = pack.bufferForKeyDown(keyCode: keyCode, randomizePitch: Settings.shared.randomizePitch)
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
