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
        center[keyPath: command.commandKeyPath].addTarget(handler: self[keyPath: command.handlerKeyPath])
    }
    
    private func disableCommand<Command: RemoteCommandProtocol>(_ command: Command) {
        center[keyPath: command.commandKeyPath].isEnabled = false
        center[keyPath: command.commandKeyPath].removeTarget(self[keyPath: command.handlerKeyPath])
    }
    
    private func enable(command: RemoteCommand) {
        switch command {
        case .play: self.enableCommand(BaseRemoteCommand.play)
        case .pause: self.enableCommand(BaseRemoteCommand.pause)
        case .stop: self.enableCommand(BaseRemoteCommand.stop)
        case .togglePlayPause: self.enableCommand(BaseRemoteCommand.togglePlayPause)
        case .changePlaybackPosition: self.enableCommand(ChangePlaybackPositionCommand.changePlaybackPosition)
            
        case .skipForward(let preferredIntervals):
            self.enableCommand(SkipIntervalCommand.skipForward.set(preferredIntervals: preferredIntervals))
        
        case .skipBackward(let preferredIntervals):
            self.enableCommand(SkipIntervalCommand.skipBackward.set(preferredIntervals: preferredIntervals))
        
        }
    }
    
    private func disable(command: RemoteCommand) {
        switch command {
        case .play: self.disableCommand(BaseRemoteCommand.play)
        case .pause: self.disableCommand(BaseRemoteCommand.pause)
        case .stop: self.disableCommand(BaseRemoteCommand.stop)
        case .togglePlayPause: self.disableCommand(BaseRemoteCommand.togglePlayPause)
        case .changePlaybackPosition: self.disableCommand(ChangePlaybackPositionCommand.changePlaybackPosition)
        case .skipForward(_): self.disableCommand(SkipIntervalCommand.skipForward)
        case .skipBackward(_): self.disableCommand(SkipIntervalCommand.skipBackward)
        }
    }
    
    // MARK: - Handlers
    
    lazy var handlePlayCommand: RemoteCommandHandler = { (event) in
        do {
            try self.audioPlayer?.play()
            return MPRemoteCommandHandlerStatus.success
        }
        catch let error {
            return self.getRemoteCommandHandlerStatus(forError: error)
        }
        
    }
    
    lazy var handlePauseCommand: RemoteCommandHandler = { (event) in
        do {
            try self.audioPlayer?.pause()
            return MPRemoteCommandHandlerStatus.success
        }
        catch let error {
            return self.getRemoteCommandHandlerStatus(forError: error)
        }
    }
    
    lazy var handleStopCommand: RemoteCommandHandler = { (event) in
        self.audioPlayer?.stop()
        return .success
    }
    
    lazy var handleTogglePlayPauseCommand: RemoteCommandHandler = { (event) in
        do {
            try self.audioPlayer?.togglePlaying()
            return MPRemoteCommandHandlerStatus.success
        }
        catch let error {
            return self.getRemoteCommandHandlerStatus(forError: error)
        }
    }
    
    lazy var handleSkipForwardCommand: RemoteCommandHandler  = { (event) in
        if let command = event.command as? MPSkipIntervalCommand,
            let interval = command.preferredIntervals.first,
            let audioPlayer = self.audioPlayer {
            try? audioPlayer.seek(to: audioPlayer.currentTime + Double(truncating: interval))
            return MPRemoteCommandHandlerStatus.success
        }

        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    lazy var handleSkipBackwardCommand: RemoteCommandHandler = { (event) in
        if let command = event.command as? MPSkipIntervalCommand,
            let interval = command.preferredIntervals.first,
            let audioPlayer = self.audioPlayer {
            try? audioPlayer.seek(to: audioPlayer.currentTime - Double(truncating: interval))
            return MPRemoteCommandHandlerStatus.success
        }
        
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    lazy var handleChangePlaybackPositionCommand: RemoteCommandHandler  = { (event) in
        if let event = event as? MPChangePlaybackPositionCommandEvent {
            do {
                try self.audioPlayer?.seek(to: event.positionTime)
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
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    
}
