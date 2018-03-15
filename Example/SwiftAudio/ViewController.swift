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
import MediaPlayer


class ViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    var isScrubbing: Bool = false
    let audioSession = AVAudioSession.sharedInstance()
    lazy var player: AudioPlayer = {
        let p = AudioPlayer(config: AudioPlayer.Config())
        p.delegate = self
        p.config.timeEventFrequency = TimeEventFrequency.everyQuarterSecond
        return p
    }()
    
    let infoController = NowPlayingInfoController()
    
    var artwork: MPMediaItemArtwork!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioSessionInit()
        activateAudioSession()
        let image = #imageLiteral(resourceName: "cover")
        artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (size) -> UIImage in
            return image
        })
    }
    
    @IBAction func playA(_ sender: Any) {
        try? player.load(from: "https://p.scdn.co/mp3-preview/4839b070015ab7d6de9fec1756e1f3096d908fba")
        
        infoController.set(keyValues: [
            MediaItemProperty.artist("This is the artis"),
            MediaItemProperty.title("This is the tile of the item"),
            MediaItemProperty.artwork(artwork),
            ])
        
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
        infoController.set(keyValue: NowPlayingInfoProperty.elapsedPlaybackTime(player.currentTime))
        infoController.set(keyValue: MediaItemProperty.duration(player.duration))
        infoController.set(keyValue: NowPlayingInfoProperty.playbackRate(Double(player.rate)))
    }
    
    func audioSessionInit() {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
            
        }
        catch {
        }
    }
    
    func activateAudioSession() {
        do{
            try audioSession.setActive(true)
        }
        catch {
        }
    }
    
}

extension ViewController: AudioPlayerDelegate {
    
    func audioPlayer(didChangeState state: AudioPlayerState) {
        print("AudioPlayer state: ", state.rawValue)
        self.update()

        if state == .playing {
            playButton.setTitle("Pause", for: .normal)
        }
        else {
            playButton.setTitle("Play", for: .normal)
            
        }
    
    }
    
    func audioPlayerItemDidComplete() {
        print("Complete!")
    }
    
    func audioPlayer(secondsElapsed seconds: Double) {
        //print(seconds)
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

