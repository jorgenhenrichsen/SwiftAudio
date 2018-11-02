//
//  AudioSessionCategory.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 02/11/2018.
//

import Foundation
import AVFoundation


/**
 An enum wrapper around the AVAudioSessionCategories.
 For detailed info about the categories, see: [AudioSession Programming Guide](https://developer.apple.com/library/content/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/AudioSessionCategoriesandModes/AudioSessionCategoriesandModes.html#//apple_ref/doc/uid/TP40007875-CH10)
 */
public enum AudioSessionCategory {
    
    case ambient
    
    case soloAmbient
    
    case playback
    
    case record
    
    case playAndRecord
    
    case multiRoute
    
    func getValue() -> String {
        switch self {
            
        case .ambient:
            return AVAudioSessionCategoryAmbient
            
        case .soloAmbient:
            return AVAudioSessionCategorySoloAmbient
            
        case .playback:
            return AVAudioSessionCategoryPlayback
            
        case .record:
            return AVAudioSessionCategoryRecord
            
        case .playAndRecord:
            return AVAudioSessionCategoryPlayAndRecord
            
        case .multiRoute:
            return AVAudioSessionCategoryMultiRoute
            
        }
    }
}
