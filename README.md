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
let player = AudioPlayer()
let audioItem = DefaultAudioItem(audioUrl: "someUrl", sourceType: .stream)
player.load(item: audioItem)
```
The player will load the track and start playing when ready.
The `AudioPlayer` will automatically update the `MPNowPlayingInfoCenter` with artist, title, album, artwork, time etc.
To enable this behaviour the AudioItems supplied to the player must supply these values.
You must also remember to set a AudioSessionCategory that supports this behaviour, and activate the session:
```swift
try? AudioSessionController.set(category: .playback)
//...
// You should wait with activating the session until you actually start playback of audio.
// This is to avoid interrupting other audio without the need to do it.
try? AudioSessionController.activateSession()
```
If you want audio to continue playing when the app is closed or phone locked remember to activate background audio:
App Settings -> Capabilities -> Background Modes -> Check 'Audio, AirPlay, and Picture in Picture'

The player will also handle remote events received from `MPRemoteCommandCenter`'s shared instance. To enable this, you have to go to App Settings -> Capabilites -> Background Modes -> Check 'Remote notifications'

To get notified of events during playback and loading, implement `AudioPlayerDelegate`
The player will notify you with changes.

### States
The `AudioPlayer` has a `state` property, to make it easier to determine appropriate actions. The delegate will be called when the state is updated.
+ **idle**: The player is doing nothing, no item is set as current. This is the default state.
+ **ready**: The player has its current item set and is ready to start loading for playback. This is when you can call `play()` if you supplied `playWhenReady=false` when calling `load(item:playWhenReady)`.
+ **loading**: The player is loading the track and will start playback soon.
+ **playing**: The player is playing.
+ **paused**: The player is paused.

## Configuration

Currently some configuration options are supported:
+ `automaticallyWaitsToMinimizeStalling`: Whether the player should delay playback start to minimize stalling. If you are streaming large audio files and playback start is slow, it can help to set this to `false`. Default is `true`.
+ `bufferDuration`: The amount of seconds to be buffered by the player. Does not have any effect if `automaticallyWaitsToMinimizeStalling` is set to `true`.
+ `timeEventFrequency`: This decides how ofen the delegate should be notified that a time unit elapsed in the playback.
+ `volume`: The volume of the player. From 0.0 to 1.0.
+ `automaticallyUpdateNowPlayingInfo`: If you want to handle updating of the `MPNowPlayingInfoCenter` yourself, set this to `false`. Default is `true`.

## Plans
* More configuration on the RemoteHandlerEvents
* Ability to queue items

## Author

Jørgen Henrichsen

## License

SwiftAudio is available under the MIT license. See the LICENSE file for more info.
