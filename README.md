# SwiftAudio

[![Build Status](https://travis-ci.org/jorgenhenrichsen/SwiftAudio.svg?branch=master)](https://travis-ci.org/jorgenhenrichsen/SwiftAudio)
[![Version](https://img.shields.io/cocoapods/v/SwiftAudio.svg?style=flat)](http://cocoapods.org/pods/SwiftAudio)
[![codecov](https://codecov.io/gh/jorgenhenrichsen/SwiftAudio/branch/master/graph/badge.svg)](https://codecov.io/gh/jorgenhenrichsen/SwiftAudio)
[![License](https://img.shields.io/cocoapods/l/SwiftAudio.svg?style=flat)](http://cocoapods.org/pods/SwiftAudio)
[![Platform](https://img.shields.io/cocoapods/p/SwiftAudio.svg?style=flat)](http://cocoapods.org/pods/SwiftAudio)

SwiftAudio is an audio player written in Swift, making it simpler to work with audio playback from streams and files.

## Example

To see the audio player in action clone the repo and run the example project!
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

### AudioPlayer
```swift
let player = QueuedAudioPlayer()
let audioItem = DefaultAudioItem(audioUrl: "someUrl", sourceType: .stream)
player.add(item: audioItem)
```

The player will load the track and start playing when ready. To disable this behaviour use `add(item:playWhenReady:)` and pass in `false`. This is `true` by default. To get notified of events during playback and loading, implement `AudioPlayerDelegate` and the player will notify you with changes.

If you want a simpler audio player without queue functionality, use:
```swift
let player = SimpleAudioPlayer()
let audioItem = DefaultAudioItem(audioUrl: "someUrl", sourceType: .stream)
player.load(item: audioItem)
```

**NOTE**: Do not use `AudioPlayer` directly. Use one of the above types.

#### States
The `AudioPlayer` has a `state` property, to make it easier to determine appropriate actions. The different states:
+ **idle**: The player is doing nothing, no item is set as current. This is the default state.
+ **ready**: The player has its current item set and is ready to start loading for playback. This is when you can call `play()` if you supplied `playWhenReady=false` when calling `load(item:playWhenReady)`.
+ **loading**: The player is loading the track and will start playback soon.
+ **playing**: The player is playing.
+ **paused**: The player is paused.

#### Queue
The `QueuedAudioPlayer` maintains a queue of audio tracks.
The arrangement of the tracks are: [Previous]-[Current]-[Next].

When a track is done playing, the player will load the next track and update the queue, as long as `automaticallyPlayNextSong` is `true` (This is by default).

Items can be added to the queue by calling `player.add(item:)` or `player.add(items:)`.
Use `removeItem(atIndex:)` and `moveItem(fromIndex:toIndex:)` to manipulate the queue.

The queue can be navigated by using `next()`, `previous()` and `jumpToItem(atIndex:)`

### Audio Session
Remember to activate an audio session with an appropriate category for your app. This can be done with `AudioSessionCategory`:
```swift
try? AudioSessionController.set(category: .playback)
//...
// You should wait with activating the session until you actually start playback of audio.
// This is to avoid interrupting other audio without the need to do it.
try? AudioSessionController.activateSession()
```

If you want audio to continue playing when the app is inactive, remember to activate background audio:
App Settings -> Capabilities -> Background Modes -> Check 'Audio, AirPlay, and Picture in Picture'.

#### Interruptions
If you are using the AudioSessionController for setting up the audio session, you can use it to handle interruptions too.
Implement `AudioSessionControllerDelegate` and you will be notified by `handleInterruption(type: AVAudioSessionInterruptionType)`.
If you are storing progress for playback time on items when the app quits, it can be a good idea to do it on interruptions as well.

### Now Playing Info
The `AudioPlayer` will automatically update the `MPNowPlayingInfoCenter` with artist, title, album, artwork, time if the passed in `AudioItem` supports this.
If you need to set additional properties for some items use `AudioPlayer.add(property:)`. Available properties can be found in `NowPlayingInfoProperty`.

### Remote Commands

The player will handle remote commands received from `MPRemoteCommandCenter`'s shared instance, enabled by:
```swift
audioPlayer.remoteCommands = [
    .play,
    .pause,
    .skipForward(intervals: [30]),
    .skipBackward(intervals: [30]),
  ]
```

These commands will be activated for each `AudioItem`. If you need some audio items to have different commands, implement `RemoteCommandable`. These commands will override the commands found in `AudioPlayer.remoteCommands` so make sure to supply all commands you need for that particular `AudioItem`.

**Remember** to go to App Settings -> Capabilites -> Background Modes -> Check 'Remote notifications'


## Configuration

Currently some configuration options are supported:
+ `automaticallyWaitsToMinimizeStalling`: Whether the player should delay playback start to minimize stalling. If you are streaming large audio files and playback start is slow, it can help to set this to `false`. Default is `true`.
+ `bufferDuration`: The amount of seconds to be buffered by the player. Does not have any effect if `automaticallyWaitsToMinimizeStalling` is set to `true`.
+ `timeEventFrequency`: This decides how ofen the delegate should be notified that a time unit elapsed in the playback.
+ `volume`: The volume of the player. From 0.0 to 1.0.
+ `automaticallyUpdateNowPlayingInfo`: If you want to handle updating of the `MPNowPlayingInfoCenter` yourself, set this to `false`. Default is `true`.

## Author

Jørgen Henrichsen

## License

SwiftAudio is available under the MIT license. See the LICENSE file for more info.
