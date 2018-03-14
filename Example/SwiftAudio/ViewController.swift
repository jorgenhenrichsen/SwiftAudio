//
//  ViewController.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 03/11/2018.
//  Copyright (c) 2018 Jørgen Henrichsen. All rights reserved.
//

import UIKit
import SwiftAudio
import AVFoundation


class ViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    var isScrubbing: Bool = false
    
    lazy var player: AudioPlayer = {
        let p = AudioPlayer(config: AudioPlayer.Config())
        p.delegate = self
        p.config.timeEventFrequency = TimeEventFrequency.everyQuarterSecond
        return p
    }()
    
    @IBAction func playA(_ sender: Any) {
        try? player.load(from: "https://p.scdn.co/mp3-preview/4839b070015ab7d6de9fec1756e1f3096d908fba")
    }
    
    
    @IBAction func togglePlay(_ sender: Any) {
        player.togglePlaying()
    }
    
    @IBAction func startScrubbing(_ sender: UISlider) {
        isScrubbing = true
    }
    
    @IBAction func scrubbing(_ sender: UISlider) {
        player.seek(to: Double(slider.value))
    }
    
    func update() {
        slider.maximumValue = Float(player.duration)
        slider.setValue(Float(player.currentTime), animated: true)
    }
    
}

extension ViewController: AudioPlayerDelegate {
    
    func audioPlayer(didChangeState state: AudioPlayerState) {
        print("AudioPlayer state: ", state.rawValue)
        if state == .playing {
            playButton.setTitle("Pause", for: .normal)
        }
        else {
            playButton.setTitle("Play", for: .normal)
        }
        
        if state == .loading {
            self.update()
        }
    }
    
    func audioPlayerItemDidComplete() {
        print("Complete!")
    }
    
    func audioPlayer(secondsElapsed seconds: Double) {
        print(seconds)
        if !isScrubbing {
            slider.setValue(Float(seconds), animated: false)
        }
    }
    
    
    func audioPlayer(seekTo seconds: Int, didFinish: Bool) {
        isScrubbing = false
    }
    
    func audioPlayer(failedWithError error: Error?) {
        
    }
    
}

