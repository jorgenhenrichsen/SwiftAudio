
import Quick
import Nimble

@testable import SwiftAudio

class SimpleAudioPlayerTests: QuickSpec {
    override func spec() {
        describe("A SimpleAudioPlayer") {
            var player: SimpleAudioPlayer!
            beforeEach {
                player = SimpleAudioPlayer()
            }
            
            describe("its state", {
                it("should be idle", closure: {
                    expect(player.playerState).to(equal(AudioPlayerState.idle))
                })
                
                context("when loading an item with playeWhenReady: false", {
                    beforeEach {
                        try? player.load(item: ShortSource.getAudioItem(), playWhenReady: false)
                    }
                    it("should eventually be ready", closure: {
                        expect(player.playerState).toEventually(equal(AudioPlayerState.ready))
                    })
                })
                
                context("when loading an item with playWhenReady: true", {
                    beforeEach {
                        try? player.load(item: ShortSource.getAudioItem(), playWhenReady: true)
                    }
                    it("should eventually be playing", closure: {
                        expect(player.playerState).toEventually(equal(AudioPlayerState.playing))
                    })
                })
            })
        }
    }
}
