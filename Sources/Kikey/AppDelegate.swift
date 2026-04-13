import AppKit
import SwiftUI
import Carbon.HIToolbox

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let audio = AudioEngine.shared
    private let tap = KeyEventTap.shared
    private let hotkey = HotKeyManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        let settings = Settings.shared

        // Apply persisted settings to the audio engine and start it.
        audio.apply(settings: settings)
        audio.start()

        // Wire keyboard events to the audio engine.
        tap.onKeyDown = { [weak self] keyCode in
            guard let self = self else { return }
            guard Settings.shared.enabled else { return }
            if Settings.shared.muteOnSecureInput && SecureInputGuard.isActive { return }
            self.audio.playKeyDown(keyCode: keyCode)
        }
        tap.onKeyUp = { [weak self] keyCode in
            guard let self = self else { return }
            guard Settings.shared.enabled else { return }
            if Settings.shared.muteOnSecureInput && SecureInputGuard.isActive { return }
            self.audio.playKeyUp(keyCode: keyCode)
        }
        tap.start()

        // Global hotkey: ⌘⇧K toggles enabled.
        hotkey.register(keyCode: UInt32(kVK_ANSI_K), modifiers: [.command, .shift]) {
            Settings.shared.enabled.toggle()
        }

        // Apply launch-at-login preference.
        LaunchAtLoginManager.apply(enabled: settings.launchAtLogin)
    }

    func applicationWillTerminate(_ notification: Notification) {
        tap.stop()
        audio.stop()
        hotkey.unregisterAll()
    }
}
