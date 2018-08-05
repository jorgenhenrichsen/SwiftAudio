import Quick
import Nimble

@testable import SwiftAudio


class AVPlayerWrapperTests: QuickSpec {

    override func spec() {

        describe("An AVPlayerWrapper") {

            var wrapper: AVPlayerWrapper!

            beforeEach {
                wrapper = AVPlayerWrapper()
                wrapper.automaticallyWaitsToMinimizeStalling = false
                wrapper.volume = 0.0
            }

            describe("its state", {
                it("should be idle", closure: {
                    expect(wrapper.state).to(equal(AVPlayerWrapperState.idle))
                })

                context("when loading a source", {
                    beforeEach {
                        try? wrapper.load(fromFilePath: Source.path, playWhenReady: false)
                    }
                    
                    it("should be loading", closure: {
                        expect(wrapper.state).to(equal(AVPlayerWrapperState.loading))
                    })

                    it("should eventually be ready", closure: {
                        expect(wrapper.state).toEventually(equal(AVPlayerWrapperState.ready))
                    })
                })
                
                context("when playing with no source", {
                    beforeEach {
                        try? wrapper.play()
                    }
                    it("should be idle", closure: {
                        expect(wrapper.state).to(equal(AVPlayerWrapperState.idle))
                    })
                })

                context("when playing a source", {
                    beforeEach {
                        try? wrapper.load(fromFilePath: Source.path, playWhenReady: true)
                    }

                    it("should eventually be playing", closure: {
                        expect(wrapper.state).toEventually(equal(AVPlayerWrapperState.playing))
                    })

                })

                context("when pausing the source", {

                    let holder = AVPlayerWrapperDelegateHolder()

                    beforeEach {
                        wrapper.delegate = holder
                        holder.stateUpdate = { (state) in
                            if state == .playing {
                                try? wrapper.pause()
                            }
                        }
                        try? wrapper.load(fromFilePath: Source.path, playWhenReady: true)
                    }

                    it("should eventually be paused", closure: {
                        expect(wrapper.state).toEventually(equal(AVPlayerWrapperState.paused))
                    })
                })
                
                context("when toggling the source from play", {
                    let holder = AVPlayerWrapperDelegateHolder()
                    beforeEach {
                        wrapper.delegate = holder
                        holder.stateUpdate = { (state) in
                            if state == .playing {
                                try? wrapper.togglePlaying()
                            }
                        }
                        try? wrapper.load(fromFilePath: Source.path, playWhenReady: true)
                    }
                    it("should eventually be paused", closure: {
                        expect(wrapper.state).toEventually(equal(AVPlayerWrapperState.paused))
                    })
                })

                context("when stopping the source", {

                    var holder: AVPlayerWrapperDelegateHolder!
                    var receivedIdleUpdate: Bool = false

                    beforeEach {
                        holder = AVPlayerWrapperDelegateHolder()
                        wrapper.delegate = holder
                        holder.stateUpdate = { (state) in
                            if state == .playing {
                                wrapper.stop()
                            }
                            if state == .idle {
                                receivedIdleUpdate = true
                            }
                        }
                        try? wrapper.load(fromFilePath: Source.path, playWhenReady: true)
                    }

                    it("should eventually be 'idle'", closure: {
                        expect(receivedIdleUpdate).toEventually(beTrue())
                    })

                })
                
                context("when seeking before loading", {
                    beforeEach {
                        try? wrapper.seek(to: 10)
                    }
                    it("should be idle", closure: {
                        expect(wrapper.state).to(equal(AVPlayerWrapperState.idle))
                    })
                })
            })
            
            describe("its duration", {
                it("should be 0", closure: {
                    expect(wrapper.duration).to(equal(0))
                })
                
                context("when loading source", {
                    beforeEach {
                        try? wrapper.load(fromFilePath: Source.path, playWhenReady: false)
                    }
                    it("should eventually not be 0", closure: {
                        expect(wrapper.duration).toEventuallyNot(equal(0))
                    })
                })
            })
            
            describe("its current time", {
                it("should be 0", closure: {
                    expect(wrapper.currentTime).to(equal(0))
                })
                
                context("when seeking to a time", {
                    let holder = AVPlayerWrapperDelegateHolder()
                    let seekTime: TimeInterval = 5
                    beforeEach {
                        wrapper.delegate = holder
                        holder.stateUpdate = { (state) in
                            if state == .ready && wrapper.duration != 0 {
                                try? wrapper.seek(to: seekTime)
                            }
                        }
                        try? wrapper.load(fromFilePath: Source.path, playWhenReady: false)
                    }
                    
                    it("should eventually be equal to the seeked time", closure: {
                        expect(wrapper.currentTime).toEventually(equal(seekTime))
                    })
                })
            })
            
        }

    }

}

class AVPlayerWrapperDelegateHolder: AVPlayerWrapperDelegate {

    
    
    var state: AVPlayerWrapperState? {
        didSet {
            print(state)
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
    
    func AVWrapper(didUpdateDuration duration: Double) {
        if let state = self.state {
            self.stateUpdate?(state)

        }
    }
    
}
