import XCTest
import Quick
import Nimble
import AVFoundation

@testable import SwiftAudio


class AVPlayerObserverTests: QuickSpec, AVPlayerObserverDelegate {
    
    var status: AVPlayerStatus?
    var timeControlStatus: AVPlayerTimeControlStatus?
    
    override func spec() {
        let player = AVPlayer()
        let observer = AVPlayerObserver(player: player)
        observer.delegate = self
        observer.startObserving()
        context("When observing is started") {
            it("should have isObserving set to true", closure: {
                expect(observer.isObserving).to(equal(true))
            })
        }
        
        player.replaceCurrentItem(with: AVPlayerItem(asset: AVURLAsset(url: URL(string: "https://p.scdn.co/mp3-preview/4839b070015ab7d6de9fec1756e1f3096d908fba")!)))
        player.play()
        
        context("Player started playing") {
            it("Should update the delegate", closure: {
                expect(self.status).toEventuallyNot(beNil())
                expect(self.timeControlStatus).toEventuallyNot(beNil())
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
