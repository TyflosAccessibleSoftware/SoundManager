# SoundManager

SoundManager is a Swift Package Manager library for loading and playing short sounds in Apple platform apps.

The package exposes a single library product:

```swift
.library(
    name: "SoundManager",
    targets: ["SoundManager"]
)
```

## Supported Platforms

The package manifest currently declares support for:

- iOS 12 and later
- watchOS 4 and later
- macOS 10.10 and later
- tvOS 12 and later

## Installation

Add the package dependency to your app with Swift Package Manager, then add the `SoundManager` product to your target.

Import the module where you want to use it:

```swift
import SoundManager
```

## Basic Usage

Use the shared `SystemSoundEngine` instance:

```swift
let sounds = SystemSoundEngine.shared

sounds.loadSound("beep", fileName: "beep", fileExtension: "wav")
sounds.playSound("beep")
```

The `name` parameter is the identifier used by the engine after loading. It does not need to match the file name.

## Loading Sounds

Load a single sound from the main bundle:

```swift
SystemSoundEngine.shared.loadSound(
    "notification",
    fileName: "notification",
    fileExtension: "wav"
)
```

Load a sound from a specific bundle:

```swift
SystemSoundEngine.shared.loadSound(
    "notification",
    fileName: "notification",
    fileExtension: "wav",
    in: .main
)
```

Load every sound with a given extension from a bundle:

```swift
SystemSoundEngine.shared.loadAllSounds("wav")
```

## Playing Sounds

The original API remains available:

```swift
SystemSoundEngine.shared.playSound("notification")
```

You can also control playback parameters:

```swift
SystemSoundEngine.shared.playSound(
    "notification",
    volume: 0.75,
    speed: 1.0,
    pan: 0.0,
    pitch: 0.5
)
```

Parameter ranges:

- `volume`: `0.0...1.0`, where `1.0` is full volume.
- `speed`: playback speed. `1.0` is normal speed.
- `pan`: `-1.0...1.0`, where `-1.0` is left, `0.0` is center, and `1.0` is right.
- `pitch`: `0.0...1.0`, where `0.0` is the lowest pitch, `0.5` is normal pitch, and `1.0` is the highest pitch.

Values outside the supported ranges are clipped internally.

## Loaded Sounds Count

Use `loadedSoundsCount` to inspect how many sounds are currently loaded:

```swift
let count = SystemSoundEngine.shared.loadedSoundsCount
```

## Unloading Sounds

Unload a single sound:

```swift
SystemSoundEngine.shared.unloadSound("notification")
```

Unload all sounds:

```swift
SystemSoundEngine.shared.unloadAllSounds()
```

## System Sound Events

On supported platforms, `SystemSoundEngine` can play predefined system sound events:

```swift
SystemSoundEngine.shared.playEvent(.Tink)
```

System sound event availability differs by platform.

## Vibration

Use vibration on supported devices:

```swift
SystemSoundEngine.shared.vibrate()
```

On platforms where vibration is not available, the engine prints a warning and does nothing.

## Thread Safety and Swift 6

`SystemSoundEngine.shared` is kept as a singleton for compatibility with earlier versions of the package. Internal mutable state is protected with locking, and the type is marked as `@unchecked Sendable` so it can compile with Swift 6 concurrency checks.
