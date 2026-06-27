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

#if !os(watchOS)
import AudioToolbox

final public class SystemSoundEngine: @unchecked Sendable {
    static public let shared = SystemSoundEngine()
    private let lock = NSRecursiveLock()
    private var currentDelegate: SoundManagerDelegate? = nil
    private var sounds = [String : SystemSoundID]()
    private var soundMuted : Bool = false
    private var vibrationMuted : Bool = false
    
    public var delegate: SoundManagerDelegate? {
        get {
            withLock {
                currentDelegate
            }
        }
        set {
            withLock {
                currentDelegate = newValue
            }
        }
    }
    
    public var loadedSoundsCount: Int {
        withLock {
            sounds.count
        }
    }
    
    public func muteSound(_ value : Bool) {
        withLock {
            soundMuted = value
        }
    }
    
    public func muteVibration(_ value : Bool) {
        guard #unavailable(macOS 10) else {
            print("⚠️📳 vibration is only available for iOS devices")
            return
        }
        withLock {
            vibrationMuted = value
        }
    }
    
    public func vibrate() {
        guard #unavailable(macOS 10) else {
            print("⚠️📳 vibration is only available for iOS devices")
            return
        }
        let shouldVibrate = withLock {
            !vibrationMuted
        }
        if shouldVibrate {
            AudioServicesPlayAlertSound ( SystemSoundID ( kSystemSoundID_Vibrate ))
        }
    }
    
    public func loadSound(_ name: String , fileName : String,
                          fileExtension : String = "") {
        loadSound(name, fileName: fileName, fileExtension: fileExtension, in: .main)
    }
    
    public func loadSound(_ name: String , fileName : String,
                          fileExtension : String = "", in bundle: Bundle) {
        if let soundUrl = soundURL(fileName: fileName, fileExtension: fileExtension, in: bundle) {
            var soundId: SystemSoundID = 0
            let status = AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
            guard status == noErr else {
                print("⚠️🎧 Error:\nError loading sound " + name + "\n File is not a valid system sound:" + soundUrl.path)
                return
            }
            AudioServicesAddSystemSoundCompletion(soundId, nil, nil, { (soundId, clientData) -> Void in
                if let delegate = SystemSoundEngine.shared.delegate {
                    delegate.didPlaySoundCompleted()
                }
            }, nil)
            let previousSoundId = withLock { () -> SystemSoundID? in
                let previousSoundId = sounds[name]
                sounds[name] = soundId
                return previousSoundId
            }
            if let previousSoundId = previousSoundId {
                AudioServicesDisposeSystemSoundID(previousSoundId)
            }
        } else {
            print("⚠️🎧 Error:\nError loading sound " + name + "\n File does not exist:" + fileName + " extension:" + fileExtension)
        }
    }
    
    public func loadAllSounds(_ withExtension: String) {
        loadAllSounds(withExtension, in: .main)
    }
    
    public func loadAllSounds(_ withExtension: String, in bundle: Bundle) {
        let documentDir = bundle.resourceURL ?? bundle.bundleURL
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentDir, includingPropertiesForKeys: nil)
            let audioFiles = directoryContents.filter{ $0.pathExtension == withExtension }
            let audioFileNames = audioFiles.map{ $0.deletingPathExtension().lastPathComponent }
            for fileName in audioFileNames {
                self.loadSound(fileName, fileName: fileName, fileExtension: withExtension, in: bundle)
            }
        } catch {
            print("⚠️🎧 Error:\nError unloading all sound files: \(error)")
        }
    }
    
    public func unloadSound(_ name : String) {
        let soundId = withLock {
            sounds.removeValue(forKey: name)
        }
        if let soundId = soundId {
            AudioServicesDisposeSystemSoundID(soundId)
        } else {
            print("⚠️🎧 Error:\nError unloading sound " + name)
        }
    }
    
    public func unloadAllSounds() {
        let soundIds = withLock { () -> [SystemSoundID] in
            let soundIds = Array(sounds.values)
            sounds.removeAll()
            return soundIds
        }
        for soundId in soundIds {
            AudioServicesDisposeSystemSoundID(soundId)
        }
    }
    
    public func playSound(_ name : String) {
        let soundId = withLock {
            soundMuted ? nil : sounds[name]
        }
        guard let soundId = soundId else {
            if !withLock({ soundMuted }) {
                print("⚠️🎧 Error:\nSound not available " + name)
            }
            return
        }
        AudioServicesPlaySystemSound(soundId)
        if let delegate = SystemSoundEngine.shared.delegate {
            delegate.didPlaySoundStarted(name: "\(name)")
        }
    }
#if os(macOS)
    
    public func playEvent(_ soundEvent: SystemSoundEngine.SoundEvent) {
        if withLock({ soundMuted }) {
            return
        }
        let sound = NSSound(named: NSSound.Name(soundEvent.rawValue))
        guard let sound = sound else {
            print("⚠️🎧 Error:\nSound not available " + soundEvent.rawValue)
            return
        }
        sound.play()
    }
#else
    public func playEvent(_ soundEvent: SystemSoundEngine.SoundEvent) {
        if withLock({ soundMuted }) {
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
    
    private func soundURL(fileName: String, fileExtension: String, in bundle: Bundle) -> URL? {
        let fileExtension = fileExtension.isEmpty ? nil : fileExtension
        return bundle.url(forResource: fileName, withExtension: fileExtension)
    }
    
    private func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock.lock()
        defer {
            lock.unlock()
        }
        return try body()
    }
}
#else

final public class SystemSoundEngine: @unchecked Sendable {
    static public let shared = SystemSoundEngine()
    private let lock = NSRecursiveLock()
    private var currentDelegate: SoundManagerDelegate? = nil
    private var sounds = [String : SoundItem]()
    private var soundMuted : Bool = false
    private var vibrationMuted : Bool = false
    
    public var delegate: SoundManagerDelegate? {
        get {
            withLock {
                currentDelegate
            }
        }
        set {
            withLock {
                currentDelegate = newValue
            }
        }
    }
    
    public var loadedSoundsCount: Int {
        withLock {
            sounds.count
        }
    }
    
    private init() {
        do {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try? AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️🎧 Error:\(error.localizedDescription)")
        }
    }
    
    public func muteSound(_ value : Bool) {
        withLock {
            soundMuted = value
        }
    }
    
    public func muteVibration(_ value : Bool) {
        print("⚠️📳 vibration is only available for iOS devices")
    }
    
    public func vibrate() {
        print("⚠️📳 vibration is only available for iOS devices")
    }
    
    public func loadSound(_ name: String , fileName : String,
                          fileExtension : String = "") {
        loadSound(name, fileName: fileName, fileExtension: fileExtension, in: .main)
    }
    
    public func loadSound(_ name: String , fileName : String,
                          fileExtension : String = "", in bundle: Bundle) {
        guard let soundItem = SoundItem(fileName, fileExtension: fileExtension, in: bundle) else {
            print("⚠️🎧 Error:\nError loading sound " + name + "\n File does not exist:" + fileName + " extension:" + fileExtension)
            return
        }
        withLock {
            sounds[name] = soundItem
        }
    }
    
    public func loadAllSounds(_ withExtension: String) {
        loadAllSounds(withExtension, in: .main)
    }
    
    public func loadAllSounds(_ withExtension: String, in bundle: Bundle) {
        let documentDir = bundle.resourceURL ?? bundle.bundleURL
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentDir, includingPropertiesForKeys: nil)
            let audioFiles = directoryContents.filter{ $0.pathExtension == withExtension }
            let audioFileNames = audioFiles.map{ $0.deletingPathExtension().lastPathComponent }
            for fileName in audioFileNames {
                self.loadSound(fileName, fileName: fileName, fileExtension: withExtension, in: bundle)
            }
        } catch {
            print("⚠️🎧 Error:\nError unloading all sound files: \(error)")
        }
    }
    
    public func unloadSound(_ name : String) {
        withLock {
            sounds[name] = nil
        }
    }
    
    public func unloadAllSounds() {
        withLock {
            sounds.removeAll()
        }
    }
    
    public func playSound(_ name : String) {
        let itemSound = withLock {
            soundMuted ? nil : sounds[name]
        }
        guard let itemSound = itemSound else {
            return
        }
        itemSound.play()
    }
    
    private func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock.lock()
        defer {
            lock.unlock()
        }
        return try body()
    }
}

final class SoundItem: @unchecked Sendable {
    private var player: AVAudioPlayer
    
    init!(_ fileName: String,
          fileExtension : String = "", in bundle: Bundle = .main) {
        let fileExtension = fileExtension.isEmpty ? nil : fileExtension
        guard let fileURL = bundle.url(forResource: fileName, withExtension: fileExtension),
              let player = try? AVAudioPlayer(contentsOf: fileURL) else {
            return nil
        }
        self.player = player
        self.player.prepareToPlay()
    }
    
    func play() {
        self.player.stop()
        self.player.currentTime = 0
        self.player.play()
    }
}
#endif
