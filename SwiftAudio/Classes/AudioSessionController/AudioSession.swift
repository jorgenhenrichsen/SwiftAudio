//
//  AudioSession.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 02/11/2018.
//

import Foundation
import AVFoundation


protocol AudioSession {
    
    var isOtherAudioPlaying: Bool { get }
    
    var availableCategories: [String] { get }
    
    
    func setCategory(_ category: String) throws
    
    func setCategory(_ category: String, mode: String, options: AVAudioSessionCategoryOptions) throws
    
    func setActive(_ active: Bool) throws
    
    func setActive(_ active: Bool, with options: AVAudioSessionSetActiveOptions) throws
    
}

extension AVAudioSession: AudioSession {}
