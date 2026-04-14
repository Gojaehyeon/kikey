import Foundation
import CoreGraphics
import AppKit

/// Global key event observer using CGEventTap. Requires Input Monitoring permission.
final class KeyEventTap {
    static let shared = KeyEventTap()

    var onKeyDown: ((UInt16) -> Void)?
    var onKeyUp: ((UInt16) -> Void)?

    private var tap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    private init() {}

    @discardableResult
    func start() -> Bool {
        guard tap == nil else { return true }

        let mask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
        let callback: CGEventTapCallBack = { _, type, event, userInfo in
            guard let userInfo = userInfo else { return Unmanaged.passUnretained(event) }
            let me = Unmanaged<KeyEventTap>.fromOpaque(userInfo).takeUnretainedValue()
            let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
            switch type {
            case .keyDown:
                me.onKeyDown?(keyCode)
            case .keyUp:
                me.onKeyUp?(keyCode)
            case .tapDisabledByTimeout, .tapDisabledByUserInput:
                if let tap = me.tap {
                    CGEvent.tapEnable(tap: tap, enable: true)
                }
            default:
                break
            }
            return Unmanaged.passUnretained(event)
        }

        let info = Unmanaged.passUnretained(self).toOpaque()
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: CGEventMask(mask),
            callback: callback,
            userInfo: info
        ) else {
            return false
        }
        self.tap = tap
        self.runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        NSLog("Kikey[tap]: started successfully")
        return true
    }

    func stop() {
        if let tap = tap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        tap = nil
        runLoopSource = nil
    }

    /// Returns true if the user has granted Input Monitoring access.
    static func hasPermission() -> Bool {
        // Probe by attempting to create a tap; if it fails, permission is missing.
        guard let probe = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
            callback: { _, _, event, _ in Unmanaged.passUnretained(event) },
            userInfo: nil
        ) else {
            return false
        }
        CGEvent.tapEnable(tap: probe, enable: false)
        return true
    }
}
