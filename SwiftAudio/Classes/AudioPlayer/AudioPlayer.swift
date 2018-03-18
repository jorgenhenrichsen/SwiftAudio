//
//  AudioPlayer.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 06/03/2018.
//  Copyright © 2018 Jørgen Henrichsen. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer


public protocol AudioPlayerDelegate: class {
    
    func audioPlayer(didChangeState state: AudioPlayerState)
    func audioPlayerItemDidComplete()
    func audioPlayer(secondsElapsed seconds: Double)
    func audioPlayer(failedWithError error: Error?)
    func audioPlayer(seekTo seconds: Int, didFinish: Bool)
    
}

public struct APError {
    
    enum LoadError: Error {
        case invalidSourceUrl(String)
    }
    
    enum PlaybackError: Error {
        case noLoadedItem
    }
    
}

public class AudioPlayer {
    
    struct Constants {
        static let assetPlayableKey = "playable"
    }
    
    // MARK: - Internal Properties
    
    let avPlayer: AVPlayer
    let playerObserver: AVPlayerObserver
    let playerTimeObserver: AVPlayerTimeObserver
    let playerItemNotificationObserver: AVPlayerItemNotificationObserver
    var _playWhenReady: Bool = true
    
    var currentAsset: AVAsset? {
        return currentItem?.asset
    }
    
    var currentItem: AVPlayerItem? {
        return avPlayer.currentItem
    }
    
    var _state: AudioPlayerState = AudioPlayerState.idle {
        didSet {
            self.delegate?.audioPlayer(didChangeState: _state)
        }
    }
    
    // MARK: - Public Properties
    
    /**
     The delegate receiving events.
     */
    public weak var delegate: AudioPlayerDelegate?
    
    /**
     True if the last call to load(from:playWhenReady) had playWhenReady=true.
     Cannot be set directly.
     */
    public var playWhenReady: Bool { return _playWhenReady }
    
    /**
     The current config.
     */
    public var config: Config {
        didSet { self.configureFromConfig() }
    }
    
    /**
     The current `AudioPlayerState` of the player.
     */
    public var state: AudioPlayerState { return _state }
    
    /**
     The duration of the current item.
     */
    public var duration: Double {
        if let seconds = currentItem?.duration.seconds, !seconds.isNaN {
            return seconds
        }
        return 0
    }
    
    /**
     The current time of the item in the player.
     */
    public var currentTime: Double {
        let seconds = avPlayer.currentTime().seconds
        return seconds.isNaN ? 0 : seconds
    }
    
    public var rate: Float {
        return avPlayer.rate
    }
    
    // MARK: - Public Methods
    
    public init(config: Config) {
        self.avPlayer = AVPlayer()
        self.config = config
        self.playerObserver = AVPlayerObserver(player: avPlayer)
        self.playerTimeObserver = AVPlayerTimeObserver(player: avPlayer, periodicObserverTimeInterval: config.timeEventFrequency.getTime())
        self.playerItemNotificationObserver = AVPlayerItemNotificationObserver()

        self.playerObserver.delegate = self
        self.playerTimeObserver.delegate = self
        self.playerItemNotificationObserver.delegate = self
        
        configureFromConfig()
        playerTimeObserver.registerForPeriodicTimeEvents()
    }
    
    /**
     Start playback.
     
     - throws: APError.PlaybackError
     */
    public func play() throws {
        if avPlayer.timeControlStatus == .paused {
            if currentItem != nil {
                avPlayer.play()
                return
            }
        }
        throw APError.PlaybackError.noLoadedItem
    }
    
    /**
     Will pause playback.
     
     - throws: APError.PlaybackError
     */
    public func pause() throws {
        if avPlayer.timeControlStatus == .playing || avPlayer.timeControlStatus == .waitingToPlayAtSpecifiedRate {
            if currentItem != nil {
                avPlayer.pause()
                return
            }
        }
        throw APError.PlaybackError.noLoadedItem
    }
    
    /**
     Will toggle playback.
     */
    public func togglePlaying() throws {
        switch avPlayer.timeControlStatus {
        case .playing, .waitingToPlayAtSpecifiedRate:
            try pause()
        case .paused:
            try play()
        }
    }
    
    /**
     Stop the player and remove the currently playing item.
     */
    public func stop() {
        try? pause()
        reset()
    }
    
    /**
     Seek to a point in the item.
     
     - parameter seconds: The point to move the player head, in seconds. If the given value is less than 0, 0 is used. If the value is larger than the duration, the duration is used.
     - throws: `APError.PlaybackError`
    */
    public func seek(to seconds: TimeInterval) throws {
        guard currentItem != nil else {
            throw APError.PlaybackError.noLoadedItem
        }
        let millis = Int64(max(min(seconds, duration), 0) * 1000)
        let time = CMTime(value: millis, timescale: 1000)
        avPlayer.seek(to: time) { (finished) in
            self.delegate?.audioPlayer(seekTo: Int(seconds), didFinish: finished)
        }
    }
    
    /**
     Load an item from a URL string. Use this when streaming sound.
     
     - parameter urlString: The AudioSource to load the item from.
     - parameter playWhenReady: Whether playback should start immediately when the item is ready. Default is `true`
     */
    public func load(fromUrlString urlString: String, playWhenReady: Bool = true) throws {
        
        guard let url = URL(string: urlString) else {
            throw APError.LoadError.invalidSourceUrl(urlString)
        }
        
        self.load(from: url, playWhenReady: playWhenReady)
    }
    
    /**
     Load an item from a file. Use this when playing local.
     
     - parameter filePath: The path to the sound file.
     - parameter playWhenReady: Whether playback should start immediately when the item is ready. Default is `true`
     */
    public func load(fromFilePath filePath: String, playWhenReady: Bool = true) throws {
        let url = URL(fileURLWithPath: filePath)
        self.load(from: url, playWhenReady: playWhenReady)
    }
    
    // MARK: - Private
    
    private func load(from url: URL, playWhenReady: Bool) {
        
        reset()
        _playWhenReady = playWhenReady
        
        // Set item
        let currentAsset = AVURLAsset(url: url)
        let currentItem = AVPlayerItem(asset: currentAsset, automaticallyLoadedAssetKeys: [Constants.assetPlayableKey])
        currentItem.preferredForwardBufferDuration = config.bufferDuration
        avPlayer.replaceCurrentItem(with: currentItem)
        
        // Register for events
        playerTimeObserver.registerForBoundaryTimeEvents()
        playerObserver.startObserving()
        playerItemNotificationObserver.startObserving(item: currentItem)
    }
    
    /**
     Reset to get ready for playing from a different source.
     */
    private func reset() {
        avPlayer.replaceCurrentItem(with: nil)
        playerTimeObserver.unregisterForBoundaryTimeEvents()
        playerItemNotificationObserver.stopObservingCurrentItem()
    }
    
    /**
     Will configure the player frmo the current config.
     Called when the config changes.
     */
    private func configureFromConfig() {
        avPlayer.automaticallyWaitsToMinimizeStalling = config.automaticallyWaitsToMinimizeStalling
        playerTimeObserver.periodicObserverTimeInterval = config.timeEventFrequency.getTime()
        avPlayer.volume = config.volume
    }
    
}

extension AudioPlayer: AVPlayerObserverDelegate {
    
    // MARK: - AVPlayerObserverDelegate
    
    func player(didChangeTimeControlStatus status: AVPlayerTimeControlStatus) {
        switch status {
        case .paused:
            if currentItem == nil {
                _state = .idle
            }
            else {
                self._state = .paused
            }
        case .waitingToPlayAtSpecifiedRate:
            self._state = .loading
        case .playing:
            self._state = .playing
        }
    }
    
    func player(statusDidChange status: AVPlayerStatus) {
        switch status {

        case .readyToPlay:
            self._state = .ready
            if _playWhenReady {
                try? self.play()
            }
            break

        case .failed:
            self.delegate?.audioPlayer(failedWithError: avPlayer.error)
            break
            
        case .unknown:
            break
        }
    }
    
}

extension AudioPlayer: AVPlayerTimeObserverDelegate {
    
    // MARK: - AVPlayerTimeObserverDelegate
    
    func audioDidStart() {
        self._state = .playing
    }
    
    func timeEvent(time: CMTime) {
        self.delegate?.audioPlayer(secondsElapsed: time.seconds)
    }
    
}

extension AudioPlayer: AVPlayerItemNotificationObserverDelegate {
    
    // MARK: - AVPlayerItemNotificationObserverDelegate
    
    func itemDidPlayToEndTime() {
        self.reset()
        delegate?.audioPlayerItemDidComplete()
    }
    
}
