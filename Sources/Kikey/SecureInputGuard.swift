import Foundation
import Carbon.HIToolbox

enum SecureInputGuard {
    /// True when a secure input field (password, sudo, lock screen) is focused.
    /// While true, Kikey stays silent — playing keystroke audio in those contexts
    /// would be both creepy and a privacy smell.
    static var isActive: Bool {
        IsSecureEventInputEnabled()
    }
}
