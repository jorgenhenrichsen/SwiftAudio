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
    
    var audioUrl: String { get }
    
    var artist: String? { get }
    
    var title: String? { get }
    
    var albumTitle: String? { get }
    
    var sourceType: SourceType { get }
    
    func getArtwork(_ handler: (UIImage?) -> Void)
    
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
    
    public func getArtwork(_ handler: (UIImage?) -> Void) {
        handler(artwork)
    }
}
