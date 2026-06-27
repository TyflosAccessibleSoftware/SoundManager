# SoundManager

A simple framework to load and play sounds in your app.

## Supported platforms

This framework is compatible with iOS, ipadOS, TvOS, Vision OS, WatchOS and MacOS..

## Usage

* Import the module in your source file
* Load a sound once
* Play the sound as many times as you want without loading the file again

You can use the alias **Sounds** to manage the library.

### Sample code

`import SoundManager

// create an alias to easy access
let Sounds = SystemSoundEngine.shared

// Load the sound file once
Sounds.loadSound("My sound", fileName: "mySampleSound.wav")
// And play it
Sounds.playSound("My sound")
// vibrate your device
Sounds.vibrate()`

## Documentation

The documentation for tthis package is available in the **Documentation** folder.

There are 3 documents:

- The general information for this package is in [SoundManager.md](Documentation/SoundManager.md)
- The information for the main class of this package is in [SystemSoundManager.md](Documentation/SystemSoundManager.md)
- The information about the unit tests for this package is in [UnitTests.md](Documentation/UnitTests.md)

## Author

This package was developed by Jonathan Chacón .

Please, if you have any question or suggestion you can contact me at [Tyflos Accessible Software](https://www.tyflosaccessiblesoftware.com) web site.

## Contributing

Pull requests are welcome. Feel free to create pull requests for any kind of improvements, bug fixes or enhancements. For major changes, please open an issue first to discuss what you would like to change.

## License

This software was published under the [MIT license](https://choosealicense.com/licenses/mit/)
