import Quick
import Nimble

@testable import SwiftAudio


class AudioPlayerTests: QuickSpec {
    
    
    override func spec() {
        
        let source = Bundle.main.path(forResource: "WAV-MP3", ofType: "wav")!
        let shortSource = Bundle.main.path(forResource: "nasa_throttle_up", ofType: "mp3")!
        
        describe("An AudioPlayer") {
            
            var audioPlayer: AudioPlayer!
            
            beforeEach {
                var config = AudioPlayer.Config()
                config.automaticallyWaitsToMinimizeStalling = false
                config.volume = 0.0
                audioPlayer = AudioPlayer(config: config)
            }
            
            describe("its state", {
                
                context("when doing nothing", {
                    it("should be idle", closure: {
                        expect(audioPlayer.state).to(equal(AudioPlayerState.idle))
                    })
                })
                
                context("when loading a source", {
                    beforeEach {
                        try? audioPlayer.load(fromFilePath: source, playWhenReady: false)
                    }
                    
                    it("should eventually be ready", closure: {
                        expect(audioPlayer.state).toEventually(equal(AudioPlayerState.ready))
                    })
                })
                
                context("when playing a source", {
                    beforeEach {
                        try? audioPlayer.load(fromFilePath: source, playWhenReady: true)
                    }

                    it("should eventually be playing", closure: {
                        expect(audioPlayer.state).toEventually(equal(AudioPlayerState.playing))
                    })

                })

                context("when pausing the source", {

                    let holder = AudioPlayerDelegateHolder()

                    beforeEach {
                        audioPlayer.delegate = holder
                        holder.stateUpdate = { (state) in
                            if state == .playing {
                                try? audioPlayer.pause()
                            }
                        }
                        try? audioPlayer.load(fromFilePath: source, playWhenReady: true)
                    }

                    it("should eventually be paused", closure: {
                        expect(audioPlayer.state).toEventually(equal(AudioPlayerState.paused))
                    })

                })

                context("when stopping the source", {

                    var holder: AudioPlayerDelegateHolder!
                    var receivedIdleUpdate: Bool = false

                    beforeEach {
                        holder = AudioPlayerDelegateHolder()
                        audioPlayer.delegate = holder
                        holder.stateUpdate = { (state) in
                            if state == .playing {
                                audioPlayer.stop()
                            }
                            if state == .idle {
                                receivedIdleUpdate = true
                            }
                        }
                        try? audioPlayer.load(fromFilePath: source, playWhenReady: true)
                    }

                    it("should eventually be 'idle'", closure: {
                        expect(receivedIdleUpdate).toEventually(beTrue())
                    })

                })
                
            })
        }
        
    }
    
}

class AudioPlayerDelegateHolder: AudioPlayerDelegate {
    
    var state: AudioPlayerState? {
        didSet {
            if let state = state {
                self.stateUpdate?(state)
            }
        }
    }
    
    var stateUpdate: ((_ state: AudioPlayerState) -> Void)?
    var itemDidComplete: (() -> Void)?
    
    func audioPlayer(didChangeState state: AudioPlayerState) {
        self.state = state
    }
    
    func audioPlayerItemDidComplete() {
        
    }
    
    func audioPlayer(secondsElapsed seconds: Double) {
        
    }
    
    func audioPlayer(failedWithError error: Error?) {
        
    }
    
    func audioPlayer(seekTo seconds: Int, didFinish: Bool) {
        
    }
    
}
