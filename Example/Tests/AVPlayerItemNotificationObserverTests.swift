import Quick
import Nimble
import AVFoundation

@testable import SwiftAudio


class AVPlayerItemNotificationObserverTests: QuickSpec {
    
    override func spec() {
        
        describe("A notification observer") {
            
            var item: AVPlayerItem!
            var observer: AVPlayerItemNotificationObserver!
        
            beforeEach {
                item = AVPlayerItem(asset: AVURLAsset(url: URL(string: "https://p.scdn.co/mp3-preview/4839b070015ab7d6de9fec1756e1f3096d908fba")!))
                observer = AVPlayerItemNotificationObserver()
            }
            
            context("when started observing", {
                beforeEach {
                    observer.startObserving(item: item)
                }
                
                it("should have an observed item", closure: {
                    expect(observer.observingItem).toNot(beNil())
                })
                
                context("when ended observing", {
                    
                    beforeEach {
                        observer.stopObservingCurrentItem()
                    }
                    
                    it("should have no observed item", closure: {
                        expect(observer.observingItem).to(beNil())
                    })
                    
                })
            })
            
        }

    }
    
}
