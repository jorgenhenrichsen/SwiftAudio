import Quick
import Nimble
import MediaPlayer

@testable import SwiftAudio

/// Tests that the AudioPlayer is automatically updating the values it should update in the NowPlayingInfoController.
class NowPlayingInfoTests: QuickSpec {
    
    override func spec() {
        
        describe("An AudioPlayer") {
            
            var audioPlayer: AudioPlayer!
            var nowPlayingController: NowPlayingInfoController_Mock!
            
            beforeEach {
                nowPlayingController = NowPlayingInfoController_Mock()
                audioPlayer = AudioPlayer(nowPlayingInfoController: nowPlayingController)
                audioPlayer.automaticallyUpdateNowPlayingInfo = true
            }
            
            describe("its NowPlayingInfoController", {
                
                context("when loading an AudioItem", {
                    
                    var item: AudioItem!
                    
                    beforeEach {
                        item = Source.getAudioItem()
                        try? audioPlayer.load(item: item, playWhenReady: false)
                    }
                    
                    it("should eventually be updated with meta data", closure: {
                        expect(nowPlayingController.getTitle()).toEventuallyNot(beNil())
                        expect(nowPlayingController.getTitle()).toEventually(equal(item.getTitle()!))
                        
                        expect(nowPlayingController.getArtist()).toEventuallyNot(beNil())
                        expect(nowPlayingController.getArtist()).toEventually(equal(item.getArtist()!))
                        
                        expect(nowPlayingController.getAlbumTitle()).toEventuallyNot(beNil())
                        expect(nowPlayingController.getAlbumTitle()).toEventually(equal(item.getAlbumTitle()!))
                        
                        expect(nowPlayingController.getArtwork()).toEventuallyNot(beNil())
                    })
                    
                })
                
                context("when playing an AudioItem", {
                    
                    var item: AudioItem!
                    
                    beforeEach {
                        item = LongSource.getAudioItem()
                        try? audioPlayer.load(item: item, playWhenReady: true)
                    }
                    
                    it("should eventually be updated with playback values", closure: {
                        expect(nowPlayingController.getRate()).toEventuallyNot(beNil())
                        expect(nowPlayingController.getDuration()).toEventuallyNot(beNil())
                        expect(nowPlayingController.getCurrentTime()).toEventuallyNot(beNil())
                    })
                    
                })
                
            })
            
        }
        
    }
    
}

class NowPlayingInfoController_Mock: NowPlayingInfoControllerProtocol {
    
    var info: [String: Any] = [:]
    
    required public init() {
    }
    
    required public init(infoCenter: MPNowPlayingInfoCenter) {
    }

    public func set(keyValues: [NowPlayingInfoKeyValue]) {
        keyValues.forEach { (keyValue) in
            info[keyValue.getKey()] = keyValue.getValue()
        }
    }
    
    public func set(keyValue: NowPlayingInfoKeyValue) {
        info[keyValue.getKey()] = keyValue.getValue()
    }
    
    func getTitle() -> String? {
        return info[MediaItemProperty.title(nil).getKey()] as? String
    }
    
    func getArtist() -> String? {
        return info[MediaItemProperty.artist(nil).getKey()] as? String
    }
    
    func getAlbumTitle() -> String? {
        return info[MediaItemProperty.albumTitle(nil).getKey()] as? String
    }
    
    func getRate() -> Double? {
        return info[NowPlayingInfoProperty.playbackRate(nil).getKey()] as? Double
    }
    
    func getDuration() -> Double? {
        return info[MediaItemProperty.duration(nil).getKey()] as? Double
    }
    
    func getCurrentTime() -> Double? {
        return info[NowPlayingInfoProperty.elapsedPlaybackTime(nil).getKey()] as? Double
    }
    
    func getArtwork() -> MPMediaItemArtwork? {
        return info[MediaItemProperty.artwork(nil).getKey()] as? MPMediaItemArtwork
    }
    
}
