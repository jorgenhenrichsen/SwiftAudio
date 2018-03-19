import Quick
import Nimble

@testable import SwiftAudio


class AVPlayerWrapperTests: QuickSpec {


    override func spec() {

        let source = Bundle.main.path(forResource: "WAV-MP3", ofType: "wav")!
        let shortSource = Bundle.main.path(forResource: "nasa_throttle_up", ofType: "mp3")!

        describe("An AVPlayerWrapper") {

            var wrapper: AVPlayerWrapper!

            beforeEach {
                wrapper = AVPlayerWrapper()
                wrapper.automaticallyWaitsToMinimizeStalling = false
                wrapper.volume = 0.0
            }

            describe("its state", {

                context("when doing nothing", {
                    it("should be idle", closure: {
                        expect(wrapper.state).to(equal(AVPlayerWrapperState.idle))
                    })
                })

                context("when loading a source", {
                    beforeEach {
                        try? wrapper.load(fromFilePath: source, playWhenReady: false)
                    }

                    it("should eventually be ready", closure: {
                        expect(wrapper.state).toEventually(equal(AVPlayerWrapperState.ready))
                    })
                })

                context("when playing a source", {
                    beforeEach {
                        try? wrapper.load(fromFilePath: source, playWhenReady: true)
                    }

                    it("should eventually be playing", closure: {
                        expect(wrapper.state).toEventually(equal(AVPlayerWrapperState.playing))
                    })

                })

                context("when pausing the source", {

                    let holder = AudioPlayerDelegateHolder()

                    beforeEach {
                        wrapper.delegate = holder
                        holder.stateUpdate = { (state) in
                            if state == .playing {
                                try? wrapper.pause()
                            }
                        }
                        try? wrapper.load(fromFilePath: source, playWhenReady: true)
                    }

                    it("should eventually be paused", closure: {
                        expect(wrapper.state).toEventually(equal(AVPlayerWrapperState.paused))
                    })

                })

                context("when stopping the source", {

                    var holder: AudioPlayerDelegateHolder!
                    var receivedIdleUpdate: Bool = false

                    beforeEach {
                        holder = AudioPlayerDelegateHolder()
                        wrapper.delegate = holder
                        holder.stateUpdate = { (state) in
                            if state == .playing {
                                wrapper.stop()
                            }
                            if state == .idle {
                                receivedIdleUpdate = true
                            }
                        }
                        try? wrapper.load(fromFilePath: source, playWhenReady: true)
                    }

                    it("should eventually be 'idle'", closure: {
                        expect(receivedIdleUpdate).toEventually(beTrue())
                    })

                })

            })
        }

    }

}

class AudioPlayerDelegateHolder: AVPlayerWrapperDelegate {

    
    
    var state: AVPlayerWrapperState? {
        didSet {
            if let state = state {
                self.stateUpdate?(state)
            }
        }
    }
    
    var stateUpdate: ((_ state: AVPlayerWrapperState) -> Void)?
    var itemDidComplete: (() -> Void)?
    
    func AVWrapper(didChangeState state: AVPlayerWrapperState) {
        self.state = state
    }
    
    func AVWrapperItemDidComplete() {
        
    }
    
    func AVWrapper(secondsElapsed seconds: Double) {
        
    }
    
    func AVWrapper(failedWithError error: Error?) {
        
    }
    
    func AVWrapper(seekTo seconds: Int, didFinish: Bool) {
         
    }
    
}
