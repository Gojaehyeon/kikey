import SwiftUI
import AppKit

@main
struct KikeyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var settings = Settings.shared

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environment(settings)
        } label: {
            // Hide the icon entirely when the user opts out.
            // MenuBarExtra still owns the menu we expose via Settings → reopen.
            if settings.showMenuBarIcon {
                Image(systemName: settings.enabled ? "cat.fill" : "cat")
                    .symbolRenderingMode(.hierarchical)
            } else {
                Image(nsImage: NSImage(size: .zero))
            }
        }
        .menuBarExtraStyle(.window)

        SwiftUI.Settings {
            SettingsView()
                .environment(settings)
        }
    }
}
