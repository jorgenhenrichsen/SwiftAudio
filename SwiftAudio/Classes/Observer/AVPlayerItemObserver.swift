//
//  AVPlayerItemObserver.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 28/07/2018.
//

import Foundation
import AVFoundation

protocol AVPlayerItemObserverDelegate: class {
    
    /**
     Called when the observed item updates the duration.
     */
    func item(didUpdateDuration duration: Double)
    
    /**
    Called when the AVPlayer.currentItem.loadedTimeRanges changes.
    */
    func getBufferPosition(buffer: Double)
    
}

/**
 Observing an AVPlayers status changes.
 */
class AVPlayerItemObserver: NSObject {
    
    private static var context = 0
    private let main: DispatchQueue = .main
    
    private struct AVPlayerItemKeyPath {
        static let duration = #keyPath(AVPlayerItem.duration)
        static let loadedTimeRanges = #keyPath(AVPlayerItem.loadedTimeRanges)
    }
    
    private(set) var isObserving: Bool = false
    
    private(set) weak var observingItem: AVPlayerItem?
    weak var delegate: AVPlayerItemObserverDelegate?
    
    deinit {
        stopObservingCurrentItem()
    }
    
    /**
     Start observing an item. Will remove self as observer from old item, if any.
     
     - parameter item: The player item to observe.
     */
    func startObserving(item: AVPlayerItem) {
        self.stopObservingCurrentItem()
        self.isObserving = true
        self.observingItem = item
        item.addObserver(self, forKeyPath: AVPlayerItemKeyPath.duration, options: [.new], context: &AVPlayerItemObserver.context)
        item.addObserver(self, forKeyPath: AVPlayerItemKeyPath.loadedTimeRanges, options: [.new], context: &AVPlayerItemObserver.context)
    }
    
    func stopObservingCurrentItem() {
        guard let observingItem = observingItem, isObserving else {
            return
        }
        observingItem.removeObserver(self, forKeyPath: AVPlayerItemKeyPath.duration, context: &AVPlayerItemObserver.context)
        observingItem.removeObserver(self, forKeyPath: AVPlayerItemKeyPath.loadedTimeRanges, context: &AVPlayerItemObserver.context)
        self.isObserving = false
        self.observingItem = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &AVPlayerItemObserver.context, let observedKeyPath = keyPath else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        switch observedKeyPath {
        case AVPlayerItemKeyPath.duration:
            if let duration = change?[.newKey] as? CMTime {
                self.delegate?.item(didUpdateDuration: duration.seconds)
            }
        
        case AVPlayerItemKeyPath.loadedTimeRanges:
//            if let ranges = change?[.newKey] as? [NSValue], let duration = ranges.first?.timeRangeValue.duration {
//                self.delegate?.item(didUpdateDuration: duration.seconds)
//            }
            handleBufferPositionChange()
            
        default: break
            
        }
    }
    
    private func handleBufferPositionChange() {
        
        if let bufferPosition = observingItem?.loadedTimeRanges.last?.timeRangeValue.end.seconds {
            delegate?.getBufferPosition(buffer: bufferPosition)
        }
        
        
    }
    
}
