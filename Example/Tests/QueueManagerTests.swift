import Quick
import Nimble

@testable import SwiftAudio

class QueueManagerTests: QuickSpec {
    
    let dummyItem = DefaultAudioItem(audioUrl: "", sourceType: .stream)
    
    let dummyItems: [DefaultAudioItem] = [
        DefaultAudioItem(audioUrl: "first", sourceType: .stream),
        DefaultAudioItem(audioUrl: "second", sourceType: .stream),
        DefaultAudioItem(audioUrl: "third", sourceType: .stream),
        DefaultAudioItem(audioUrl: "", sourceType: .stream),
        DefaultAudioItem(audioUrl: "", sourceType: .stream),
        DefaultAudioItem(audioUrl: "", sourceType: .stream),
        DefaultAudioItem(audioUrl: "", sourceType: .stream)
    ]
    
    override func spec() {
        
        describe("A QueueManager") {
            
            var manager: QueueManager!
            
            beforeEach {
                manager = QueueManager()
            }
            
            context("when adding one item", {
                
                beforeEach {
                    manager.addItem(self.dummyItem)
                }
                
                it("should have an item in the queue", closure: {
                    expect(manager.items).notTo(beEmpty())
                })
                
                it("should set it as the current item", closure: {
                    expect(manager.current).toNot(beNil())
                    expect(manager.current?.getSourceUrl()).to(equal(self.dummyItem.getSourceUrl()))
                })
                
                context("then calling next", {
                    
                    var nextItem: AudioItem?
                    
                    beforeEach {
                        nextItem = manager.next()
                    }
                    
                    it("should return nil", closure: {
                        expect(nextItem).to(beNil())
                    })
                    
                })
                
                context("then calling previous", {
                    var previousItem: AudioItem?
                    
                    beforeEach {
                        previousItem = manager.previous()
                    }
                    
                    it("should return nil", closure: {
                        expect(previousItem).to(beNil())
                    })
                })
                
            })
            
            context("when adding multiple items", {
                
                beforeEach {
                    manager.addItems(self.dummyItems)
                }
                
                it("should have items in the queue", closure: {
                    expect(manager.items.count).to(equal(self.dummyItems.count))
                })
                
                it("should have the first item as a current item", closure: {
                    expect(manager.current).toNot(beNil())
                    expect(manager.current?.getSourceUrl()).to(equal(self.dummyItems.first!.getSourceUrl()))
                })
                
                context("then calling next", {
                    var nextItem: AudioItem?
                    beforeEach {
                        nextItem = manager.next()
                    }
                    
                    it("should return the next item", closure: {
                        expect(nextItem).toNot(beNil())
                        expect(nextItem?.getSourceUrl()).to(equal(self.dummyItems[1].getSourceUrl()))
                    })
                    
                    it("should have next current item", closure: {
                        expect(manager.current?.getSourceUrl()).to(equal(self.dummyItems[1].getSourceUrl()))
                    })
                    
                    context("then calling previous", {
                        var previousItem: AudioItem?
                        beforeEach {
                            previousItem = manager.previous()
                        }
                        it("should return the first item", closure: {
                            expect(previousItem).toNot(beNil())
                            expect(previousItem?.getSourceUrl()).to(equal(self.dummyItems.first!.getSourceUrl()))
                        })
                        it("should have the previous current item", closure: {
                            expect(manager.current?.getSourceUrl()).to(equal(self.dummyItems.first!.getSourceUrl()))
                        })
                    })
                })
                
            })
            
        }
        
    }
    
}
