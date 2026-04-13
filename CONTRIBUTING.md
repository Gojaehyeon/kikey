# Contributing to Kikey

Thanks for thinking about contributing! 🐱

## Dev setup

```bash
brew install xcodegen
git clone https://github.com/Gojaehyeon/kikey.git
cd kikey
make open       # generates Kikey.xcodeproj and opens it in Xcode
```

The Xcode project is **generated** from `project.yml` — never edit `Kikey.xcodeproj` directly. If you add a Swift file under `Sources/Kikey/`, just run `make project` (or `xcodegen generate`) again.

## Adding a sound pack

1. Create `Sources/Kikey/SoundPacks/MyPack.swift` conforming to `SoundPack`.
2. Synthesize a buffer in `bufferForKeyDown(keyCode:randomizePitch:)` using the helpers in `Synth`.
3. Register it in `SoundPacks/SoundPackRegistry.swift`.
4. `make build && make run` to test.

Built-in packs are entirely procedural (no audio assets) so the binary stays tiny and licensing is clean. If you want sample-based playback, drop `.wav` files into a folder and load them in your `SoundPack` implementation — the protocol doesn't care how the buffer is made.

## Style

- Swift 5.10, SwiftUI / AppKit interop allowed
- No third-party dependencies in the app target
- Keep `AudioEngine` lock-free on the audio render path

## License

By contributing you agree your work is released under the [MIT License](LICENSE).
