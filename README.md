# SwiftAudio

[![Build Status](https://travis-ci.com/jorgenhenrichsen/SwiftAudio.svg?token=vuPZfsuL1yx6emZGn1Qz&branch=master)](https://travis-ci.com/jorgenhenrichsen/SwiftAudio)
[![Version](https://img.shields.io/cocoapods/v/SwiftAudio.svg?style=flat)](http://cocoapods.org/pods/SwiftAudio)
[![License](https://img.shields.io/cocoapods/l/SwiftAudio.svg?style=flat)](http://cocoapods.org/pods/SwiftAudio)
[![Platform](https://img.shields.io/cocoapods/p/SwiftAudio.svg?style=flat)](http://cocoapods.org/pods/SwiftAudio)

SwiftAudio aims to make audio playback easier on iOS. No more boundaryTimeObserver, periodicTimeObserver, KVO and NotificationCenter to get state update from the player. It also updates NowPlayingInfo for you and handles remote events.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 10.0+

## Installation

SwiftAudio is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftAudio'
```

## Usage

Using the AudioManager:
```swift
let manager = AudioManager()
player.load(item: DefaultAudioItem(audioUrl: "someUrl",
            artist: "Artist",
            title: "Title",
            albumTitle: "Album",
            sourceType: .stream,
            artwork: UIImage(named: "artwork"))
```
The manager will load the track and start playing when ready.
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

## Configuration

If you need to configure the behaviour of the underlying `AudioPlayer` create your own instance and pass it in to the AudioManager:
```swift
let config = AudioPlayer.Config()
let player = AudioPlayer(config: config)
let manager = AudioManager(audioPlayer: player)
```

In the config you can configure paramters for the player. Look in [AudioPlayer.Config](SwiftAudio/Classes/AudioPlayer/AudioPlayerConfig.swift) for details. If you need to configure the player later, just keep a reference to it and change the property in the player's config.

## Plans
* More configuration on the RemoteHandlerEvents
* Ability to queue items

## Author

Jørgen Henrichsen

## License

SwiftAudio is available under the MIT license. See the LICENSE file for more info.
