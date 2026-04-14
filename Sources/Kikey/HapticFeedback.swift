import AppKit

/// Routes haptic calls through `ForceTouchHaptic` (which drives the private
/// MultitouchSupport actuator API and bypasses capacitive-touch gating).
/// Falls back to `NSHapticFeedbackManager` if the private path is unavailable.
enum HapticFeedback {
    static func bump() {
        ForceTouchHaptic.shared.bump()
    }
}
