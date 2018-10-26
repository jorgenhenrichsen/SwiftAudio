import Quick
import Nimble
import AVFoundation

@testable import SwiftAudio

class QueuedAudioPlayerTests: QuickSpec {
    override func spec() {
        describe("A QueuedAudioPlayer") {
            var audioPlayer: QueuedAudioPlayer!
            beforeEach {
                let player = AVPlayer()
                player.automaticallyWaitsToMinimizeStalling = false
                player.volume = 0.0
                audioPlayer = QueuedAudioPlayer()
                audioPlayer.bufferDuration = 0.0001
            }
            describe("its current item", {
                it("should be nil", closure: {
                    expect(audioPlayer.currentItem).to(beNil())
                })
                
                context("when adding one item", {
                    var item: AudioItem!
                    beforeEach {
                        item = ShortSource.getAudioItem()
                        try? audioPlayer.add(item: item, playWhenReady: false)
                    }
                    it("should not be nil", closure: {
                        expect(audioPlayer.currentItem).toNot(beNil())
                    })
                    
                    context("then loading a new item", closure: {
                        beforeEach {
                            try? audioPlayer.load(item: Source.getAudioItem(), playWhenReady: false)
                        }
                        
                        it("should have replaced the item", closure: {
                            expect(audioPlayer.currentItem?.getSourceUrl()).toNot(equal(item.getSourceUrl()))
                        })
                    })
                })
                
                context("when adding multiple items", {
                    beforeEach {
                        try? audioPlayer.add(items: [ShortSource.getAudioItem(), ShortSource.getAudioItem()], playWhenReady: false)
                    }
                    it("should not be nil", closure: {
                        expect(audioPlayer.currentItem).toNot(beNil())
                    })
                })
            })
            
            describe("its next items", {
                it("should be empty", closure: {
                    expect(audioPlayer.nextItems.count).to(equal(0))
                })
                
                context("when adding 2 items", {
                    beforeEach {
                        try? audioPlayer.add(items: [Source.getAudioItem(), Source.getAudioItem()])
                    }
                    it("should contain 1 item", closure: {
                        expect(audioPlayer.nextItems.count).to(equal(1))
                    })
                    
                    context("then calling next()", {
                        beforeEach {
                            try? audioPlayer.next()
                        }
                        it("should contain 0 items", closure: {
                            expect(audioPlayer.nextItems.count).to(equal(0))
                        })
                        
                        context("then calling previous()", {
                            beforeEach {
                                try? audioPlayer.previous()
                            }
                            it("should contain 1 item", closure: {
                                expect(audioPlayer.nextItems.count).to(equal(1))
                            })
                        })
                    })
                    
                    context("then removing one item", {
                        beforeEach {
                            try? audioPlayer.removeItem(atIndex: 1)
                        }
                        
                        it("should be empty", closure: {
                            expect(audioPlayer.nextItems.count).to(equal(0))
                        })
                    })
                    
                    context("then jumping to the last item", {
                        beforeEach {
                            try? audioPlayer.jumpToItem(atIndex: 1)
                        }
                        it("should be empty", closure: {
                            expect(audioPlayer.nextItems.count).to(equal(0))
                        })
                    })
                })
            })
            
            describe("its previous items", {
                it("should be empty", closure: {
                    expect(audioPlayer.previousItems.count).to(equal(0))
                })
                
                context("when adding 2 items", {
                    beforeEach {
                        try? audioPlayer.add(items: [ShortSource.getAudioItem(), ShortSource.getAudioItem()])
                    }
                    
                    it("should be empty", closure: {
                        expect(audioPlayer.previousItems.count).to(equal(0))
                    })
                    
                    context("then calling next()", {
                        beforeEach {
                            try? audioPlayer.next()
                        }
                        it("should contain one item", closure: {
                            expect(audioPlayer.previousItems.count).to(equal(1))
                        })
                    })
                    
                })
            })
        }
    }
}
