//  SoundManager.swift
//
//  Copyright (c) 2021-2023 Jonathan Chacón
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import AVFoundation
#if os(macOS)
import AppKit
#endif

public let Sounds: SystemSoundEngine = SystemSoundEngine.shared

#if !os(watchOS)
import AudioToolbox

final public class SystemSoundEngine {
    static public let shared = SystemSoundEngine()
    public var delegate: SoundManagerDelegate? = nil
    private var sounds = [String : SystemSoundID]()
    private var soundMuted : Bool = false
    private var vibrationMuted : Bool = false
    
    public func muteSound(_ value : Bool) {
        soundMuted = value
    }
    
    public func muteVibration(_ value : Bool) {
        guard #unavailable(macOS 10) else {
            print("⚠️📳 vibration is only available for iOS devices")
            return
        }
        vibrationMuted = value
    }
    
    public func vibrate() {
        guard #unavailable(macOS 10) else {
            print("⚠️📳 vibration is only available for iOS devices")
            return
        }
        if !vibrationMuted {
            AudioServicesPlayAlertSound ( SystemSoundID ( kSystemSoundID_Vibrate ))
        }
    }
    
    public func loadSound(_ name: String , fileName : String,
                          fileExtension : String = "") {
        if let soundUrl = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
            var soundId: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
            AudioServicesAddSystemSoundCompletion(soundId, nil, nil, { (soundId, clientData) -> Void in
                if let delegate = SystemSoundEngine.shared.delegate {
                    delegate.didPlaySoundCompleted()
                }
            }, nil)
            sounds[name] = soundId
        } else {
            print("⚠️🎧 Error:\nError loading sound " + name + "\n File does not exist:" + fileName + " extension:" + fileExtension)
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
            print("⚠️🎧 Error:\nError unloading all sound files: \(error)")
        }
    }
    
    public func unloadSound(_ name : String) {
        let soundId: SystemSoundID? = sounds[name]
        if soundId != nil {
            AudioServicesDisposeSystemSoundID(soundId!)
        } else {
            print("⚠️🎧 Error:\nError unloading sound " + name)
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
            if let delegate = SystemSoundEngine.shared.delegate {
                delegate.didPlaySoundStarted(name: "\(name)")
            }
        } else {
            print("⚠️🎧 Error:\nSound not available " + name)
        }
    }
#if os(macOS)
    
    public func playEvent(_ soundEvent: SystemSoundEngine.SoundEvent) {
        if soundMuted {
            return
        }
        var sound = NSSound(named: NSSound.Name(soundEvent.rawValue))
        guard let sound = sound else {
            print("⚠️🎧 Error:\nSound not available " + soundEvent.rawValue)
            return
        }
        sound.play()
    }
#else
    public func playEvent(_ soundEvent: SystemSoundEngine.SoundEvent) {
        if soundMuted {
            return
        }
        AudioServicesAddSystemSoundCompletion(soundEvent.rawValue, nil, nil, { (soundId, clientData) -> Void in
            if let delegate = SystemSoundEngine.shared.delegate {
                delegate.didPlaySoundCompleted()
            }
        }, nil)
        AudioServicesPlaySystemSound(soundEvent.rawValue)
        if let delegate = SystemSoundEngine.shared.delegate {
            delegate.didPlaySoundStarted(name: "\(soundEvent)")
        }
    }
#endif
    
}
#else

final public class SystemSoundEngine {
    static public let shared = SystemSoundEngine()
    public var delegate: SoundManagerDelegate? = nil
    private var sounds = [String : SoundItem]()
    private var soundMuted : Bool = false
    private var vibrationMuted : Bool = false
    
    private init() {
        do {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try? AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️🎧 Error:\(error.localizedDescription)")
        }
    }
    
    public func muteSound(_ value : Bool) {
        soundMuted = value
    }
    
    public func muteVibration(_ value : Bool) {
        print("⚠️📳 vibration is only available for iOS devices")
    }
    
    public func vibrate() {
        print("⚠️📳 vibration is only available for iOS devices")
    }
    
    public func loadSound(_ name: String , fileName : String,
                          fileExtension : String = "") {
        sounds[name] = SoundItem(fileName, fileExtension: fileExtension)
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
            print("⚠️🎧 Error:\nError unloading all sound files: \(error)")
        }
    }
    
    public func unloadSound(_ name : String) {
        sounds[name] = nil
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
        guard let itemSound = sounds[name] else {
            return
        }
        itemSound.play()
    }
}

final class SoundItem {
    private var player: AVAudioPlayer
    
    init!(_ fileName: String,
          fileExtension : String = "") {
        let fileURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
        self.player = try! AVAudioPlayer(contentsOf: fileURL!)
        self.player.prepareToPlay()
    }
    
    func play() {
        self.player.stop()
        self.player.currentTime = 0
        self.player.play()
    }
}
#endif
