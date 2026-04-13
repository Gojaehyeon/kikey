# Security & Privacy

## What Kikey reads

Kikey installs a `CGEventTap` (Input Monitoring) and observes the **keycode** of every key‑down and key‑up event so it can play a sound. That is *all* it reads.

Specifically, Kikey does **not**:

- record the characters you type
- record modifier combinations as text
- read the focused application's contents
- write any keystroke data to disk
- send any data over the network (the binary makes zero outbound network calls)

When `IsSecureEventInputEnabled()` is true (e.g. you focus a password field, sudo prompt, or the lock screen), Kikey is automatically silent and the event tap still does not see the content of those events.

You can verify all of the above by reading [`Sources/Kikey/KeyEventTap.swift`](Sources/Kikey/KeyEventTap.swift) and [`Sources/Kikey/SecureInputGuard.swift`](Sources/Kikey/SecureInputGuard.swift). The audio path is in [`Sources/Kikey/AudioEngine.swift`](Sources/Kikey/AudioEngine.swift).

## Reporting a vulnerability

If you find a security or privacy issue, please **do not** open a public GitHub issue. Email the maintainer at the address listed on the [maintainer's GitHub profile](https://github.com/Gojaehyeon) with:

- a description of the issue
- steps to reproduce
- the affected version

You'll get a response within a few days. Coordinated disclosure is appreciated.

## Supported versions

Only the latest released version receives security fixes.
