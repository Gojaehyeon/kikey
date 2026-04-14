import SwiftUI

struct SettingsView: View {
    @Environment(Settings.self) private var settings

    var body: some View {
        @Bindable var s = settings

        TabView {
            Form {
                Section("General") {
                    Toggle("Enable Kikey", isOn: $s.enabled)
                    Toggle("Show menu bar icon", isOn: $s.showMenuBarIcon)
                    Toggle("Launch at login", isOn: $s.launchAtLogin)
                }
                Section("Sound") {
                    Picker("Pack", selection: $s.soundPackID) {
                        ForEach(SoundPackRegistry.all, id: \.id) { pack in
                            Text(pack.name).tag(pack.id)
                        }
                    }
                    Picker("Volume", selection: $s.volume) {
                        ForEach(VolumeLevel.allCases) { level in
                            Text(level.label).tag(level)
                        }
                    }
                    Toggle("Play key release", isOn: $s.playKeyUp)
                    Toggle("Randomize pitch", isOn: $s.randomizePitch)
                    Toggle("Trackpad haptic", isOn: $s.hapticFeedback)
                }
                Section("Privacy") {
                    Toggle("Mute on secure input", isOn: $s.muteOnSecureInput)
                    Text("Kikey reads only the keycode of each press to play a sound. Nothing is logged or transmitted.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .formStyle(.grouped)
            .tabItem { Label("General", systemImage: "gear") }
            .padding()

            VStack(alignment: .leading, spacing: 10) {
                Text("Kikey \(versionString)")
                    .font(.title2)
                Text("Cute keyboard sound app for Mac.")
                    .foregroundStyle(.secondary)
                Link("github.com/Gojaehyeon/kikey",
                     destination: URL(string: "https://github.com/Gojaehyeon/kikey")!)
                Spacer()
                Text("© 2026 Gojaehyeon · MIT License")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 480, height: 420)
    }

    private var versionString: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}
