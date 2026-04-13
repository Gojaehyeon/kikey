import Foundation
import ServiceManagement

enum LaunchAtLoginManager {
    static func apply(enabled: Bool) {
        let service = SMAppService.mainApp
        do {
            if enabled {
                if service.status != .enabled {
                    try service.register()
                }
            } else {
                if service.status == .enabled {
                    try service.unregister()
                }
            }
        } catch {
            NSLog("Kikey: launch-at-login update failed: \(error)")
        }
    }
}
