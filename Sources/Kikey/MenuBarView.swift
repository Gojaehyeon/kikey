import SwiftUI
import AppKit

struct MenuBarView: View {
    @Environment(Settings.self) private var settings
    @State private var hasInputPermission: Bool = KeyEventTap.hasPermission()

    var body: some View {
        @Bindable var s = settings

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("🐱  Kikey")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $s.enabled)
                    .labelsHidden()
                    .toggleStyle(.switch)
            }

            if !hasInputPermission {
                PermissionsView(hasPermission: $hasInputPermission)
            }

            Divider()

            Text("Sound Pack")
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(SoundPackRegistry.all, id: \.id) { pack in
                Button {
                    s.soundPackID = pack.id
                } label: {
                    HStack {
                        Text(pack.icon)
                        Text(pack.name.replacingOccurrences(of: " " + pack.icon, with: ""))
                        Spacer()
                        if s.soundPackID == pack.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            Divider()

            Text("Volume")
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker("Volume", selection: $s.volume) {
                ForEach(VolumeLevel.allCases) { level in
                    Text(level.label).tag(level)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            Divider()

            Toggle("Show menu bar icon", isOn: $s.showMenuBarIcon)
            Toggle("Mute on secure input", isOn: $s.muteOnSecureInput)
            Toggle("Play key release", isOn: $s.playKeyUp)
            Toggle("Randomize pitch", isOn: $s.randomizePitch)
            Toggle("Launch at login", isOn: $s.launchAtLogin)

            Divider()

            HStack {
                Button("Settings…") {
                    NSApp.activate(ignoringOtherApps: true)
                    if #available(macOS 14, *) {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    } else {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    }
                }
                Spacer()
                Button("Quit") {
                    NSApp.terminate(nil)
                }
            }
            .font(.caption)
        }
        .padding(14)
        .frame(width: 280)
        .onAppear {
            hasInputPermission = KeyEventTap.hasPermission()
        }
    }
}
