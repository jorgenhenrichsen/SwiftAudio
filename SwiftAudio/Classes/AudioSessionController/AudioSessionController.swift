//
//  AudioSessionController.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 19/03/2018.
//

import Foundation
import AVFoundation


public protocol AudioSessionControllerDelegate: class {
    func handleInterruption(type: AVAudioSessionInterruptionType)
}


/**
 Simple controller for the `AVAudioSession`. If you need more advanced options, just use the `AVAudioSession` directly.
 - warning: Do not combine usage of this and `AVAudioSession` directly, chose one.
 */
public class AudioSessionController {
    
    public static let shared = AudioSessionController()
    
    private let audioSession: AudioSession
    private let notificationCenter: NotificationCenter = NotificationCenter.default
    private var _isObservingForInterruptions: Bool = false
    
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
    
    /**
     Wheter notifications for interruptions are being observed or not.
     This is enabled by default.
     Set this to false to disable the behaviour.
     */
    public var isObservingForInterruptions: Bool {
        get {
            return _isObservingForInterruptions
        }
        set {
            if newValue == _isObservingForInterruptions {
                return
            }
            
            if newValue {
                registerForInterruptionNotification()
            }
            else {
                unregisterForInterruptionNotification()
            }
        }
    }
    
    public weak var delegate: AudioSessionControllerDelegate?
    
    init(audioSession: AudioSession = AVAudioSession.sharedInstance()) {
        self.audioSession = audioSession
        registerForInterruptionNotification()
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
    
    private func registerForInterruptionNotification() {
        notificationCenter.addObserver(self,
                                       selector: #selector(handleInterruption),
                                       name: .AVAudioSessionInterruption,
                                       object: nil)
        _isObservingForInterruptions = true
    }
    
    private func unregisterForInterruptionNotification() {
        notificationCenter.removeObserver(self, name: .AVAudioSessionInterruption, object: nil)
        _isObservingForInterruptions = false
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
