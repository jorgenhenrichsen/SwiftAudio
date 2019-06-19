import Quick
import Nimble
import AVFoundation
import XCTest

@testable import SwiftAudio

class AudioPlayerTests: XCTestCase {
    
    var audioPlayer: AudioPlayer!
    var listener: AudioPlayerEventListener!
    
    override func setUp() {
        super.setUp()
        audioPlayer = AudioPlayer()
        audioPlayer.volume = 0.0
        audioPlayer.bufferDuration = 0.001
        audioPlayer.automaticallyWaitsToMinimizeStalling = false
        listener = AudioPlayerEventListener(audioPlayer: audioPlayer)
    }
    
    override func tearDown() {
        audioPlayer = nil
        listener = nil
        super.tearDown()
    }
    
    func test_AudioPlayer__state__should_be_idle() {
        XCTAssert(audioPlayer.playerState == AudioPlayerState.idle)
    }
    
    func test_AudioPlayer__state__load_source__should_be_ready() {
        let expectation = XCTestExpectation()
        listener.stateUpdate = { state in
            switch state {
            case .ready: expectation.fulfill()
            default: break
            }
        }
        try? audioPlayer.load(item: Source.getAudioItem(), playWhenReady: false)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func test_AudioPlayer__state__load_source_playWhenReady__should_be_playing() {
        let expectation = XCTestExpectation()
        listener.stateUpdate = { state in
            switch state {
            case .playing: expectation.fulfill()
            default: break
            }
        }
        try? audioPlayer.load(item: Source.getAudioItem(), playWhenReady: true)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func test_AudioPlayer__state__play_source__should_be_playing() {
        let expectation = XCTestExpectation()
        listener.stateUpdate = { state in
            switch state {
            case .ready: self.audioPlayer.play()
            case .playing: expectation.fulfill()
            default: break
            }
        }
        try? audioPlayer.load(item: Source.getAudioItem(), playWhenReady: false)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func test_AudioPlayer__state__pausing_source__should_be_paused() {
        let expectation = XCTestExpectation()
        listener.stateUpdate = { state in
            switch state {
            case .playing: self.audioPlayer.pause()
            case .paused: expectation.fulfill()
            default: break
            }
        }
        try? audioPlayer.load(item: Source.getAudioItem(), playWhenReady: true)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func test_AudioPlayer__state__stopping_source__should_be_idle() {
        let expectation = XCTestExpectation()
        var hasBeenPlaying: Bool = false
        listener.stateUpdate = { state in
            switch state {
            case .playing:
                hasBeenPlaying = true
                self.audioPlayer.stop()
            case .idle:
                if hasBeenPlaying {
                    expectation.fulfill()
                }
            default: break
            }
        }
        try? audioPlayer.load(item: Source.getAudioItem(), playWhenReady: true)
        wait(for: [expectation], timeout: 20.0)
    }
    
    // MARK: - Current time
    
    func test_AudioPlayer__currentTime__should_be_0() {
        XCTAssert(audioPlayer.currentTime == 0.0)
    }
    
// Commented out -- Keeps failing in CI at Bitrise, but succeeds locally, even with Bitrise CLI.
//    func test_AudioPlayer__currentTime__playing_source__shold_be_greater_than_0() {
//        let expectation = XCTestExpectation()
//        audioPlayer.timeEventFrequency = .everyQuarterSecond
//        listener.secondsElapse = { _ in
//            if self.audioPlayer.currentTime > 0.0 {
//                expectation.fulfill()
//            }
//        }
//        try? audioPlayer.load(item: LongSource.getAudioItem(), playWhenReady: true)
//        wait(for: [expectation], timeout: 20.0)
//    }
    
    func test_AudioPlayer__currentTime__when_loading_source_with_intial_time__should_be_equal_to_initial_time() {
        let expectation = XCTestExpectation()
        let item = DefaultAudioItemInitialTime(audioUrl: LongSource.path, artist: nil, title: nil, albumTitle: nil, sourceType: .file, artwork: nil, initialTime: 4.0)
        listener.stateUpdate = { state in
            switch state {
            case .ready:
                if self.audioPlayer.currentTime == item.getInitialTime() {
                    expectation.fulfill()
                }
            default: break
            }
        }
        try? audioPlayer.load(item: item, playWhenReady: false)
        wait(for: [expectation], timeout: 20.0)
    }
    
    // MARK: - Rate
    
    func test_AudioPlayer__rate__should_be_0() {
        XCTAssert(audioPlayer.rate == 0.0)
    }
    
    func test_AudioPlayer__rate__playing_source__should_be_1() {
        let expectation = XCTestExpectation()
        listener.stateUpdate = { state in
            switch state {
            case .playing:
                if self.audioPlayer.rate == 1.0 {
                    expectation.fulfill()
                }
            default: break
            }
        }
        try? audioPlayer.load(item: Source.getAudioItem(), playWhenReady: true)
        wait(for: [expectation], timeout: 20.0)
    }
    
    // MARK: - Current item
    
    func test_AudioPlayer__currentItem__should_be_nil() {
        XCTAssertNil(audioPlayer.currentItem)
    }
    
    func test_AudioPlayer__currentItem__loading_source__should_not_be_nil() {
        let expectation = XCTestExpectation()
        listener.stateUpdate = { state in
            switch state {
            case .ready:
                if self.audioPlayer.currentItem != nil {
                    expectation.fulfill()
                }
            default: break
            }
        }
        try? audioPlayer.load(item: Source.getAudioItem(), playWhenReady: false)
        wait(for: [expectation], timeout: 20.0)
    }
    
}

class AudioPlayerEventListener {
    
    var state: AudioPlayerState? {
        didSet {
            if let state = state {
                stateUpdate?(state)
            }
        }
    }
    
    var stateUpdate: ((_ state: AudioPlayerState) -> Void)?
    var secondsElapse: ((_ seconds: TimeInterval) -> Void)?
    var seekCompletion: (() -> Void)?
    
    init(audioPlayer: AudioPlayer) {
        audioPlayer.event.stateChange.addListener(self, handleDidUpdateState)
        audioPlayer.event.seek.addListener(self, handleSeek)
        audioPlayer.event.secondElapse.addListener(self, handleSecondsElapse)
    }
    
    func handleDidUpdateState(state: AudioPlayerState) {
        self.state = state
    }
    
    func handleSeek(data: AudioPlayer.SeekEventData) {
        seekCompletion?()
    }
    
    func handleSecondsElapse(data: AudioPlayer.SecondElapseEventData) {
        self.secondsElapse?(data)
    }
    
}
