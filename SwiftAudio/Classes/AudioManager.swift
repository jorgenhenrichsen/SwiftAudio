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
    
    /**
     The elapsed playback time of the current item.
     */
    public var currentTime: Double {
        return audioPlayer.currentTime
    }
    
    /**
     The duration of the current AudioItem.
     */
    public var duration: Double {
        return audioPlayer.duration
    }
    
    /**
     The current rate of the underlying `AudioPlayer`.
     */
    public var rate: Float {
        return audioPlayer.rate
    }
    
    /**
     The current state of the underlying `AudioPlayer`.
     */
    public var playerState: AudioPlayerState {
        return audioPlayer.state
    }
    
    /**
     Set this to false to disable automatic updating of now playing info for control center and lock screen.
     */
    public var automaticallyUpdateNowPlayingInfo: Bool = true
    
    /**
     Create a new AudioManager.
     
     - parameter audioPlayer: The underlying AudioPlayer instance for the Manager. If you need to configure the behaviour of the player, create an instance, configure it and pass it in here.
     - parameter infoCenter: The InfoCenter to update. Default is `MPNowPlayingInfoCenter.default()`.
     */
    public init(audioPlayer: AudioPlayer = AudioPlayer(config: AudioPlayer.Config()), infoCenter: MPNowPlayingInfoCenter = MPNowPlayingInfoCenter.default()) {
        self.audioPlayer = audioPlayer
        self.nowPlayingInfoController = NowPlayingInfoController(infoCenter: infoCenter)
        
        self.audioPlayer.delegate = self
        
        connectToCommandCenter()
    }
    
    /**
     Load an AudioItem into the manager.
     
     - parameter item: The AudioItem to load. The info given in this item is the one used for the InfoCenter.
     - parameter playWhenReady: Immediately start playback when the item is ready. Default is `true`. If you disable this you have to call play() or togglePlay() when the `state` switches to `ready`.
     */
    public func load(item: AudioItem, playWhenReady: Bool = true) {
        
        switch item.sourceType {
        case .stream:
            try? self.audioPlayer.load(fromUrlString: item.audioUrl, playWhenReady: playWhenReady)
        case .file:
            print(item.audioUrl)
            try? self.audioPlayer.load(fromFilePath: item.audioUrl, playWhenReady: playWhenReady)
        }
        
        self.currentItem = item
        set(item: item)
        setArtwork(forItem: item)
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
    
    // MARK: - NowPlayingInfo
    
    func set(item: AudioItem) {
        guard automaticallyUpdateNowPlayingInfo else { return }
        nowPlayingInfoController.set(keyValues: [
            MediaItemProperty.artist(item.artist),
            MediaItemProperty.title(item.title),
            MediaItemProperty.albumTitle(item.albumTitle),
            ])
    }
    
    func setArtwork(forItem item: AudioItem) {
        guard automaticallyUpdateNowPlayingInfo else { return }
        item.getArtwork { (image) in
            if let image = image {
                let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (size) -> UIImage in
                    return image
                })
                
                nowPlayingInfoController.set(keyValue: MediaItemProperty.artwork(artwork))
            }
        }
    }
    
    func updatePlaybackValues() {
        guard automaticallyUpdateNowPlayingInfo else { return }
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
    
    func audioPlayer(didChangeState state: AudioPlayerState) {
        updatePlaybackValues()
        self.delegate?.audioManager(playerDidChangeState: state)
    }
    
    func audioPlayerItemDidComplete() {
        self.delegate?.audioManagerItemDidComplete()
    }
    
    func audioPlayer(secondsElapsed seconds: Double) {
        self.delegate?.audioManager(secondsElapsed: seconds)
    }
    
    func audioPlayer(failedWithError error: Error?) {
        self.delegate?.audioManager(failedWithError: error)
    }
    
    func audioPlayer(seekTo seconds: Int, didFinish: Bool) {
        self.updatePlaybackValues()
        self.delegate?.audioManager(seekTo: seconds, didFinish: didFinish)
    }
    
}
