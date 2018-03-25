//
//  AudioItem.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 18/03/2018.
//

import Foundation

public enum SourceType {
    case stream
    case file
}

public protocol AudioItem {
    
    func getSourceUrl() -> String
    func getArtist() -> String?
    func getTitle() -> String?
    func getAlbumTitle() -> String?
    func getSourceType() -> SourceType
    func getArtwork(_ handler: @escaping (UIImage?) -> Void)
    
}

public struct DefaultAudioItem: AudioItem {
    

    public var audioUrl: String
    
    public var artist: String?
    
    public var title: String?
    
    public var albumTitle: String?
    
    public var sourceType: SourceType
    
    public var artwork: UIImage?
    
    public init(audioUrl: String, artist: String? = nil, title: String? = nil, albumTitle: String? = nil, sourceType: SourceType, artwork: UIImage? = nil) {
        self.audioUrl = audioUrl
        self.artist = artist
        self.title = title
        self.albumTitle = albumTitle
        self.sourceType = sourceType
        self.artwork = artwork
    }
    
    public func getSourceUrl() -> String {
        return audioUrl
    }
    
    public func getArtist() -> String? {
        return artist
    }
    
    public func getTitle() -> String? {
        return title
    }
    
    public func getAlbumTitle() -> String? {
        return albumTitle
    }
    
    public func getSourceType() -> SourceType {
        return sourceType
    }
    
    public func getArtwork(_ handler: @escaping (UIImage?) -> Void) {
        handler(artwork)
    }
    
    
}
