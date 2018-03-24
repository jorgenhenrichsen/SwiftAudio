//
//  QueueManager.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 24/03/2018.
//

import Foundation


/**
 Controls an AudioPlayer.
 */
class QueueManager {
    
    private var _items: [AudioItem] = []
    
    public var items: [AudioItem] {
        return _items
    }
    
    private var _currentIndex: Int = 0
    
    public var current: AudioItem? {
        if _items.count > _currentIndex {
            return _items[_currentIndex]
        }
        return nil
    }
    
    public func addItem(_ item: AudioItem, playWhenReady: Bool = true) {
        _items.append(item)
    }
    
    public func addItems(_ items: [AudioItem]) {
        _items.append(contentsOf: items)
    }
    
    /**
     Get the next item in the queue, if there are any.
     Will update the current item.
     
     - returns: The next item or nil.
     */
    @discardableResult
    public func next() -> AudioItem? {
        let nextIndex = _currentIndex + 1
        if _items.count > nextIndex {
            _currentIndex = nextIndex
            return _items[nextIndex]
        }
        else {
            return nil
        }
    }
    
    /**
     Get the previous item in the queue, if there are any.
     Will update the current item.
     */
    @discardableResult
    public func previous() -> AudioItem? {
        let previousIndex = _currentIndex - 1
        if previousIndex >= 0 {
            _currentIndex = previousIndex
            return _items[previousIndex]
        }
        else {
            return nil
        }
    }

    
}
