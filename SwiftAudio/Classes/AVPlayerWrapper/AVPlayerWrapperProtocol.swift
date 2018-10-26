//
//  AVPlayerWrapperProtocol.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 26/10/2018.
//

import Foundation
import AVFoundation


protocol AVPlayerWrapperProtocol {
    
    var state: AVPlayerWrapperState { get }
    
    var currentItem: AVPlayerItem? { get }
    
    var currentTime: TimeInterval { get }
    
    var duration: TimeInterval { get }
    
    var rate: Float { get }
    
    
    var delegate: AVPlayerWrapperDelegate? { get set }
    
    var bufferDuration: TimeInterval { get set }
    
    var timeEventFrequency: TimeEventFrequency { get set }
    
    
    func play()
    
    func pause()
    
    func togglePlaying()
    
    func stop()
    
    func seek(to seconds: TimeInterval)
    
    func load(from url: URL, playWhenReady: Bool)
    
}
