import XCTest
@testable import SoundManager

final class SystemSoundEngineTests: XCTestCase {
    private var engine: SystemSoundEngine!
    private var soundBundle: Bundle {
        Self.soundBundle
    }
    
    private static let soundBundle: Bundle = {
        let fileURL = URL(fileURLWithPath: #filePath)
        let packageURL = fileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let resourcesURL = packageURL.appendingPathComponent("Resources", isDirectory: true)
        let bundleURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("SoundManagerTests.bundle", isDirectory: true)
        let bundleResourcesURL = bundleURL
            .appendingPathComponent("Contents", isDirectory: true)
            .appendingPathComponent("Resources", isDirectory: true)
        let infoPlistURL = bundleURL
            .appendingPathComponent("Contents", isDirectory: true)
            .appendingPathComponent("Info.plist")
        let infoPlist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>CFBundleIdentifier</key>
            <string>com.tyflosaccessible.SoundManagerTests</string>
            <key>CFBundleName</key>
            <string>SoundManagerTests</string>
            <key>CFBundlePackageType</key>
            <string>BNDL</string>
        </dict>
        </plist>
        """
        
        do {
            try? FileManager.default.removeItem(at: bundleURL)
            try FileManager.default.createDirectory(at: bundleResourcesURL, withIntermediateDirectories: true)
            try infoPlist.write(to: infoPlistURL, atomically: true, encoding: .utf8)
            try FileManager.default.copyItem(
                at: resourcesURL.appendingPathComponent("beep.wav"),
                to: bundleResourcesURL.appendingPathComponent("beep.wav")
            )
            try FileManager.default.copyItem(
                at: resourcesURL.appendingPathComponent("guiro.wav"),
                to: bundleResourcesURL.appendingPathComponent("guiro.wav")
            )
        } catch {
            XCTFail("Could not create sound test bundle: \(error)")
        }
        
        guard let bundle = Bundle(url: bundleURL) else {
            XCTFail("Could not load sound test bundle")
            return .main
        }
        return bundle
    }()
    
    override func setUp() {
        super.setUp()
        engine = SystemSoundEngine.shared
        engine.delegate = nil
        engine.muteSound(true)
        engine.unloadAllSounds()
    }
    
    override func tearDown() {
        engine.unloadAllSounds()
        engine.muteSound(false)
        engine.delegate = nil
        engine = nil
        super.tearDown()
    }
    
    func testLoadSoundIncreasesLoadedSoundsCount() {
        engine.loadSound("beep", fileName: "beep", fileExtension: "wav", in: soundBundle)
        
        XCTAssertEqual(engine.loadedSoundsCount, 1)
    }
    
    func testLoadSoundWithFileNameContainingExtension() {
        engine.loadSound("beep", fileName: "beep.wav", in: soundBundle)
        
        XCTAssertEqual(engine.loadedSoundsCount, 1)
    }
    
    func testLoadingSameSoundNameReplacesExistingSound() {
        engine.loadSound("effect", fileName: "beep", fileExtension: "wav", in: soundBundle)
        engine.loadSound("effect", fileName: "guiro", fileExtension: "wav", in: soundBundle)
        
        XCTAssertEqual(engine.loadedSoundsCount, 1)
    }
    
    func testLoadAllSoundsLoadsBundledResources() {
        engine.loadAllSounds("wav", in: soundBundle)
        
        XCTAssertEqual(engine.loadedSoundsCount, 2)
    }
    
    func testUnloadSoundDecreasesLoadedSoundsCount() {
        engine.loadSound("beep", fileName: "beep", fileExtension: "wav", in: soundBundle)
        engine.loadSound("guiro", fileName: "guiro", fileExtension: "wav", in: soundBundle)
        
        engine.unloadSound("beep")
        
        XCTAssertEqual(engine.loadedSoundsCount, 1)
    }
    
    func testUnloadAllSoundsClearsLoadedSoundsCount() {
        engine.loadAllSounds("wav", in: soundBundle)
        
        engine.unloadAllSounds()
        
        XCTAssertEqual(engine.loadedSoundsCount, 0)
    }
    
    func testMissingSoundDoesNotIncreaseLoadedSoundsCount() {
        engine.loadSound("missing", fileName: "missing", fileExtension: "wav", in: soundBundle)
        
        XCTAssertEqual(engine.loadedSoundsCount, 0)
    }
    
    func testPlayBeepSound() {
        let playbackStarted = expectation(description: "Beep sound started playback")
        let delegate = SoundPlaybackDelegate(expectation: playbackStarted)
        engine.delegate = delegate
        engine.loadSound("beep", fileName: "beep", fileExtension: "wav", in: soundBundle)
        engine.muteSound(false)
        
        Thread.sleep(forTimeInterval: 0.5)
        engine.playSound("beep")
        
        wait(for: [playbackStarted], timeout: 1)
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertEqual(delegate.startedSoundName, "beep")
    }
    
    func testPlayGuiroSound() {
        let playbackStarted = expectation(description: "Guiro sound started playback")
        let delegate = SoundPlaybackDelegate(expectation: playbackStarted)
        engine.delegate = delegate
        engine.loadSound("guiro", fileName: "guiro", fileExtension: "wav", in: soundBundle)
        engine.muteSound(false)
        
        Thread.sleep(forTimeInterval: 0.5)
        engine.playSound("guiro")
        
        wait(for: [playbackStarted], timeout: 1)
        Thread.sleep(forTimeInterval: 1.0)
        XCTAssertEqual(delegate.startedSoundName, "guiro")
    }
}

private final class SoundPlaybackDelegate: SoundManagerDelegate {
    private let expectation: XCTestExpectation
    private(set) var startedSoundName: String?
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    func didPlaySoundStarted(name: String) {
        startedSoundName = name
        expectation.fulfill()
    }
    
    func didPlaySoundCompleted() {}
}
