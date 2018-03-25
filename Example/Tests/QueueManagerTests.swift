import Quick
import Nimble

@testable import SwiftAudio


class QueueManagerTests: QuickSpec {
    
    let dummyItem = 0
    
    let dummyItems: [Int] = [0, 1, 2, 3, 4, 5, 6]
    
    override func spec() {
        
        describe("A QueueManager") {
            
            var manager: QueueManager<Int>!
            
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
                    expect(manager.current).to(equal(self.dummyItem))
                })
                
                context("then calling next", {
                    
                    var nextItem: Int?
                    
                    beforeEach {
                        nextItem = try? manager.next()
                    }
                    
                    it("should not return", closure: {
                        expect(nextItem).to(beNil())
                    })
                    
                })
                
                context("then calling previous", {
                    var previousItem: Int?
                    
                    beforeEach {
                        previousItem = try? manager.previous()
                    }
                    
                    it("should not return", closure: {
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
                    expect(manager.current).to(equal(self.dummyItems.first))
                })
                
                context("then calling next", {
                    var nextItem: Int?
                    beforeEach {
                        nextItem = try? manager.next()
                    }
                    
                    it("should return the next item", closure: {
                        expect(nextItem).toNot(beNil())
                        expect(nextItem).to(equal(self.dummyItems[1]))
                    })
                    
                    it("should have next current item", closure: {
                        expect(manager.current).to(equal(self.dummyItems[1]))
                    })
                    
                    context("then calling previous", {
                        var previousItem: Int?
                        beforeEach {
                            previousItem = try? manager.previous()
                        }
                        it("should return the first item", closure: {
                            expect(previousItem).toNot(beNil())
                            expect(previousItem).to(equal(self.dummyItems.first))
                        })
                        it("should have the previous current item", closure: {
                            expect(manager.current).to(equal(self.dummyItems.first))
                        })
                    })
                })
                
                // MARK: - Removal
                
                context("then removing the second item", {
                    var removed: Int?
                    beforeEach {
                        removed = try? manager.remove(atIndex: 1)
                    }
                    
                    it("should have one less item", closure: {
                        expect(removed).toNot(beNil())
                        expect(manager.items.count).to(equal(self.dummyItems.count - 1))
                    })
                })
                
                context("then removing the last item", {
                    var removed: Int?
                    beforeEach {
                        removed = try? manager.remove(atIndex: self.dummyItems.count - 1)
                    }
                    
                    it("should have one less item", closure: {
                        expect(removed).toNot(beNil())
                        expect(manager.items.count).to(equal(self.dummyItems.count - 1))
                    })
                })
                
                context("then removing the current item", {
                    var removed: Int?
                    beforeEach {
                        removed = try? manager.remove(atIndex: manager.currentIndex)
                    }
                    it("should not remove any items", closure: {
                        expect(removed).to(beNil())
                        expect(manager.items.count).to(equal(self.dummyItems.count))
                    })
                })
                
                context("then removing with too large index", {
                    var removed: Int?
                    beforeEach {
                        removed = try? manager.remove(atIndex: self.dummyItems.count)
                    }

                    it("should not remove any items", closure: {
                        expect(removed).to(beNil())
                        expect(manager.items.count).to(equal(self.dummyItems.count))
                    })
                })
                
                context("then removing with too small index", {
                    var removed: Int?
                    beforeEach {
                        removed = try? manager.remove(atIndex: -1)
                    }
                    
                    it("should not remove any items", closure: {
                        expect(removed).to(beNil())
                        expect(manager.items.count).to(equal(self.dummyItems.count))
                    })
                })
                
                // MARK: - Jumping
                
                context("then jumping to the second item", {
                    var jumped: Int?
                    beforeEach {
                        try? jumped = manager.jump(to: 1)
                    }
                    
                    it("should return the current item", closure: {
                        expect(jumped).toNot(beNil())
                        expect(jumped).to(equal(manager.current))
                    })
                    
                    it("should move the current index", closure: {
                        expect(manager.currentIndex).to(equal(1))
                    })
                })
                
                context("then jumping to last item", closure: {
                    var jumped: Int?
                    beforeEach {
                        try? jumped = manager.jump(to: manager.items.count - 1)
                    }
                    it("should return the current item", closure: {
                        expect(jumped).toNot(beNil())
                        expect(jumped).to(equal(manager.current))
                    })
                    
                    it("should move the current index", closure: {
                        expect(manager.currentIndex).to(equal(manager.items.count - 1))
                    })
                })
                
                context("then jumping to a negative index", closure: {
                    var jumped: Int?
                    beforeEach {
                        jumped = try? manager.jump(to: -1)
                    }
                    
                    it("should not return", closure: {
                        expect(jumped).to(beNil())
                    })
                    
                    it("should not move the current index", closure: {
                        expect(manager.currentIndex).to(equal(0))
                    })
                })
                
                context("then jumping with too large index", closure: {
                    var jumped: Int?
                    beforeEach {
                        jumped = try? manager.jump(to: manager.items.count)
                    }
                    it("should not return", closure: {
                        expect(jumped).to(beNil())
                    })
                    
                    it("should not move the current index", closure: {
                        expect(manager.currentIndex).to(equal(0))
                    })
                })
                
                // MARK: - Moving
                
                context("then moving 2nd to 4th", closure: {
                    let afterMoving: [Int] = [0, 2, 3, 1, 4, 5, 6]
                    beforeEach {
                        try? manager.moveItem(fromIndex: 1, toIndex: 3)
                    }
                    
                    it("should move the item", closure: {
                        expect(manager.items).to(equal(afterMoving))
                    })
                })
            })
            
            
            
        }
        
    }
    
}
