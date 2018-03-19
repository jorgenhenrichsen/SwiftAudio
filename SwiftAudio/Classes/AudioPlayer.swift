//
//  AudioPlayer.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 15/03/2018.
//

import Foundation
import MediaPlayer

public typealias AudioPlayerState = AVPlayerWrapperState

public protocol AudioPlayerDelegate: class {
    
    func audioPlayer(playerDidChangeState state: AudioPlayerState)
    
    func audioPlayerItemDidComplete()
    
    func audioPlayer(secondsElapsed seconds: Double)
    
    func audioPlayer(failedWithError error: Error?)
    
    func audioPlayer(seekTo seconds: Int, didFinish: Bool)
    
}

public class AudioPlayer {
    
    let wrapper: AVPlayerWrapper
    let nowPlayingInfoController: NowPlayingInfoController
    let remoteCommandCenter: MPRemoteCommandCenter = MPRemoteCommandCenter.shared()
    
    public weak var delegate: AudioPlayerDelegate?
    public var currentItem: AudioItem?
    
    /**
     Set this to false to disable automatic updating of now playing info for control center and lock screen.
     */
    public var automaticallyUpdateNowPlayingInfo: Bool = true
    
    // MARK: - Getters from AVPlayerWrapper
    
    /**
     The elapsed playback time of the current item.
     */
    public var currentTime: Double {
        return wrapper.currentTime
    }
    
    /**
     The duration of the current AudioItem.
     */
    public var duration: Double {
        return wrapper.duration
    }
    
    /**
     The current rate of the underlying `AudioPlayer`.
     */
    public var rate: Float {
        return wrapper.rate
    }
    
    /**
     The current state of the underlying `AudioPlayer`.
     */
    public var playerState: AudioPlayerState {
        return wrapper.state
    }
    
    // MARK: - Setters for AVPlayerWrapper
    
    /**
     Indicates wether the player should automatically delay playback in order to minimize stalling.
     [Read more from Apple Documentation](https://developer.apple.com/documentation/avfoundation/avplayer/1643482-automaticallywaitstominimizestal)
     */
    var automaticallyWaitsToMinimizeStalling: Bool {
        get { return wrapper.automaticallyWaitsToMinimizeStalling }
        set { wrapper.automaticallyWaitsToMinimizeStalling = newValue }
    }
    
    /**
     The amount of seconds to be buffered by the player. Default value is 0 seconds, this means the AVPlayer will choose an appropriate level of buffering.
     
     [Read more from Apple Documentation](https://developer.apple.com/documentation/avfoundation/avplayeritem/1643630-preferredforwardbufferduration)
     
     - Important: This setting will have no effect if `automaticallyWaitsToMinimizeStalling` is set to `true`
     */
    var bufferDuration: TimeInterval {
        get { return wrapper.bufferDuration }
        set { wrapper.bufferDuration = newValue }
    }
    
    /**
     Set this to decide how often the player should call the delegate with time progress events.
     */
    var timeEventFrquency: TimeEventFrequency {
        get { return wrapper.timeEventFrequency }
        set { wrapper.timeEventFrequency = newValue }
    }
    
    /**
     The player volume, from 0.0 to 1.0
     Default is 1.0
     */
    var volume: Float {
        get { wrapper.volume }
        set { wrapper.volume = newValue }
    }
    
    // MARK: - Public Methods
    
    /**
     Create a new AudioManager.
     
     - parameter audioPlayer: The underlying AudioPlayer instance for the Manager. If you need to configure the behaviour of the player, create an instance, configure it and pass it in here.
     - parameter infoCenter: The InfoCenter to update. Default is `MPNowPlayingInfoCenter.default()`.
     */
    public init(infoCenter: MPNowPlayingInfoCenter = MPNowPlayingInfoCenter.default()) {
        self.wrapper = AVPlayerWrapper()
        self.nowPlayingInfoController = NowPlayingInfoController(infoCenter: infoCenter)
        
        self.wrapper.delegate = self
        
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
            try? self.wrapper.load(fromUrlString: item.audioUrl, playWhenReady: playWhenReady)
        case .file:
            print(item.audioUrl)
            try? self.wrapper.load(fromFilePath: item.audioUrl, playWhenReady: playWhenReady)
        }
        
        self.currentItem = item
        set(item: item)
        setArtwork(forItem: item)
    }
    
    /**
     Toggle playback status.
     */
    public func togglePlaying() {
        try? self.wrapper.togglePlaying()
    }
    
    /**
     Start playback
     */
    public func play() {
        try? self.wrapper.play()
    }
    
    /**
     Pause playback
     */
    public func pause() {
        try? self.wrapper.pause()
    }
    
    /**
     Seek to a specific time in the item.
     */
    public func seek(to seconds: TimeInterval) {
        try? self.wrapper.seek(to: seconds)
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
        nowPlayingInfoController.set(keyValue: NowPlayingInfoProperty.elapsedPlaybackTime(wrapper.currentTime))
        nowPlayingInfoController.set(keyValue: MediaItemProperty.duration(wrapper.duration))
        nowPlayingInfoController.set(keyValue: NowPlayingInfoProperty.playbackRate(Double(wrapper.rate)))
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
            try self.wrapper.play()
            return MPRemoteCommandHandlerStatus.success
        }
        catch let error {
            return getRemoteCommandHandlerStatus(forError: error)
        }
    }
    
    func handlePauseCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        do {
            try self.wrapper.pause()
            return MPRemoteCommandHandlerStatus.success
        }
        catch let error {
            return getRemoteCommandHandlerStatus(forError: error)
        }
    }
    
    func handleTogglePlaybackCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        do {
            try self.wrapper.togglePlaying()
            return MPRemoteCommandHandlerStatus.success
        }
        catch let error {
            return getRemoteCommandHandlerStatus(forError: error)
        }
    }
    
    func handleStopCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        self.wrapper.stop()
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
                try wrapper.seek(to: event.positionTime)
                return MPRemoteCommandHandlerStatus.success
            }
            catch let error {
                return getRemoteCommandHandlerStatus(forError: error)
            }
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
}

extension AudioPlayer: AVPlayerWrapperDelegate {
    
    func AVWrapper(didChangeState state: AVPlayerWrapperState) {
        updatePlaybackValues()
        self.delegate?.audioPlayer(playerDidChangeState: state)
    }
    
    func AVWrapperItemDidComplete() {
        self.delegate?.audioPlayerItemDidComplete()
    }
    
    func AVWrapper(secondsElapsed seconds: Double) {
        self.delegate?.audioPlayer(secondsElapsed: seconds)
    }
    
    func AVWrapper(failedWithError error: Error?) {
        self.delegate?.audioPlayer(failedWithError: error)
    }
    
    func AVWrapper(seekTo seconds: Int, didFinish: Bool) {
        self.updatePlaybackValues()
        self.delegate?.audioPlayer(seekTo: seconds, didFinish: didFinish)
    }
    
}
