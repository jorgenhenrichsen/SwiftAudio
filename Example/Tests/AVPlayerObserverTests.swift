import Quick
import Nimble
import AVFoundation

@testable import SwiftAudio


class AVPlayerObserverTests: QuickSpec, AVPlayerObserverDelegate {
    
    var status: AVPlayerStatus?
    var timeControlStatus: AVPlayerTimeControlStatus?
    
    override func spec() {
        
        describe("A player observer") {
            
            var player: AVPlayer!
            var observer: AVPlayerObserver!
            
            beforeEach {
                player = AVPlayer()
                observer = AVPlayerObserver(player: player)
                observer.delegate = self
            }
            
            context("when observing has started", {
                beforeEach {
                    observer.startObserving()
                }
                
                it("should be observing", closure: {
                    expect(observer.isObserving).toEventually(beTrue())
                })
                
                context("when player has started", {
                    beforeEach {
                        player.replaceCurrentItem(with: AVPlayerItem(asset: AVURLAsset(url: URL(string: "https://p.scdn.co/mp3-preview/4839b070015ab7d6de9fec1756e1f3096d908fba")!)))
                        player.play()
                    }
                    
                    it("it should update the delegate", closure: {
                        expect(self.status).toEventuallyNot(beNil())
                        expect(self.timeControlStatus).toEventuallyNot(beNil())
                    })
                })
                
                context("when observing again", {
                    beforeEach {
                        observer.startObserving()
                    }
                    
                    it("should be observing", closure: {
                        expect(observer.isObserving).toEventually(beTrue())
                    })
                })
            })
            
        }
    }
    
    func player(statusDidChange status: AVPlayerStatus) {
        self.status = status
    }
    
    func player(didChangeTimeControlStatus status: AVPlayerTimeControlStatus) {
        self.timeControlStatus = status
    }
    
}
