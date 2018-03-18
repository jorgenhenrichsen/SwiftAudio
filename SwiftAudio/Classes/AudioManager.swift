//
//  AudioManager.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 15/03/2018.
//

import Foundation
import MediaPlayer


public protocol AudioManagerDelegate: class {
    
    func audioManager(playerDidChangeState state: AudioPlayerState)
    
    func audioManagerItemDidComplete()
    
    func audioManager(secondsElapsed seconds: Double)
    
    func audioManager(failedWithError error: Error?)
    
    func audioManager(seekTo seconds: Int, didFinish: Bool)
    
}

/**
 The class managing the AudioPlayer and NowPlayingInfoCenter.
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
        
        switch item.sourceType {
        case .stream:
            try? self.audioPlayer.load(fromUrlString: item.audioUrl, playWhenReady: playWhenReady)
        case .file:
            print(item.audioUrl)
            try? self.audioPlayer.load(fromFilePath: item.audioUrl, playWhenReady: playWhenReady)
        }
        
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
        try? self.audioPlayer.seek(to: seconds)
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
            do {
                try audioPlayer.seek(to: event.positionTime)
                return MPRemoteCommandHandlerStatus.success
            }
            catch let error {
                return getRemoteCommandHandlerStatus(forError: error)
            }
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
