//
//  AudioPlayer.swift
//  AudioPlayerTest
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
    
}

public class AudioPlayer {
    
    struct Constants {
        static let assetPlayableKey = "playable"
    }
    
    // MARK: - Internal Properties
    
    let avPlayer: AVPlayer
    let playerObserver: AVPlayerObserver
    let playerTimeObserver: AVPlayerTimeObserver
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
    
    // MARK: - Public Methods
    
    public init(config: Config) {
        self.avPlayer = AVPlayer()
        self.config = config
        self.playerObserver = AVPlayerObserver(player: avPlayer)
        self.playerTimeObserver = AVPlayerTimeObserver(player: avPlayer, periodicObserverTimeInterval: config.timeEventFrequency.getTime())

        self.playerObserver.delegate = self
        self.playerTimeObserver.delegate = self
        
        configureFromConfig()
        playerTimeObserver.registerForPeriodicTimeEvents()
    }
    
    /**
     Start playback.
     */
    public func play() {
        if avPlayer.timeControlStatus == .paused {
            avPlayer.play()
        }
    }
    
    /**
     Will pause playback.
     */
    public func pause() {
        if avPlayer.timeControlStatus == .playing || avPlayer.timeControlStatus == .waitingToPlayAtSpecifiedRate {
            avPlayer.pause()
        }
    }
    
    /**
     Will toggle playback.
     */
    public func togglePlaying() {
        switch avPlayer.timeControlStatus {
        case .playing, .waitingToPlayAtSpecifiedRate:
            pause()
        case .paused:
            play()
        default: break
        }
    }
    
    /**
     Stop the player and remove the currently playing item.
     */
    public func stop() {
        pause()
        reset()
    }
    
    public func seek(to seconds: TimeInterval) {
        let time = CMTime(seconds: seconds, preferredTimescale: 1)
        avPlayer.seek(to: time) { (finished) in
            self.delegate?.audioPlayer(seekTo: Int(seconds), didFinish: finished)
        }
    }
    
    /**
     Load an item.
     
     - parameter source: The AudioSource to load the item from.
     - parameter playWhenReady: Whether playback should start immediately when the item is ready. Default is `true`
     */
    public func load(from urlString: String, playWhenReady: Bool = true) throws {
        
        reset()
        
        guard let url = URL(string: urlString) else {
            throw APError.LoadError.invalidSourceUrl(urlString)
        }
        
        _playWhenReady = playWhenReady
        
        // Set item
        let currentAsset = AVURLAsset(url: url)
        let currentItem = AVPlayerItem(asset: currentAsset, automaticallyLoadedAssetKeys: [Constants.assetPlayableKey])
        currentItem.preferredForwardBufferDuration = config.bufferDuration
        avPlayer.replaceCurrentItem(with: currentItem)
        
        // Register for events
        playerTimeObserver.registerForBoundaryTimeEvents()
        playerObserver.startObserving()
        
    }
    
    // MARK: - Private
    
    /**
     Reset to get ready for playing from a different source.
     */
    private func reset() {
        avPlayer.replaceCurrentItem(with: nil)
        playerTimeObserver.unregisterForBoundaryTimeEvents()
    }
    
    /**
     Will configure the player frmo the current config.
     Called when the config changes.
     */
    private func configureFromConfig() {
        avPlayer.automaticallyWaitsToMinimizeStalling = config.automaticallyWaitsToMinimizeStalling
        playerTimeObserver.periodicObserverTimeInterval = config.timeEventFrequency.getTime()
    }
    
}

extension AudioPlayer: AVPlayerObserverDelegate {
    
    // MARK: - AVPlayerObserverDelegate
    
    func player(didChangeTimeControlStatus status: AVPlayerTimeControlStatus) {
        switch status {
        case .paused:
            self._state = .paused
        case .waitingToPlayAtSpecifiedRate:
            self._state = .loading
        case .playing:
            self._state = .playing
        }
    }
    
    func player(statusDidChange status: AVPlayerStatus) {
        switch status {

        case .readyToPlay:
            delegate?.audioPlayer(didChangeState: .ready)
            self._state = .ready
            if _playWhenReady {
                self.play()
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
    
    func audioDidComplete() {
        delegate?.audioPlayerItemDidComplete()
    }
    
    func timeEvent(time: CMTime) {
        self.delegate?.audioPlayer(secondsElapsed: time.seconds)
    }
    
}



















