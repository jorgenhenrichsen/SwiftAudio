//
//  QueueManager.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 24/03/2018.
//

import Foundation


class QueueManager<T> {
    
    private var _items: [T] = []
    
    /**
     All items held by the queue.
     */
    public var items: [T] {
        return _items
    }
    
    public var nextItems: [T] {
        guard _currentIndex < _items.count else {
            return []
        }
        return Array(_items[_currentIndex + 1..<items.count])
    }
    
    public var previousItems: [T] {
        if (_currentIndex == 0) {
            return []
        }
        return Array(_items[0..<_currentIndex])
    }
    
    private var _currentIndex: Int = 0
    
    /**
     The index of the current item.
     Will be populated event though there is no current item (When the queue is empty).
     */
    public var currentIndex: Int {
        return _currentIndex
    }
    
    /**
     The current item for the queue.
     */
    public var current: T? {
        if _items.count > _currentIndex {
            return _items[_currentIndex]
        }
        return nil
    }
    
    /**
     Add a single item to the queue.
     
     - parameter item: The `AudioItem` to be added.
     */
    public func addItem(_ item: T) {
        _items.append(item)
    }
    
    /**
     Add an array of items to the queue.
     
     - parameter items: The `AudioItem`s to be added.
     */
    public func addItems(_ items: [T]) {
        _items.append(contentsOf: items)
    }
    
    /**
     Get the next item in the queue, if there are any.
     Will update the current item.
     
     - throws: `APError.QueueError`
     - returns: The next item.
     */
    @discardableResult
    public func next() throws -> T {
        let nextIndex = _currentIndex + 1
        guard _items.count > nextIndex else {
            throw APError.QueueError.noNextItem
        }
        _currentIndex = nextIndex
        return _items[nextIndex]
    }
    
    /**
     Get the previous item in the queue, if there are any.
     Will update the current item.

     - throws: `APError.QueueError`
     - returns: The previous item.
     */
    @discardableResult
    public func previous() throws -> T {
        let previousIndex = _currentIndex - 1
        guard previousIndex >= 0 else {
            throw APError.QueueError.noPreviousItem
        }
        _currentIndex = previousIndex
        return _items[previousIndex]
    }
    
    /**
     Jump to a position in the queue.
     Will update the current item.
     
     - parameter index: The index to jump to.
     - throws: `APError.QueueError`
     - returns: The item at the index.
     */
    @discardableResult
    func jump(to index: Int) throws -> T {
        guard index != currentIndex else {
            throw APError.QueueError.invalidIndex(index: index, message: "Cannot jump to the current item")
        }
        
        guard index >= 0 && items.count > index else {
            throw APError.QueueError.invalidIndex(index: index, message: "The jump index has to be positive and smaller thant the count of current items (\(items.count))")
        }
        _currentIndex = index
        return _items[index]
    }
    
    /**
     Move an item in the queue.
     
     - parameter fromIndex: The index of the item to be moved.
     - parameter toIndex: The index to move the item to.
     - throws: `APError.QueueError`
     */
    func moveItem(fromIndex: Int, toIndex: Int) throws {
        
        guard fromIndex != _currentIndex else {
            throw APError.QueueError.invalidIndex(index: fromIndex, message: "The fromIndex cannot be equal to the current index.")
        }
        
        guard fromIndex >= 0 && fromIndex < _items.count else {
            throw APError.QueueError.invalidIndex(index: fromIndex, message: "The fromIndex has to be positive and smaller than the count of current items (\(items.count)).")
        }
        
        guard toIndex >= 0 && toIndex < _items.count else {
            throw APError.QueueError.invalidIndex(index: toIndex, message: "The toIndex has to be positive and smaller than the count of current items (\(items.count)).")
        }
        
        _items.insert(_items.remove(at: fromIndex), at: toIndex)
    }
    
    /**
     Remove an item.
     
     - parameter index: The index of the item to remove.
     - throws: APError.QueueError
     - returns: The removed item.
     */
    @discardableResult
    public func remove(atIndex index: Int) throws -> T {
        guard index != _currentIndex else {
            throw APError.QueueError.invalidIndex(index: index, message: "Cannot remove the current item!")
        }
        
        guard index >= 0 && _items.count > index else {
            throw APError.QueueError.invalidIndex(index: index, message: "Index for removal has to be postivie and smaller than the count of current items (\(items.count)).")
        }
        return _items.remove(at: index)
    }

    
}
