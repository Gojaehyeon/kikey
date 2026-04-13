# Changelog

All notable changes to Kikey are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] — 2026-04-13

### Added
- Initial release.
- SwiftUI MenuBarExtra app for macOS 14+.
- Five procedurally-synthesized sound packs: Cat 🐱, Mech ⌨️, Typewriter 📝, Pop 🫧, Drop 💧.
- Polyphonic AVAudioEngine playback with 16-voice pool, randomized pitch per keystroke.
- Press / release sound separation.
- Global keystroke capture via `CGEventTap` (Input Monitoring).
- Privacy-aware: silent when `IsSecureEventInputEnabled()` is true.
- Toggleable menu bar icon — control entirely via global hotkey when hidden.
- ⌘⇧K global hotkey to toggle Kikey on/off.
- Settings window (General · Sound · Privacy · About).
- Launch at login via `SMAppService`.
- App icon generated from SF Symbol cat.fill on pastel gradient.
- Packaging script producing `.zip` and `.dmg` artifacts.
- GitHub Actions: build on push/PR, release on tag push.
