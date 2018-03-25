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
    
    let queueManager: QueueManager = QueueManager<AudioItem>()
    
    /**
     Set wether the player should automatically play the next song when a song is finished.
     Default is `true`.
     */
    public var automaticallyPlayNextSong: Bool = true
    
    public override var currentItem: AudioItem? {
        return queueManager.current
    }
    
    public var previousItems: [AudioItem]? {
        return queueManager.previousItems
    }
    
    public var nextItems: [AudioItem]? {
        return queueManager.nextItems
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
        let nextItem = try queueManager.next()
        try self.loadItem(nextItem, playWhenReady: true)
    }
    
    public func previous() throws {
        let previousItem = try queueManager.previous()
        try self.loadItem(previousItem, playWhenReady: true)
    }
    
    public func removeItem(atIndex index: Int) throws {
        try queueManager.remove(atIndex: index)
    }
    
    public func jumpToItem(atIndex index: Int, playWhenReady: Bool = true) throws {
        let item = try queueManager.jump(to: index)
        try self.loadItem(item, playWhenReady: playWhenReady)
    }
    
    func moveItem(fromIndex: Int, toIndex: Int) throws {
        try queueManager.moveItem(fromIndex: fromIndex, toIndex: toIndex)
    }
    
    // MARK: - AVPlayerWrapperDelegate
    
    override func AVWrapperItemDidComplete() {
        super.AVWrapperItemDidComplete()
        if automaticallyPlayNextSong {
            try? self.next()
        }
    }
    
}
