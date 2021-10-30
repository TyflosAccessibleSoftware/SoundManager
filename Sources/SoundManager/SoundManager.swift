import Foundation
import AudioToolbox
import AVFoundation

public let Sounds: SystemSoundEngine = SystemSoundEngine.shared

final public class SystemSoundEngine {
    static public let shared = SystemSoundEngine()
    private var sounds = [String : SystemSoundID]()
    private var soundMuted : Bool = false
    private var vibrationMuted : Bool = false

    public func muteSound(_ value : Bool) {
        soundMuted = value
    }
    
    public func muteVibration(_ value : Bool) {
        vibrationMuted = value
    }
    
    public func vibrate() {
        if !vibrationMuted {
            AudioServicesPlayAlertSound ( SystemSoundID ( kSystemSoundID_Vibrate ))
        }
    }
    
    public func loadSound(_ name: String , fileName : String, fileExtension : String = "") {
        if let soundUrl = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
            var soundId: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
            AudioServicesAddSystemSoundCompletion(soundId, nil, nil, { (soundId, clientData) -> Void in
                // AudioServicesDisposeSystemSoundID(soundId)
            }, nil)
            sounds[name] = soundId
        } else {
            print("SoundEngine error:\nError loading sound " + name + "\n File does not exist:" + fileName + " extension:" + fileExtension)
        }
    }
    
    public func loadAllSounds(_ withExtension: String) {
        let documentDir = Bundle.main.bundleURL
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentDir, includingPropertiesForKeys: nil)
            let audioFiles = directoryContents.filter{ $0.pathExtension == withExtension }
            let audioFileNames = audioFiles.map{ $0.deletingPathExtension().lastPathComponent }
            for fileName in audioFileNames {
                self.loadSound(fileName, fileName: fileName, fileExtension: withExtension)
            }
        } catch {
            print("SoundEngine error:\nError unloading all sound files: \(error)")
        }
    }
    
    public func unloadSound(_ name : String) {
        let soundId: SystemSoundID? = sounds[name]
        if soundId != nil {
            AudioServicesDisposeSystemSoundID(soundId!)
        } else {
            print("SoundEngine error:\nError unloading sound " + name)
        }
    }
    
    public func unloadAllSounds() {
        for name in sounds.keys {
            self.unloadSound(name)
        }
    }
    
    public func playSound(_ name : String) {
        if soundMuted {
            return
        }
        let soundId: SystemSoundID? = sounds[name]
        if soundId != nil {
            AudioServicesPlaySystemSound(soundId!)
        } else {
            print("SoundEngine error:\nSound not available " + name)
        }
    }
}
