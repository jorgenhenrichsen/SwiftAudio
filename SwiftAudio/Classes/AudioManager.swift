//
//  AudioManager.swift
//  Pods-SwiftAudio_Example
//
//  Created by Jørgen Henrichsen on 15/03/2018.
//

import Foundation
import MediaPlayer


public protocol AudioItem {
    
    var audioUrl: String { get }
    
    var artist: String? { get }
    
    var title: String? { get }
    
    var albumTitle: String? { get }
    
    func getArtwork(_ handler: (UIImage?) -> Void)
    
}

public struct DefaultAudioItem: AudioItem {
    
    public var audioUrl: String
    
    public var artist: String?
    
    public var title: String?
    
    public var albumTitle: String?
    
    public var artwork: UIImage?
    
    public init(audioUrl: String, artist: String?, title: String?, albumTitle: String?, artwork: UIImage?) {
        self.audioUrl = audioUrl
        self.artist = artist
        self.title = title
        self.albumTitle = albumTitle
        self.artwork = artwork
    }
    
    public func getArtwork(_ handler: (UIImage?) -> Void) {
        handler(artwork)
    }
}

public protocol AudioManagerDelegate: class {
    
    func audioManager(playerDidChangeState state: AudioPlayerState)
    
    func audioManagerItemDidComplete()
    
    func audioManager(secondsElapsed seconds: Double)
    
    func audioManager(failedWithError error: Error?)
    
    func audioManager(seekTo seconds: Int, didFinish: Bool)
}

/**
 The class managing the AudioPlayern and NowPlayingInfoCenter.
 */
public class AudioManager {
    
    let audioPlayer: AudioPlayer
    let nowPlayingInfoController: NowPlayingInfoController
    let remoteCommandCenter: MPRemoteCommandCenter = MPRemoteCommandCenter.shared()
    
    public weak var delegate: AudioManagerDelegate?
    public var currentItem: AudioItem?
    
    public var currentTime: Double {
        return audioPlayer.currentTime
    }
    
    public var duration: Double {
        return audioPlayer.duration
    }
    
    public var rate: Float {
        return audioPlayer.rate
    }
    
    public var playerState: AudioPlayerState {
        return audioPlayer.state
    }
    
    public init(config: AudioPlayer.Config = AudioPlayer.Config(), infoCenter: MPNowPlayingInfoCenter = MPNowPlayingInfoCenter.default()) {
        self.audioPlayer = AudioPlayer(config: config)
        self.nowPlayingInfoController = NowPlayingInfoController(infoCenter: infoCenter)
        
        self.audioPlayer.delegate = self
        
        connectToCommandCenter()
    }
    
    public func load(item: AudioItem, playWhenReady: Bool = true) {
        try? self.audioPlayer.load(from: item.audioUrl, playWhenReady: playWhenReady)
        
        self.currentItem = item
        nowPlayingInfoController.set(keyValues: [
            MediaItemProperty.artist(item.artist),
            MediaItemProperty.title(item.title),
            MediaItemProperty.albumTitle(item.albumTitle),
            ])
        
        item.getArtwork { (image) in
            if let image = image {
                let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (size) -> UIImage in
                    return image
                })
                
                nowPlayingInfoController.set(keyValue: MediaItemProperty.artwork(artwork))
            }
        }
    }
    
    public func togglePlaying() {
        try? self.audioPlayer.togglePlaying()
    }
    
    public func play() {
        try? self.audioPlayer.play()
    }
    
    public func pause() {
        try? self.audioPlayer.pause()
    }
    
    public func seek(to seconds: TimeInterval) {
        self.audioPlayer.seek(to: seconds)
    }
    
    func updatePlaybackValues() {
        nowPlayingInfoController.set(keyValue: NowPlayingInfoProperty.elapsedPlaybackTime(audioPlayer.currentTime))
        nowPlayingInfoController.set(keyValue: MediaItemProperty.duration(audioPlayer.duration))
        nowPlayingInfoController.set(keyValue: NowPlayingInfoProperty.playbackRate(Double(audioPlayer.rate)))
    }
    
    // MARK: - Remote Commands Handlers
    
    func connectToCommandCenter() {
        self.remoteCommandCenter.playCommand.addTarget(handler: handlePlayCommand(event:))
        self.remoteCommandCenter.pauseCommand.addTarget(handler: handlePauseCommand(event:))
        self.remoteCommandCenter.togglePlayPauseCommand.addTarget(handler: handleTogglePlaybackCommand(event:))
        self.remoteCommandCenter.stopCommand.addTarget(handler: handleStopCommand(event:))
        self.remoteCommandCenter.skipForwardCommand.addTarget(handler: handleSkipForwardCommand(event:))
        remoteCommandCenter.skipForwardCommand.preferredIntervals = [15]
        self.remoteCommandCenter.skipBackwardCommand.addTarget(handler: handleSkipBackwardCommand(event:))
        remoteCommandCenter.skipBackwardCommand.preferredIntervals = [15]
        
        self.remoteCommandCenter.changePlaybackPositionCommand.addTarget(handler: handleChangePlaybackPositionCommand(event:))
    }
    
    func getRemoteCommandHandlerStatus(forError error: Error) -> MPRemoteCommandHandlerStatus {
        if let error = error as? APError.PlaybackError {
            switch error {
            case .noLoadedItem:
                return MPRemoteCommandHandlerStatus.noActionableNowPlayingItem
            }
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    func handlePlayCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        do {
            try self.audioPlayer.play()
            return MPRemoteCommandHandlerStatus.success
        }
        catch let error {
            return getRemoteCommandHandlerStatus(forError: error)
        }
    }
    
    func handlePauseCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        do {
            try self.audioPlayer.pause()
            return MPRemoteCommandHandlerStatus.success
        }
        catch let error {
            return getRemoteCommandHandlerStatus(forError: error)
        }
    }
    
    func handleTogglePlaybackCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        do {
            try self.audioPlayer.togglePlaying()
            return MPRemoteCommandHandlerStatus.success
        }
        catch let error {
            return getRemoteCommandHandlerStatus(forError: error)
        }
    }
    
    func handleStopCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        self.audioPlayer.stop()
        return MPRemoteCommandHandlerStatus.success
    }
    
    func handleSkipForwardCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if let command = event.command as? MPSkipIntervalCommand {
            if let interval = command.preferredIntervals.first {
                self.seek(to: currentTime + interval.doubleValue)
                return MPRemoteCommandHandlerStatus.success
            }
        }
        
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    func handleSkipBackwardCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if let command = event.command as? MPSkipIntervalCommand {
            if let interval = command.preferredIntervals.first {
                self.seek(to: currentTime - interval.doubleValue)
                return MPRemoteCommandHandlerStatus.success
            }
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    func handleChangePlaybackPositionCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if let event = event as? MPChangePlaybackPositionCommandEvent {
            self.seek(to: event.positionTime)
            return MPRemoteCommandHandlerStatus.success
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
}

extension AudioManager: AudioPlayerDelegate {
    
    public func audioPlayer(didChangeState state: AudioPlayerState) {
        updatePlaybackValues()
        self.delegate?.audioManager(playerDidChangeState: state)
    }
    
    public func audioPlayerItemDidComplete() {
        self.delegate?.audioManagerItemDidComplete()
    }
    
    public func audioPlayer(secondsElapsed seconds: Double) {
        self.delegate?.audioManager(secondsElapsed: seconds)
    }
    
    public func audioPlayer(failedWithError error: Error?) {
        self.delegate?.audioManager(failedWithError: error)
    }
    
    public func audioPlayer(seekTo seconds: Int, didFinish: Bool) {
        self.updatePlaybackValues()
        self.delegate?.audioManager(seekTo: seconds, didFinish: didFinish)
    }
    
}
