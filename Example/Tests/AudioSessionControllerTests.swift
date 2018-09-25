import Quick
import Nimble

@testable import SwiftAudio

class AudioSessionControllerTests: QuickSpec {
    
    override func spec() {
        
        describe("An AudioSessionController") {
            let audioSessionController: AudioSessionController = AudioSessionController.shared
            
            it("should be inactive", closure: {
                expect(audioSessionController.audioSessionIsActive).to(beFalse())
            })
            
            context("when session is activated", {
                beforeEach {
                    try? audioSessionController.activateSession()
                }
                
                it("should be active", closure: {
                    expect(audioSessionController.audioSessionIsActive).to(beTrue())
                })
                
                context("when deactivating session", {
                    beforeEach {
                        try? audioSessionController.deactivateSession()
                    }
                    
                    it("should be inactive", closure: {
                        expect(audioSessionController.audioSessionIsActive).to(beFalse())
                    })
                })
            })
            
        }
        
    }
    
}
