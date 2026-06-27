# Unit Tests

The package includes an XCTest target named `SoundManagerTests`.

Run the test suite with:

```sh
swift test
```

To validate Swift 6 language mode:

```sh
swift test -Xswiftc -swift-version -Xswiftc 6
```

## Test Resources

The tests use real sound files from the package `Resources/` folder:

- `beep.wav`
- `guiro.wav`

The test suite creates a temporary bundle and copies those files into it. This allows tests to call the public bundle-based loading API without requiring the files to live inside the test target itself.

## Test Setup

Each test uses the shared singleton:

```swift
engine = SystemSoundEngine.shared
```

Before every test:

- The delegate is cleared.
- Sound playback is muted by default.
- All loaded sounds are unloaded.

After every test:

- All loaded sounds are unloaded again.
- Sound playback is unmuted.
- The delegate is cleared.

This keeps the singleton state predictable between tests.

## Coverage

The tests cover:

- Loading a single sound.
- Loading a sound by file name with extension.
- Replacing an already loaded sound with the same name.
- Loading all sounds with a given extension.
- Unloading one sound.
- Unloading all sounds.
- Ensuring a missing sound does not increase `loadedSoundsCount`.
- Playing `beep.wav`.
- Playing `guiro.wav`.
- Playing with panning changes.
- Playing with speed changes.
- Playing with pitch changes.
- Playing with volume changes.

## Playback Tests

### Beep Playback

The `beep.wav` playback test loads `beep`, unmutes playback, plays the sound, and verifies through `SoundManagerDelegate` that playback started with the expected sound name.

### Guiro Playback

The `guiro.wav` playback test loads `guiro`, waits briefly, plays the sound, waits again, and verifies that the delegate received the expected started sound name.

### Panning

The panning test plays `beep.wav` while moving from full left to full right:

- Starts at `-1.0`
- Ends at `1.0`
- Uses increments of `0.1`
- Waits `0.1` seconds between playback calls

### Speed

The speed test plays a sound while moving playback speed from `0.0` to `2.0`:

- Starts at `0.0`
- Ends at `2.0`
- Uses increments of `0.1`
- Waits between playback calls

The engine clips speed internally to the supported playback range.

### Pitch

The pitch test plays `beep.wav` from the lowest to the highest normalized pitch:

- Starts at `0.0`
- Ends at `1.0`
- Uses increments of `0.1`
- Waits `0.2` seconds between playback calls

The normal pitch value is `0.5`.

### Volume

The volume test plays `guiro.wav` several times with increasing volume values and waits between playback calls.

## Notes

These tests exercise real audio-loading and playback paths. They are intentionally slower than pure unit tests because several cases include short sleeps to make playback behavior observable and reproducible.
