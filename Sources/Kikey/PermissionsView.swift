import SwiftUI
import AppKit

struct PermissionsView: View {
    @Binding var hasPermission: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Input Monitoring required", systemImage: "exclamationmark.shield")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.orange)
            Text("Kikey needs permission to observe keystrokes so it can play sounds. It never records what you type.")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Button("Open System Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") {
                        NSWorkspace.shared.open(url)
                    }
                }
                Button("Re-check") {
                    hasPermission = KeyEventTap.hasPermission()
                    if hasPermission {
                        KeyEventTap.shared.start()
                    }
                }
            }
            .font(.caption)
        }
        .padding(8)
        .background(.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}
