import Quick
import Nimble
import AVFoundation

@testable import SwiftAudio

let source = Bundle.main.path(forResource: "WAV-MP3", ofType: "wav")!

class AVPlayerItemObserverTests: QuickSpec {
    
    override func spec() {
        
        describe("An AVPlayerItemObserver") {
            var observer: AVPlayerItemObserver!
            beforeEach {
                observer = AVPlayerItemObserver()
            }
            describe("observed item", {
                context("when observing", {
                    var item: AVPlayerItem!
                    beforeEach {
                        item = AVPlayerItem(url: URL(fileURLWithPath: source))
                        observer.startObserving(item: item)
                    }
                    
                    it("should exist", closure: {
                        expect(observer.observingItem).toEventuallyNot(beNil())
                    })
                })
            })
            
            describe("observing status", {
                it("should not be observing", closure: {
                    expect(observer.isObserving).toEventuallyNot(beTrue())
                })
                context("when observing", {
                    var item: AVPlayerItem!
                    beforeEach {
                        item = AVPlayerItem(url: URL(fileURLWithPath: source))
                        observer.startObserving(item: item)
                    }
                    it("should be observing", closure: {
                        expect(observer.isObserving).toEventually(beTrue())
                    })
                })
            })
            
            describe("it's delegate", {
                context("when observing", {
                    var holder: AVPlayerItemObserverDelegateHolder!
                    var item: AVPlayerItem!
                    var duration: Double = 0
                    beforeEach {
                        holder = AVPlayerItemObserverDelegateHolder()
                        holder.updateDuration = {(value) in
                            duration = value
                        }
                        observer.delegate = holder
                        item = AVPlayerItem(url: URL(fileURLWithPath: source))
                        observer.startObserving(item: item)
                    }
                    
                    it("should update delegate with duration", closure: {
                        expect(duration).toEventually(beTruthy())
                    })
                })
            })
        }
    }
}

class AVPlayerItemObserverDelegateHolder: AVPlayerItemObserverDelegate {
    
    var updateDuration: ((_ duration: Double) -> Void)?
    
    func item(didUpdateDuration duration: Double) {
        updateDuration?(duration)
    }
}
