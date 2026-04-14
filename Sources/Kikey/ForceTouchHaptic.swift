import Foundation
import AppKit

/// Direct access to the MacBook Force Touch trackpad actuator via the private
/// MultitouchSupport framework.
///
/// Why this exists: `NSHapticFeedbackManager` gates haptic output on capacitive
/// touch detection, so with both hands on the keyboard you feel nothing. The
/// `MTActuator*` functions below talk to the trackpad firmware directly and
/// bypass that gate — the actuator fires regardless of whether a finger is on
/// the glass. This lets Kikey produce a real mechanical "bump" per keystroke.
///
/// Caveats:
/// - Uses private symbols resolved at runtime via dlopen/dlsym, so it will
///   not prevent the app from launching on macOS versions where the framework
///   has been reorganized — it just silently falls back to NSHapticFeedbackManager.
/// - Cannot be shipped through the Mac App Store (private API usage).
/// - Only works on MacBooks with a Force Touch trackpad (2015+).
final class ForceTouchHaptic {
    static let shared = ForceTouchHaptic()

    // MARK: - Private API function signatures

    private typealias MTDeviceCreateListFn = @convention(c) () -> Unmanaged<CFArray>?
    private typealias MTDeviceGetDeviceIDFn = @convention(c) (UnsafeMutableRawPointer, UnsafeMutablePointer<UInt64>) -> Int32
    private typealias MTActuatorCreateFromDeviceIDFn = @convention(c) (UInt64) -> UnsafeMutableRawPointer?
    private typealias MTActuatorOpenFn = @convention(c) (UnsafeMutableRawPointer) -> Int32
    private typealias MTActuatorCloseFn = @convention(c) (UnsafeMutableRawPointer) -> Int32
    private typealias MTActuatorActuateFn = @convention(c) (UnsafeMutableRawPointer, Int32, UInt32, Float, Float) -> Int32

    // MARK: - State

    private let actuator: UnsafeMutableRawPointer?
    private let actuate: MTActuatorActuateFn?

    var isAvailable: Bool { actuator != nil && actuate != nil }

    // MARK: - Init

    private init() {
        let frameworkPath = "/System/Library/PrivateFrameworks/MultitouchSupport.framework/MultitouchSupport"
        guard let handle = dlopen(frameworkPath, RTLD_NOW) else {
            NSLog("Kikey[haptic]: MultitouchSupport not loadable — falling back to NSHapticFeedbackManager")
            self.actuator = nil
            self.actuate = nil
            return
        }

        func sym(_ name: String) -> UnsafeMutableRawPointer? { dlsym(handle, name) }

        guard
            let createListPtr = sym("MTDeviceCreateList"),
            let getDeviceIDPtr = sym("MTDeviceGetDeviceID"),
            let createActPtr  = sym("MTActuatorCreateFromDeviceID"),
            let openActPtr    = sym("MTActuatorOpen"),
            let actuatePtr    = sym("MTActuatorActuate")
        else {
            NSLog("Kikey[haptic]: private symbols missing — falling back")
            self.actuator = nil
            self.actuate = nil
            return
        }

        let createList  = unsafeBitCast(createListPtr,  to: MTDeviceCreateListFn.self)
        let getDeviceID = unsafeBitCast(getDeviceIDPtr, to: MTDeviceGetDeviceIDFn.self)
        let createAct   = unsafeBitCast(createActPtr,   to: MTActuatorCreateFromDeviceIDFn.self)
        let openAct     = unsafeBitCast(openActPtr,     to: MTActuatorOpenFn.self)
        self.actuate    = unsafeBitCast(actuatePtr,     to: MTActuatorActuateFn.self)

        guard let devices = createList()?.takeRetainedValue(),
              CFArrayGetCount(devices) > 0,
              let deviceRawPtr = CFArrayGetValueAtIndex(devices, 0)
        else {
            NSLog("Kikey[haptic]: no multitouch devices found")
            self.actuator = nil
            return
        }

        let devicePtr = UnsafeMutableRawPointer(mutating: deviceRawPtr)
        var deviceID: UInt64 = 0
        _ = getDeviceID(devicePtr, &deviceID)

        guard let act = createAct(deviceID) else {
            NSLog("Kikey[haptic]: MTActuatorCreateFromDeviceID failed for id=\(deviceID)")
            self.actuator = nil
            return
        }
        _ = openAct(act)
        self.actuator = act
        NSLog("Kikey[haptic]: Force Touch actuator opened (deviceID=\(deviceID))")
    }

    // MARK: - API

    /// Fire a strong haptic pulse through the trackpad actuator. Falls back to
    /// `NSHapticFeedbackManager` if the private path is unavailable.
    func bump() {
        guard let actuator = actuator, let actuate = actuate else {
            NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .now)
            return
        }
        // Actuation ID 6 is the strongest of the commonly-used patterns on
        // Force Touch trackpads. The trailing Float pair is amplitude-ish —
        // 2.0 is the empirical max.
        _ = actuate(actuator, 6, 0, 0.0, 2.0)
    }
}
