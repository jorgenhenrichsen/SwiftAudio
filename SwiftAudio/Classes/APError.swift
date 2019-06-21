//
//  APError.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 25/03/2018.
//

import Foundation


public struct APError {
    
    public enum LoadError: Error {
        case invalidSourceUrl(String)
    }
    
    public enum PlaybackError: Error {
        case noLoadedItem
    }
    
    public enum QueueError: Error {
        case noPreviousItem
        case noNextItem
        case invalidIndex(index: Int, message: String)
    }
    
    public enum EventError: Error {}
    
}
