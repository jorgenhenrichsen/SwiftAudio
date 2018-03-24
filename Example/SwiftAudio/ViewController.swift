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
    var audioPlayer: QueuedAudioPlayer = QueuedAudioPlayer()
    let audioSessionController: AudioSessionController = AudioSessionController.shared
    let localSource = DefaultAudioItem(audioUrl: Bundle.main.path(forResource: "WAV-MP3", ofType: "wav")!, artist: "Artist", title: "Title", albumTitle: "Album", sourceType: .file, artwork: #imageLiteral(resourceName: "cover"))
    let streamSource = DefaultAudioItem(audioUrl: "https://p.scdn.co/mp3-preview/081447adc23dad4f79ba4f1082615d1c56edf5e1?cid=d8a5ed958d274c2e8ee717e6a4b0971d", artist: "Bon Iver", title: "8 (circle)", albumTitle: "22, A Million", sourceType: .stream, artwork: #imageLiteral(resourceName: "22AMI"))
    
    let sources: [AudioItem] = [
        DefaultAudioItem(audioUrl: "https://p.scdn.co/mp3-preview/67b51d90ffddd6bb3f095059997021b589845f81?cid=d8a5ed958d274c2e8ee717e6a4b0971d", artist: "Bon Iver", title: "33 \"GOD\"", albumTitle: "22, A Million", sourceType: .stream, artwork: #imageLiteral(resourceName: "22AMI")),
        DefaultAudioItem(audioUrl: "https://p.scdn.co/mp3-preview/081447adc23dad4f79ba4f1082615d1c56edf5e1?cid=d8a5ed958d274c2e8ee717e6a4b0971d", artist: "Bon Iver", title: "8 (circle)", albumTitle: "22, A Million", sourceType: .stream, artwork: #imageLiteral(resourceName: "22AMI")),
        DefaultAudioItem(audioUrl: "https://p.scdn.co/mp3-preview/6f9999d909b017eabef97234dd7a206355720d9d?cid=d8a5ed958d274c2e8ee717e6a4b0971d", artist: "Bon Iver", title: "715 - CRΣΣKS", albumTitle: "22, A Million", sourceType: .stream, artwork: #imageLiteral(resourceName: "22AMI")),
        DefaultAudioItem(audioUrl: "https://p.scdn.co/mp3-preview/bf9bdd403c67fdbe06a582e7b292487c8cfd1f7e?cid=d8a5ed958d274c2e8ee717e6a4b0971d", artist: "Bon Iver", title: "____45_____", albumTitle: "22, A Million", sourceType: .stream, artwork: #imageLiteral(resourceName: "22AMI"))
    ]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        audioPlayer.delegate = self
        audioPlayer.remoteCommands = [
                .stop,
                .togglePlayPause,
                .skipForward(preferredIntervals: [30]),
                .skipBackward(preferredIntervals: [30]),
                .changePlaybackPosition
            ]
        try? audioSessionController.set(category: .playback)
        try? audioSessionController.activateSession()
    }
    
    @IBAction func playA(_ sender: Any) {
        //try? audioPlayer.load(item: localSource)
    }
    
    @IBAction func playB(_ sender: Any) {
        try? audioPlayer.add(items: sources)
    }
    
    @IBAction func togglePlay(_ sender: Any) {
        try? audioPlayer.togglePlaying()
    }
    
    @IBAction func previous(_ sender: Any) {
        try? audioPlayer.previous()
    }
    
    @IBAction func next(_ sender: Any) {
        try? audioPlayer.next()
    }
    
    @IBAction func startScrubbing(_ sender: UISlider) {
        isScrubbing = true
    }
    
    @IBAction func scrubbing(_ sender: UISlider) {
        try? audioPlayer.seek(to: Double(slider.value))
    }
    
    func update() {
        slider.maximumValue = Float(audioPlayer.duration)
        slider.setValue(Float(audioPlayer.currentTime), animated: true)
    }
    
}

extension ViewController: AudioPlayerDelegate {
    
    func audioPlayer(playerDidChangeState state: AVPlayerWrapperState) {
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
        
    }
    
    func audioPlayer(secondsElapsed seconds: Double) {
        if !isScrubbing {
            slider.setValue(Float(seconds), animated: false)
        }
    }
    
    func audioPlayer(failedWithError error: Error?) {
        
    }
    
    func audioPlayer(seekTo seconds: Int, didFinish: Bool) {
        isScrubbing = false
    }
    
}
