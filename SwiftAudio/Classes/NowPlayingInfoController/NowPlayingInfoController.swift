//
//  MediaInfoController.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 15/03/2018.
//

import Foundation
import MediaPlayer


public class NowPlayingInfoController: NowPlayingInfoControllerProtocol {
    private let concurrentInfoQueue = DispatchQueue(label: "com.doublesymmetry.nowPlayingInfoQueue", attributes: .concurrent)
    
    private var _infoCenter: NowPlayingInfoCenter
    private var _info: [String: Any] = [:]
    
    var infoCenter: NowPlayingInfoCenter {
        return _infoCenter
    }
    
    var info: [String: Any] {
        return _info
    }
    
    public required init() {
        self._infoCenter = MPNowPlayingInfoCenter.default()
    }
    
    public required init(infoCenter: NowPlayingInfoCenter) {
        self._infoCenter = infoCenter
    }
    
    public func set(keyValues: [NowPlayingInfoKeyValue]) {
        concurrentInfoQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            keyValues.forEach { (keyValue) in
                self._info[keyValue.getKey()] = keyValue.getValue()
            }

            self._infoCenter.nowPlayingInfo = self._info
        }
    }
    
    public func set(keyValue: NowPlayingInfoKeyValue) {
        concurrentInfoQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            self._info[keyValue.getKey()] = keyValue.getValue()
            self._infoCenter.nowPlayingInfo = self._info
        }
    }
    
    public func clear() {
        self._info = [:]
        self._infoCenter.nowPlayingInfo = _info
    }
    
}
