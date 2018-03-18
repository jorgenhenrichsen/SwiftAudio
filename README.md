# SwiftAudio

[![Build Status](https://travis-ci.com/jorgenhenrichsen/SwiftAudio.svg?token=vuPZfsuL1yx6emZGn1Qz&branch=master)](https://travis-ci.com/jorgenhenrichsen/SwiftAudio)
[![Version](https://img.shields.io/cocoapods/v/SwiftAudio.svg?style=flat)](http://cocoapods.org/pods/SwiftAudio)
[![License](https://img.shields.io/cocoapods/l/SwiftAudio.svg?style=flat)](http://cocoapods.org/pods/SwiftAudio)
[![Platform](https://img.shields.io/cocoapods/p/SwiftAudio.svg?style=flat)](http://cocoapods.org/pods/SwiftAudio)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SwiftAudio is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftAudio'
```

## Usage

Using the AudioManager:
```swift
let config = AudioPlayer.Config()
let player = AudioManager(config: config)
player.load(item: DefaultAudioItem(audioUrl: "someUrl",
            artist: "Artist",
            title: "Title",
            albumTitle: "Album",
            sourceType: .stream,
            artwork: UIImage(named: "artwork"))
```
The player will load the track and start playing when ready.
The `AudioManager` will automatically update the `MPNowPlayingInfoCenter` with artist, title, album, artwork, time etc.
It will also handle remote events received from `MPRemoteCommandCenter`'s shared instance.

To get notified of events during playback and loading, implement `AudioManagerDelegate`.
The player will notify you with changes:
```swift
func audioManager(playerDidChangeState state: AudioPlayerState)

func audioManagerItemDidComplete()

func audioManager(secondsElapsed seconds: Double)

func audioManager(failedWithError error: Error?)

func audioManager(seekTo seconds: Int, didFinish: Bool)
```

The states of the player:
```swift
public enum AudioPlayerState: String {
    
    /// The current item is set, and the player is ready to start loading (buffering).
    /// Call play() to start loading.
    case ready
    
    /// The current item is loading, getting ready to play.
    case loading
    
    /// The player is paused.
    case paused
    
    /// The player is playing.
    case playing
    
    /// No item loaded, the player is stopped.
    case idle
    
}
```




## Author

Jørgen Henrichsen, jh.henrichs@gmail.com

## License

SwiftAudio is available under the MIT license. See the LICENSE file for more info.
