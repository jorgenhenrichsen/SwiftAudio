//
//  RemoteCommand.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 20/03/2018.
//

import Foundation
import MediaPlayer


public typealias RemoteCommandHandler = (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus

public protocol RemoteCommandProtocol {
    associatedtype Command: MPRemoteCommand
    
    var commandKeyPath: KeyPath<MPRemoteCommandCenter, Command> { get }
    var handlerKeyPath: KeyPath<RemoteCommandController, RemoteCommandHandler> { get }
}

public struct BaseRemoteCommand: RemoteCommandProtocol {
    
    public static let play = BaseRemoteCommand(commandKeyPath: \MPRemoteCommandCenter.playCommand, handlerKeyPath: \RemoteCommandController.handlePlayCommand)
    
    public static let pause = BaseRemoteCommand(commandKeyPath: \MPRemoteCommandCenter.pauseCommand, handlerKeyPath: \RemoteCommandController.handlePauseCommand)
    
    public static let stop = BaseRemoteCommand(commandKeyPath: \MPRemoteCommandCenter.stopCommand, handlerKeyPath: \RemoteCommandController.handleStopCommand)
    
    public static let togglePlayPause = BaseRemoteCommand(commandKeyPath: \MPRemoteCommandCenter.togglePlayPauseCommand, handlerKeyPath: \RemoteCommandController.handleTogglePlayPauseCommand)
    
    
    public typealias Command = MPRemoteCommand
    
    public var commandKeyPath: KeyPath<MPRemoteCommandCenter, MPRemoteCommand>
    
    public var handlerKeyPath: KeyPath<RemoteCommandController, RemoteCommandHandler>
    
}

public struct ChangePlaybackPositionCommand: RemoteCommandProtocol {
    
    public static let changePlaybackPosition = ChangePlaybackPositionCommand(commandKeyPath: \MPRemoteCommandCenter.changePlaybackPositionCommand, handlerKeyPath: \RemoteCommandController.handleChangePlaybackPositionCommand)
    
    public typealias Command = MPChangePlaybackPositionCommand
    
    public var commandKeyPath: KeyPath<MPRemoteCommandCenter, MPChangePlaybackPositionCommand>
    
    public var handlerKeyPath: KeyPath<RemoteCommandController, RemoteCommandHandler>
    
}

public struct SkipIntervalCommand: RemoteCommandProtocol {
    
    public static let skipForward = SkipIntervalCommand(commandKeyPath: \MPRemoteCommandCenter.skipForwardCommand, handlerKeyPath: \RemoteCommandController.handleSkipForwardCommand)
    
    public static let skipBackward = SkipIntervalCommand(commandKeyPath: \MPRemoteCommandCenter.skipBackwardCommand, handlerKeyPath: \RemoteCommandController.handleSkipBackwardCommand)

    public typealias Command = MPSkipIntervalCommand
    
    public var commandKeyPath: KeyPath<MPRemoteCommandCenter, MPSkipIntervalCommand>
    
    public var handlerKeyPath: KeyPath<RemoteCommandController, RemoteCommandHandler>
    
    func set(preferredIntervals: [NSNumber]) -> SkipIntervalCommand {
        MPRemoteCommandCenter.shared()[keyPath: commandKeyPath].preferredIntervals = preferredIntervals
        return self
    }
    
}

public enum RemoteCommand {

    case play
    
    case pause
    
    case stop
    
    case togglePlayPause
    
    case changePlaybackPosition
    
    case skipForward(preferredIntervals: [NSNumber])
    
    case skipBackward(preferredIntervals: [NSNumber])
    
    /**
     All values in an array for convenience.
     Don't use for associated values.
     */
    static func all() -> [RemoteCommand] {
        return [
            .play,
            .pause,
            .stop,
            .togglePlayPause,
            .changePlaybackPosition,
            .skipForward(preferredIntervals: []),
            .skipBackward(preferredIntervals: []),
        ]
    }
    
}
