# System Sound Manager

The public manager type in this package is `SystemSoundEngine`.

Use the singleton instance:

```swift
let sounds = SystemSoundEngine.shared
```

The singleton is preserved for compatibility with projects that already use SoundManager 1.6.

## Responsibilities

`SystemSoundEngine` is responsible for:

- Loading sound files by name.
- Playing loaded sounds.
- Playing sounds with volume, speed, panning, and pitch controls.
- Unloading individual sounds or all loaded sounds.
- Reporting the number of loaded sounds.
- Muting sound playback.
- Triggering vibration where supported.
- Playing platform system sound events where supported.
- Notifying a delegate when playback starts or completes.

## Loading

Load from the main bundle:

```swift
SystemSoundEngine.shared.loadSound(
    "beep",
    fileName: "beep",
    fileExtension: "wav"
)
```

Load from a specific bundle:

```swift
SystemSoundEngine.shared.loadSound(
    "beep",
    fileName: "beep",
    fileExtension: "wav",
    in: .main
)
```

Load all matching files:

```swift
SystemSoundEngine.shared.loadAllSounds("wav")
```

## Playback

Default playback:

```swift
SystemSoundEngine.shared.playSound("beep")
```

Controlled playback:

```swift
SystemSoundEngine.shared.playSound(
    "beep",
    volume: 1.0,
    speed: 1.0,
    pan: 0.0,
    pitch: 0.5
)
```

## Playback Parameters

### Volume

`volume` controls playback loudness.

- Minimum: `0.0`
- Maximum: `1.0`
- Default: `1.0`

```swift
SystemSoundEngine.shared.playSound("beep", volume: 0.25)
```

### Speed

`speed` controls playback speed.

- `1.0` is normal speed.
- Values lower than `1.0` play more slowly.
- Values higher than `1.0` play faster.

```swift
SystemSoundEngine.shared.playSound("beep", speed: 1.5)
```

### Pan

`pan` controls horizontal stereo position.

- `-1.0` is full left.
- `0.0` is center.
- `1.0` is full right.
- Default: `0.0`

```swift
SystemSoundEngine.shared.playSound("beep", pan: -0.5)
```

### Pitch

`pitch` controls tone independently from speed.

- `0.0` is the lowest pitch.
- `0.5` is normal pitch.
- `1.0` is the highest pitch.
- Default: `0.5`

```swift
SystemSoundEngine.shared.playSound("beep", pitch: 0.8)
```

Internally, the normalized pitch value is mapped to the pitch range used by `AVAudioUnitTimePitch`.

On watchOS, `pitch` is accepted by the API for source compatibility but ignored during playback because `AVAudioUnitTimePitch` is not available on watchOS.

## Muting

Mute or unmute regular sound playback:

```swift
SystemSoundEngine.shared.muteSound(true)
SystemSoundEngine.shared.muteSound(false)
```

Mute or unmute vibration where vibration is supported:

```swift
SystemSoundEngine.shared.muteVibration(true)
SystemSoundEngine.shared.muteVibration(false)
```

## Loaded Sounds Count

`loadedSoundsCount` returns the current number of sounds loaded in memory:

```swift
let count = SystemSoundEngine.shared.loadedSoundsCount
```

The count is updated when sounds are loaded, replaced, unloaded, or cleared.

## Delegate

Assign a `SoundManagerDelegate` to receive playback callbacks:

```swift
final class SoundDelegate: SoundManagerDelegate {
    func didPlaySoundStarted(name: String) {
        print("Started: \(name)")
    }

    func didPlaySoundCompleted() {
        print("Completed")
    }
}

SystemSoundEngine.shared.delegate = SoundDelegate()
```

The delegate is optional.

## Unloading

Unload one sound:

```swift
SystemSoundEngine.shared.unloadSound("beep")
```

Unload all sounds:

```swift
SystemSoundEngine.shared.unloadAllSounds()
```

## Implementation Notes

Loaded sounds are played with `AVAudioEngine`, `AVAudioPlayerNode`, and `AVAudioUnitTimePitch`. This allows the engine to control speed and pitch independently.

System events and vibration continue to use platform system audio APIs where available.
