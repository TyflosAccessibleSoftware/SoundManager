//  SoundManager.swift
//
//  Copyright (c) 2021 Jonathan Chacón
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
