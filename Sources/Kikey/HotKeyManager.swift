import Foundation
import Carbon.HIToolbox
import AppKit

/// Carbon RegisterEventHotKey wrapper for global shortcuts.
final class HotKeyManager {
    static let shared = HotKeyManager()

    struct Modifier: OptionSet {
        let rawValue: UInt32
        static let command = Modifier(rawValue: UInt32(cmdKey))
        static let shift   = Modifier(rawValue: UInt32(shiftKey))
        static let option  = Modifier(rawValue: UInt32(optionKey))
        static let control = Modifier(rawValue: UInt32(controlKey))
    }

    private var hotKeyRefs: [EventHotKeyRef?] = []
    private var handlers: [UInt32: () -> Void] = [:]
    private var nextID: UInt32 = 1
    private var installed = false

    private init() {}

    func register(keyCode: UInt32, modifiers: Modifier, action: @escaping () -> Void) {
        installHandlerIfNeeded()
        let id = nextID
        nextID += 1
        handlers[id] = action

        var hotKeyID = EventHotKeyID(signature: OSType(0x4b494b59 /* "KIKY" */), id: id)
        var ref: EventHotKeyRef?
        let status = RegisterEventHotKey(keyCode, modifiers.rawValue, hotKeyID, GetEventDispatcherTarget(), 0, &ref)
        if status == noErr {
            hotKeyRefs.append(ref)
        } else {
            handlers.removeValue(forKey: id)
        }
    }

    func unregisterAll() {
        for ref in hotKeyRefs {
            if let ref = ref { UnregisterEventHotKey(ref) }
        }
        hotKeyRefs.removeAll()
        handlers.removeAll()
    }

    private func installHandlerIfNeeded() {
        guard !installed else { return }
        installed = true
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let userData = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(GetEventDispatcherTarget(), { _, event, userData in
            guard let event = event, let userData = userData else { return noErr }
            var hkID = EventHotKeyID()
            GetEventParameter(event,
                              EventParamName(kEventParamDirectObject),
                              EventParamType(typeEventHotKeyID),
                              nil,
                              MemoryLayout<EventHotKeyID>.size,
                              nil,
                              &hkID)
            let me = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
            me.handlers[hkID.id]?()
            return noErr
        }, 1, &spec, userData, nil)
    }
}
