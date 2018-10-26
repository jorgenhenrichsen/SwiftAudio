//
//  AVPlayerWrapper.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 06/03/2018.
//  Copyright © 2018 Jørgen Henrichsen. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer


class AVPlayerWrapper: AVPlayerWrapperProtocol {
    
    struct Constants {
        static let assetPlayableKey = "playable"
    }
    
    // MARK: - Properties
    
    let avPlayer: AVPlayer
    let playerObserver: AVPlayerObserver
    let playerTimeObserver: AVPlayerTimeObserver
    let playerItemNotificationObserver: AVPlayerItemNotificationObserver
    let playerItemObserver: AVPlayerItemObserver
    
    fileprivate var _state: AVPlayerWrapperState = AVPlayerWrapperState.idle {
        didSet {
            if oldValue != _state {
                self.delegate?.AVWrapper(didChangeState: _state)
            }
        }
    }
    
    fileprivate var _playWhenReady: Bool = false
    
    public init(avPlayer: AVPlayer = AVPlayer()) {
        self.avPlayer = avPlayer
        self.playerObserver = AVPlayerObserver(player: avPlayer)
        self.playerTimeObserver = AVPlayerTimeObserver(player: avPlayer, periodicObserverTimeInterval: timeEventFrequency.getTime())
        self.playerItemNotificationObserver = AVPlayerItemNotificationObserver()
        self.playerItemObserver = AVPlayerItemObserver()
        
        self.playerObserver.delegate = self
        self.playerTimeObserver.delegate = self
        self.playerItemNotificationObserver.delegate = self
        self.playerItemObserver.delegate = self
        
        playerTimeObserver.registerForPeriodicTimeEvents()
    }
    
    // MARK: - AVPlayerWrapperProtocol
    
    var state: AVPlayerWrapperState {
        return _state
    }
    
    var currentItem: AVPlayerItem? {
        return avPlayer.currentItem
    }
    
    var currentTime: TimeInterval {
        let seconds = avPlayer.currentTime().seconds
        return seconds.isNaN ? 0 : seconds
    }
    
    var duration: TimeInterval {
        
        if let timeRange = self.avPlayer.currentItem?.loadedTimeRanges[0].timeRangeValue {
            let duration = CMTimeGetSeconds(timeRange.duration)
            print(duration)
        }
        
        
        if let seconds = currentItem?.duration.seconds, !seconds.isNaN {
            return seconds
        }
        return 0
    }
    
    var rate: Float {
        return avPlayer.rate
    }
    
    weak var delegate: AVPlayerWrapperDelegate? = nil
    
    var bufferDuration: TimeInterval = 0
    
    var timeEventFrequency: TimeEventFrequency = .everySecond {
        didSet {
            playerTimeObserver.periodicObserverTimeInterval = timeEventFrequency.getTime()
        }
    }
    
    func play() {
        avPlayer.play()
    }
    
    func pause() {
        avPlayer.pause()
    }
    
    func togglePlaying() {
        switch avPlayer.timeControlStatus {
        case .playing, .waitingToPlayAtSpecifiedRate:
            pause()
        case .paused:
            play()
        }
    }
    
    func stop() {
        pause()
        reset(soft: false)
    }
    
    func seek(to seconds: TimeInterval) {
        let millis = Int64(max(min(seconds, duration), 0) * 1000)
        let time = CMTime(value: millis, timescale: 1000)
        avPlayer.seek(to: time) { (finished) in
            self.delegate?.AVWrapper(seekTo: Int(seconds), didFinish: finished)
        }
    }
    
    func load(from url: URL, playWhenReady: Bool) {
        reset(soft: true)
        _playWhenReady = playWhenReady
        _state = .loading

        // Set item
        let currentAsset = AVURLAsset(url: url)
        let currentItem = AVPlayerItem(asset: currentAsset, automaticallyLoadedAssetKeys: [Constants.assetPlayableKey])
        currentItem.preferredForwardBufferDuration = bufferDuration
        avPlayer.replaceCurrentItem(with: currentItem)

        // Register for events
        playerTimeObserver.registerForBoundaryTimeEvents()
        playerObserver.startObserving()
        playerItemNotificationObserver.startObserving(item: currentItem)
        playerItemObserver.startObserving(item: currentItem)
    }
    
    // MARK: - Util
    
    private func reset(soft: Bool) {
        if !soft {
            avPlayer.replaceCurrentItem(with: nil)
        }
        playerTimeObserver.unregisterForBoundaryTimeEvents()
        playerItemNotificationObserver.stopObservingCurrentItem()
    }
    
}

extension AVPlayerWrapper: AVPlayerObserverDelegate {
    
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
                self.play()
            }
            break

        case .failed:
            self.delegate?.AVWrapper(failedWithError: avPlayer.error)
            break
            
        case .unknown:
            break
        }
    }
    
}

extension AVPlayerWrapper: AVPlayerTimeObserverDelegate {
    
    // MARK: - AVPlayerTimeObserverDelegate
    
    func audioDidStart() {
        self._state = .playing
    }
    
    func timeEvent(time: CMTime) {
        self.delegate?.AVWrapper(secondsElapsed: time.seconds)
    }
    
}

extension AVPlayerWrapper: AVPlayerItemNotificationObserverDelegate {
    
    // MARK: - AVPlayerItemNotificationObserverDelegate
    
    func itemDidPlayToEndTime() {
        delegate?.AVWrapperItemDidComplete()
    }
    
}

extension AVPlayerWrapper: AVPlayerItemObserverDelegate {
    
    // MARK: - AVPlayerItemObserverDelegate
    
    func item(didUpdateDuration duration: Double) {
        self.delegate?.AVWrapper(didUpdateDuration: duration)
    }
    
}
