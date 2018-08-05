import Quick
import Nimble

@testable import SwiftAudio

class AudioPlayerTests: QuickSpec {
    
    override func spec() {
        describe("An AudioPlayer") {
            var audioPlayer: AudioPlayer!
            
            beforeEach {
                audioPlayer = AudioPlayer()
                audioPlayer.automaticallyWaitsToMinimizeStalling = false
                audioPlayer.bufferDuration = 0.0001
                audioPlayer.volume = 0
            }
            
            describe("its state", {
                
                it("should be idle", closure: {
                    expect(audioPlayer.playerState).to(equal(AudioPlayerState.idle))
                })
                
                context("when audio item is loaded", {
                    beforeEach {
                        try? audioPlayer.loadItem(Source.getAudioItem(), playWhenReady: false)
                    }
                    
                    it("it should eventually be ready", closure: {
                        expect(audioPlayer.playerState).toEventually(equal(AudioPlayerState.ready))
                    })
                })
                
                context("when an item is loaded (playWhenReady=true)", {
                    beforeEach {
                        try? audioPlayer.loadItem(Source.getAudioItem(), playWhenReady: true)
                    }
                    
                    it("it should eventually be playing", closure: {
                        expect(audioPlayer.playerState).toEventually(equal(AudioPlayerState.playing))
                    })
                })
                
                context("when playing an item", {
                    var holder: AudioPlayerDelegateHolder!
                    beforeEach {
                        holder = AudioPlayerDelegateHolder()
                        audioPlayer.delegate = holder
                        holder.stateUpdate = { state in
                            print(state.rawValue)
                            if state == .ready {
                                try? audioPlayer.play()
                            }
                        }
                        try? audioPlayer.loadItem(Source.getAudioItem(), playWhenReady: false)
                    }
                    
                    it("should eventually be playing", closure: {
                        expect(audioPlayer.playerState).toEventually(equal(AudioPlayerState.playing))
                    })
                })
                
                context("when pausing an item", {
                    var holder: AudioPlayerDelegateHolder!
                    beforeEach {
                        holder = AudioPlayerDelegateHolder()
                        audioPlayer.delegate = holder
                        holder.stateUpdate = { (state) in
                            if state == .playing {
                                try? audioPlayer.pause()
                            }
                        }
                        try? audioPlayer.loadItem(Source.getAudioItem(), playWhenReady: true)
                    }
                    
                    it("should eventually be paused", closure: {
                        expect(audioPlayer.playerState).toEventually(equal(AudioPlayerState.paused))
                    })
                })
                
                context("when stopping an item", {
                    var holder: AudioPlayerDelegateHolder!
                    beforeEach {
                        holder = AudioPlayerDelegateHolder()
                        audioPlayer.delegate = holder
                        holder.stateUpdate = { (state) in
                            if state == .playing {
                                audioPlayer.stop()
                            }
                        }
                        try? audioPlayer.loadItem(Source.getAudioItem(), playWhenReady: true)
                    }
                    
                    it("should eventually be idle", closure: {
                        expect(audioPlayer.playerState).toEventually(equal(AudioPlayerState.idle))
                    })
                })
                
            })
        }
    }
    
}

class AudioPlayerDelegateHolder: AudioPlayerDelegate {
    
    var stateUpdate: ((_ state: AudioPlayerState) -> Void)?
    var state: AudioPlayerState? {
        didSet {
            if let state = state {
                stateUpdate?(state)
            }
        }
    }
    
    func audioPlayer(playerDidChangeState state: AudioPlayerState) {
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
    
    func audioPlayer(didUpdateDuration duration: Double) {
        
    }
    
}


