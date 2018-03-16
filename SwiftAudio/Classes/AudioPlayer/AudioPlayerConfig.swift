//
//  AudioPlayerConfig.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 10/03/2018.
//  Copyright © 2018 Jørgen Henrichsen. All rights reserved.
//

import Foundation
import AVFoundation


extension AudioPlayer {
    
    public struct Config {
        
        /**
         Indicates wether the player should automatically delay playback in order to minimize stalling.
         
         [Read more from Apple Documentation](https://developer.apple.com/documentation/avfoundation/avplayer/1643482-automaticallywaitstominimizestal)
         */
        public var automaticallyWaitsToMinimizeStalling: Bool = true
        
        /**
         The amount of seconds to be buffered by the player. Default value is 0 seconds, this means the AVPlayer will choose an appropriate level of buffering.
         
         [Read more from Apple Documentation](https://developer.apple.com/documentation/avfoundation/avplayeritem/1643630-preferredforwardbufferduration)
         
         - Important: This setting will have no effect if `automaticallyWaitsToMinimizeStalling` is set to `true`
         */
        public var bufferDuration: TimeInterval = 0
        
        /**
         Set this to decide how often the player should call the delegate with time progress events.
         Default is every second.
         Options:
         * every second
         * every half second
         * every quarter second
         */
        public var timeEventFrequency: TimeEventFrequency = .everySecond
        
        
        public init() {}
    }
    
}
