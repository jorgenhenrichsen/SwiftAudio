//
//  AudioSession.swift
//  SwiftAudio_Tests
//
//  Created by Jørgen Henrichsen on 31/10/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import AVFoundation

@testable import SwiftAudio


class NonFailingAudioSession: AudioSession {
    
    var isOtherAudioPlaying: Bool = false
    
    var availableCategories: [String] = []
    
    func setCategory(_ category: String) throws {}
    
    func setCategory(_ category: String, mode: String, options: AVAudioSessionCategoryOptions) throws {}
    
    func setActive(_ active: Bool) throws {}
    
    func setActive(_ active: Bool, with options: AVAudioSessionSetActiveOptions) throws {}

}

class FailingAudioSession: AudioSession {
    
    var isOtherAudioPlaying: Bool = false
    
    var availableCategories: [String] = []
    
    func setCategory(_ category: String) throws {
        throw AVError(AVError.unknown)
    }
    
    func setCategory(_ category: String, mode: String, options: AVAudioSessionCategoryOptions) throws {
        throw AVError(AVError.unknown)
    }
    
    func setActive(_ active: Bool) throws {
        throw AVError(AVError.unknown)
    }
    
    func setActive(_ active: Bool, with options: AVAudioSessionSetActiveOptions) throws {
        throw AVError(AVError.unknown)
    }
    
    
}
