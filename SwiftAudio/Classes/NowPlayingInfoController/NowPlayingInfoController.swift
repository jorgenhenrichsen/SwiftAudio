//
//  MediaInfoController.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 15/03/2018.
//

import Foundation
import MediaPlayer


public class NowPlayingInfoController: NowPlayingInfoControllerProtocol {
    
    private let infoCenter: MPNowPlayingInfoCenter
    private var info: [String: Any] = [:]
    
    required public init() {
        self.infoCenter = MPNowPlayingInfoCenter.default()
    }
    
    required public init(infoCenter: MPNowPlayingInfoCenter) {
        self.infoCenter = infoCenter
    }
    
    /**
     This updates a set of values in the now playing info.
     */
    public func set(keyValues: [NowPlayingInfoKeyValue]) {
        keyValues.forEach { (keyValue) in
            info[keyValue.getKey()] = keyValue.getValue()
        }
        self.infoCenter.nowPlayingInfo = info
    }
    
    /**
     This updates a single value in the now playing info.
     */
    public func set(keyValue: NowPlayingInfoKeyValue) {
        info[keyValue.getKey()] = keyValue.getValue()
        self.infoCenter.nowPlayingInfo = info
    }
    
}
