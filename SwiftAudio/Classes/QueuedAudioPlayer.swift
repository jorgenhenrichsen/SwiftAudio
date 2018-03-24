//
//  QueuedAudioPlayer.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 24/03/2018.
//

import Foundation


/**
 An audio player that can keep track of a queue of AudioItems.
 */
public class QueuedAudioPlayer: AudioPlayer {
    
    let queueManager: QueueManager = QueueManager()
    
    /**
     Set wether the player should automatically play the next song when a song is finished.
     Default is `true`.
     */
    public var automaticallyPlayNextSong: Bool = true
    
    public override var currentItem: AudioItem? {
        return queueManager.current
    }
    
    public func add(item: AudioItem, playWhenReady: Bool = true) throws {
        if currentItem == nil {
            queueManager.addItem(item)
            try self.loadItem(item, playWhenReady: playWhenReady)
        }
        else {
            queueManager.addItem(item)
        }
    }
    
    public func add(items: [AudioItem], playWhenReady: Bool = true) throws {
        if currentItem == nil {
            queueManager.addItems(items)
            try self.loadItem(currentItem!, playWhenReady: playWhenReady)
        }
        else {
            queueManager.addItems(items)
        }
    }
    
    public func next() throws {
        if let nextItem = queueManager.next() {
            try self.loadItem(nextItem, playWhenReady: true)
        }
        else {
            throw APError.LoadError.noNextItem
        }
    }
    
    public func previous() throws {
        if let previousItem = queueManager.previous() {
            try self.loadItem(previousItem, playWhenReady: true)
        }
        else {
            throw APError.LoadError.noPreviousItem
        }
    }
    
    // MARK: - AVPlayerWrapperDelegate
    
    override func AVWrapperItemDidComplete() {
        super.AVWrapperItemDidComplete()
        if automaticallyPlayNextSong {
            try? self.next()
        }
    }
    
}
