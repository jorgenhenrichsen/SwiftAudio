//
//  AudioPlayerTimeEventObserver.swift
//  AudioPlayerTest
//
//  Created by Jørgen Henrichsen on 09/03/2018.
//  Copyright © 2018 Jørgen Henrichsen. All rights reserved.
//

import Foundation
import AVFoundation

protocol AVPlayerTimeObserverDelegate: class {
    
    func audioDidStart()
    func audioDidComplete()
    func timeEvent(time: CMTime)
    
}

/**
 Class for observing time-based events from the AVPlayer
 */
class AVPlayerTimeObserver {
    
    /// The time to use as start boundary time. Cannot be zero.
    private static let startBoundaryTime: CMTime = CMTime(value: 1, timescale: 1000)
    
    /// The frequence to receive periodic time events.
    private static let periodicObserverTimeInterval: CMTime = CMTime(value: 1, timescale: 1)

    private var boundaryTimeStartObserverToken: Any?
    private var periodicTimeObserverToken: Any?
    
    private let player: AVPlayer
    
    weak var delegate: AVPlayerTimeObserverDelegate?
    
    init(player: AVPlayer) {
        self.player = player
    }
    
    /**
     Will register for the AVPlayer BoundaryTimeEvents, to trigger start and complete events.
     */
    func registerForBoundaryTimeEvents() {
        
        let startBoundaryTimes: [NSValue] = [AVPlayerTimeObserver.startBoundaryTime].map({NSValue(time: $0)})
        
        boundaryTimeStartObserverToken = player.addBoundaryTimeObserver(forTimes: startBoundaryTimes, queue: nil, using: { [weak self] in
            self?.delegate?.audioDidStart()
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func unregisterForBoundaryTimeEvents() {
        
        if let boundaryTimeStartObserverToken = boundaryTimeStartObserverToken {
            player.removeTimeObserver(boundaryTimeStartObserverToken)
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     Start observing periodic time events.
     */
    func registerForPeriodicTimeEvents() {
        periodicTimeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: nil, using: { (time) in
            self.delegate?.timeEvent(time: time)
        })
    }
    
    @objc private func didFinishPlaying() {
        delegate?.audioDidComplete()
    }
    
}
