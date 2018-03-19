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
    var audioPlayer: AudioPlayer = AudioPlayer()
    let audioSessionController: AudioSessionController = AudioSessionController.shared
    let localSource = DefaultAudioItem(audioUrl: Bundle.main.path(forResource: "WAV-MP3", ofType: "wav")!, artist: "Artist", title: "Title", albumTitle: "Album", sourceType: .file, artwork: #imageLiteral(resourceName: "cover"))
    let streamSource = DefaultAudioItem(audioUrl: "https://p.scdn.co/mp3-preview/4839b070015ab7d6de9fec1756e1f3096d908fba", artist: "Artist", title: "Title", albumTitle: "Album", sourceType: .stream, artwork: #imageLiteral(resourceName: "cover"))
    
    var artwork: MPMediaItemArtwork!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioPlayer.delegate = self
        try? audioSessionController.set(category: .playback)
        try? audioSessionController.activateSession()
        let image = #imageLiteral(resourceName: "cover")
        artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (size) -> UIImage in
            return image
        })
    }
    
    @IBAction func playA(_ sender: Any) {
        audioPlayer.load(item: localSource)
    }
    
    @IBAction func playB(_ sender: Any) {
        audioPlayer.load(item: streamSource)
    }
    
    @IBAction func togglePlay(_ sender: Any) {
        audioPlayer.togglePlaying()
    }
    
    @IBAction func startScrubbing(_ sender: UISlider) {
        isScrubbing = true
    }
    
    @IBAction func scrubbing(_ sender: UISlider) {
        audioPlayer.seek(to: Double(slider.value))
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
