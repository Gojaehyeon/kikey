import Foundation
import Observation

enum VolumeLevel: String, CaseIterable, Identifiable, Codable {
    case soft, balanced, loud
    var id: String { rawValue }
    var gain: Float {
        switch self {
        case .soft: return 0.35
        case .balanced: return 0.7
        case .loud: return 1.0
        }
    }
    var label: String {
        switch self {
        case .soft: return "Soft"
        case .balanced: return "Balanced"
        case .loud: return "Loud"
        }
    }
}

@Observable
final class Settings {
    static let shared = Settings()

    private let store = UserDefaults.standard
    private enum Key {
        static let enabled = "kikey.enabled"
        static let volume = "kikey.volume"
        static let soundPackID = "kikey.soundPackID"
        static let showMenuBarIcon = "kikey.showMenuBarIcon"
        static let muteOnSecureInput = "kikey.muteOnSecureInput"
        static let launchAtLogin = "kikey.launchAtLogin"
        static let randomizePitch = "kikey.randomizePitch"
        static let playKeyUp = "kikey.playKeyUp"
        static let hapticFeedback = "kikey.hapticFeedback"
    }

    var enabled: Bool {
        didSet { store.set(enabled, forKey: Key.enabled) }
    }
    var volume: VolumeLevel {
        didSet {
            store.set(volume.rawValue, forKey: Key.volume)
            AudioEngine.shared.setVolume(volume)
        }
    }
    var soundPackID: String {
        didSet {
            store.set(soundPackID, forKey: Key.soundPackID)
            if let pack = SoundPackRegistry.pack(id: soundPackID) {
                AudioEngine.shared.setPack(pack)
            }
        }
    }
    var showMenuBarIcon: Bool {
        didSet { store.set(showMenuBarIcon, forKey: Key.showMenuBarIcon) }
    }
    var muteOnSecureInput: Bool {
        didSet { store.set(muteOnSecureInput, forKey: Key.muteOnSecureInput) }
    }
    var launchAtLogin: Bool {
        didSet {
            store.set(launchAtLogin, forKey: Key.launchAtLogin)
            LaunchAtLoginManager.apply(enabled: launchAtLogin)
        }
    }
    var randomizePitch: Bool {
        didSet { store.set(randomizePitch, forKey: Key.randomizePitch) }
    }
    var playKeyUp: Bool {
        didSet { store.set(playKeyUp, forKey: Key.playKeyUp) }
    }
    var hapticFeedback: Bool {
        didSet { store.set(hapticFeedback, forKey: Key.hapticFeedback) }
    }

    private init() {
        // Defaults
        store.register(defaults: [
            Key.enabled: true,
            Key.volume: VolumeLevel.balanced.rawValue,
            Key.soundPackID: "cat",
            Key.showMenuBarIcon: true,
            Key.muteOnSecureInput: true,
            Key.launchAtLogin: false,
            Key.randomizePitch: true,
            Key.playKeyUp: true,
            Key.hapticFeedback: false,
        ])
        self.enabled = store.bool(forKey: Key.enabled)
        self.volume = VolumeLevel(rawValue: store.string(forKey: Key.volume) ?? "balanced") ?? .balanced
        self.soundPackID = store.string(forKey: Key.soundPackID) ?? "cat"
        self.showMenuBarIcon = store.bool(forKey: Key.showMenuBarIcon)
        self.muteOnSecureInput = store.bool(forKey: Key.muteOnSecureInput)
        self.launchAtLogin = store.bool(forKey: Key.launchAtLogin)
        self.randomizePitch = store.bool(forKey: Key.randomizePitch)
        self.playKeyUp = store.bool(forKey: Key.playKeyUp)
        self.hapticFeedback = store.bool(forKey: Key.hapticFeedback)
    }
}
