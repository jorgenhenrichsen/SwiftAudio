//
//  AudioSessionController.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 19/03/2018.
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

public protocol AudioSessionControllerDelegate: class {
    func handleInterruption(type: AVAudioSessionInterruptionType)
}

/**
 Simple controller for the `AVAudioSession`. If you need more advanced options, just use the `AVAudioSession` directly.
 - warning: Do not combine usage of this and `AVAudioSession` directly, chose one.
 */
public class AudioSessionController {
    
    public static let shared = AudioSessionController()
    
    private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    /**
     True if another app is currently playing audio.
     */
    public var isOtherAudioPlaying: Bool {
        return audioSession.isOtherAudioPlaying
    }
    
    /**
     True if the audiosession is active.
     
     - warning: This will only be correct if the audiosession is activated through this class!
     */
    public var audioSessionIsActive: Bool = false
    
    public weak var delegate: AudioSessionControllerDelegate?
    
    private init() {
        setupInterruptionNotification()
    }
    
    public func activateSession() throws {
        do {
            try audioSession.setActive(true)
            audioSessionIsActive = true
        }
        catch let error { throw error }
    }
    
    public func deactivateSession() throws {
        do {
            try audioSession.setActive(false)
            audioSessionIsActive = false
        }
        catch let error { throw error }
    }
    
    /**
     Set the audiosession.
     */
    public func set(category: AudioSessionCategory) throws {
        try audioSession.setCategory(category.getValue())
    }
    
    // MARK: - Interruptions
    
    func setupInterruptionNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleInterruption),
                                       name: .AVAudioSessionInterruption,
                                       object: nil)
    }
    
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
                return
        }
        
        self.delegate?.handleInterruption(type: type)
    }
    
}
