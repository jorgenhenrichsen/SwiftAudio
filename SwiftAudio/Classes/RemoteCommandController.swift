//
//  File.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 20/03/2018.
//

import Foundation
import MediaPlayer

public protocol RemoteCommandable {
    func getCommands() ->  [RemoteCommand]
}

public class RemoteCommandController {
        
    private let center = MPRemoteCommandCenter.shared()
    
    weak var audioPlayer: AudioPlayer?
    
    var commandTargetPointers: [String: Any] = [:]
    
    init() {}
    
    /**
     Enable a set of RemoteCommands. Calling this will disable all earlier set commands, so include all commands that needs to be active.
     
     - parameter commands: The RemoteCommands that is to be enabled.
     */
    public func enable(commands: [RemoteCommand]) {
        self.disable(commands: RemoteCommand.all())
        commands.forEach { (command) in
            self.enable(command: command)
        }
    }
    
    private func disable(commands: [RemoteCommand]) {
        commands.forEach { (command) in
            self.disable(command: command)
        }
    }
    
    private func enableCommand<Command: RemoteCommandProtocol>(_ command: Command) {
        center[keyPath: command.commandKeyPath].isEnabled = true
        commandTargetPointers[command.id] = center[keyPath: command.commandKeyPath].addTarget(handler: self[keyPath: command.handlerKeyPath])
    }
    
    private func disableCommand<Command: RemoteCommandProtocol>(_ command: Command) {
        center[keyPath: command.commandKeyPath].isEnabled = false
        center[keyPath: command.commandKeyPath].removeTarget(commandTargetPointers[command.id])
        commandTargetPointers.removeValue(forKey: command.id)
    }
    
    private func enable(command: RemoteCommand) {
        switch command {
        case .play: self.enableCommand(PlayBackCommand.play)
        case .pause: self.enableCommand(PlayBackCommand.pause)
        case .stop: self.enableCommand(PlayBackCommand.stop)
        case .togglePlayPause: self.enableCommand(PlayBackCommand.togglePlayPause)
        case .next: self.enableCommand(PlayBackCommand.nextTrack)
        case .previous: self.enableCommand(PlayBackCommand.previousTrack)
        case .changePlaybackPosition: self.enableCommand(ChangePlaybackPositionCommand.changePlaybackPosition)
        case .skipForward(let preferredIntervals): self.enableCommand(SkipIntervalCommand.skipForward.set(preferredIntervals: preferredIntervals))
        case .skipBackward(let preferredIntervals): self.enableCommand(SkipIntervalCommand.skipBackward.set(preferredIntervals: preferredIntervals))
        
        }
    }
    
    private func disable(command: RemoteCommand) {
        switch command {
        case .play: self.disableCommand(PlayBackCommand.play)
        case .pause: self.disableCommand(PlayBackCommand.pause)
        case .stop: self.disableCommand(PlayBackCommand.stop)
        case .togglePlayPause: self.disableCommand(PlayBackCommand.togglePlayPause)
        case .next: self.disableCommand(PlayBackCommand.nextTrack)
        case .previous: self.disableCommand(PlayBackCommand.previousTrack)
        case .changePlaybackPosition: self.disableCommand(ChangePlaybackPositionCommand.changePlaybackPosition)
        case .skipForward(_): self.disableCommand(SkipIntervalCommand.skipForward)
        case .skipBackward(_): self.disableCommand(SkipIntervalCommand.skipBackward)
        }
    }
    
    // MARK: - Handlers
    
    lazy var handlePlayCommand: RemoteCommandHandler = { (event) in
        if let audioPlayer = self.audioPlayer {
            do {
                try audioPlayer.play()
                return MPRemoteCommandHandlerStatus.success
            }
            catch let error {
                return self.getRemoteCommandHandlerStatus(forError: error)
            }
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    lazy var handlePauseCommand: RemoteCommandHandler = { (event) in
        if let audioPlayer = self.audioPlayer {
            do {
                try audioPlayer.pause()
                return MPRemoteCommandHandlerStatus.success
            }
            catch let error {
                return self.getRemoteCommandHandlerStatus(forError: error)
            }
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    lazy var handleStopCommand: RemoteCommandHandler = { (event) in
        if let audioPlayer = self.audioPlayer {
            audioPlayer.stop()
            return .success
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    lazy var handleTogglePlayPauseCommand: RemoteCommandHandler = { (event) in
        if let audioPlayer = self.audioPlayer {
            do {
                try audioPlayer.togglePlaying()
                return MPRemoteCommandHandlerStatus.success
            }
            catch let error {
                return self.getRemoteCommandHandlerStatus(forError: error)
            }
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    lazy var handleSkipForwardCommand: RemoteCommandHandler  = { (event) in
        if let command = event.command as? MPSkipIntervalCommand,
            let interval = command.preferredIntervals.first,
            let audioPlayer = self.audioPlayer {
            do {
                try audioPlayer.seek(to: audioPlayer.currentTime + Double(truncating: interval))
                return MPRemoteCommandHandlerStatus.success
            }
            catch let error {
                return self.getRemoteCommandHandlerStatus(forError: error)
            }
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    lazy var handleSkipBackwardCommand: RemoteCommandHandler = { (event) in
        if let command = event.command as? MPSkipIntervalCommand,
            let interval = command.preferredIntervals.first,
            let audioPlayer = self.audioPlayer {
            do {
                try audioPlayer.seek(to: audioPlayer.currentTime - Double(truncating: interval))
                return MPRemoteCommandHandlerStatus.success
            }
            catch let error {
                return self.getRemoteCommandHandlerStatus(forError: error)
            }
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    lazy var handleChangePlaybackPositionCommand: RemoteCommandHandler  = { (event) in
        if let event = event as? MPChangePlaybackPositionCommandEvent,
            let audioPlayer = self.audioPlayer {
            do {
                try audioPlayer.seek(to: event.positionTime)
                return MPRemoteCommandHandlerStatus.success
            }
            catch let error {
                return self.getRemoteCommandHandlerStatus(forError: error)
            }
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    lazy var handleNextTrackCommand: RemoteCommandHandler = { (event) in
        if let player = self.audioPlayer as? QueuedAudioPlayer {
            do {
                try player.next()
                return MPRemoteCommandHandlerStatus.success
            }
            catch let error {
                return self.getRemoteCommandHandlerStatus(forError: error)
            }
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    lazy var handlePreviousTrackCommand: RemoteCommandHandler = { (event) in
        if let player = self.audioPlayer as? QueuedAudioPlayer {
            do {
                try player.previous()
                return MPRemoteCommandHandlerStatus.success
            }
            catch let error {
                return self.getRemoteCommandHandlerStatus(forError: error)
            }
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    private func getRemoteCommandHandlerStatus(forError error: Error) -> MPRemoteCommandHandlerStatus {
        if let error = error as? APError.PlaybackError {
            switch error {
            case .noLoadedItem:
                return MPRemoteCommandHandlerStatus.noActionableNowPlayingItem
            }
        }
        else if let error = error as? APError.LoadError {
            switch error {
            case .invalidSourceUrl(_):
                return MPRemoteCommandHandlerStatus.commandFailed
            }
        }
        else if let error = error as? APError.QueueError {
            switch error {
            case .noNextItem, .noPreviousItem, .invalidIndex(_, _):
                return MPRemoteCommandHandlerStatus.noSuchContent
            }
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
}
