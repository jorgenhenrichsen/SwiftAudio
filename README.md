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
pod 'SwiftAudio', '~> 0.3.6'
```

## Usage

### AudioPlayer
```swift
let player = AudioPlayer()
let audioItem = DefaultAudioItem(audioUrl: "someUrl", sourceType: .stream)
player.load(item: audioItem, playWhenReady: true) // Load the item and start playing when the player is ready.
```

Implement `AudioPlayerDelegate` to get notified about useful events for the `AudioPlayer`.

#### States
The `AudioPlayer` has a `state` property, to make it easier to determine appropriate actions. The different states:
+ **idle**: The player is doing nothing, no item is set as current. This is the default state.
+ **ready**: The player has its current item set and is ready to start loading for playback. This is when you can call `play()` if you supplied `playWhenReady=false` when calling `load(item:playWhenReady)`.
+ **loading**: The player is loading the track and will start playback soon.
+ **playing**: The player is playing.
+ **paused**: The player is paused.

#### Queue
The `QueuedAudioPlayer` maintains a queue of audio tracks.
To use the `QueuedAudioPlayer`:
```swift
let player = QueuedAudioPlayer()
let audioItem = DefaultAudioItem(audioUrl: "someUrl", sourceType: .stream)
player.add(item: audioItem, playWhenReady: true) // Since this is the first item, we can supply playWhenReady = true to immidietaly starting playing when the item is loaded.
```

When a track is done playing, the player will load the next track and update the queue, as long as `automaticallyPlayNextSong` is `true` (This is by default).

Adding several items: `player.add(items: [audioItems])`.

Use `removeItem(atIndex:)` and `moveItem(fromIndex:toIndex:)` to manipulate the queue.

The queue can be navigated by using `next()`, `previous()` and `jumpToItem(atIndex:)`

### Audio Session
Remember to activate an audio session with an appropriate category for your app. This can be done with `AudioSessionController`:
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
To disable interruption notifcations set `isObservingForInterruptions` to `false`.

### Now Playing Info
The `AudioPlayer` will automatically update the `MPNowPlayingInfoCenter` with artist, title, album, artwork and time if the passed in `AudioItem` supports this.
If you need to set additional properties for some items, access the player's `NowPlayingInfoController` and call `set(keyValue:)`. Available properties can be found in `NowPlayingInfoProperty`.

### Remote Commands
**First** go to App Settings -> Capabilites -> Background Modes -> Check 'Remote notifications'

To enable remote commands for the player you need to populate the RemoteCommands array for the player:
```swift
audioPlayer.remoteCommands = [
    .play,
    .pause,
    .skipForward(intervals: [30]),
    .skipBackward(intervals: [30]),
  ]
```
These commands will be activated for each `AudioItem`. If you need some audio items to have different commands, implement `RemoteCommandable` in your `AudioItem`-subclass. These commands will override the commands found in `AudioPlayer.remoteCommands` so make sure to supply all commands you need for that particular `AudioItem`.

#### Custom handlers for remote commands
To supply custom handlers for your remote commands, just override the handlers contained in the player's `RemoteCommandController`:
```swift
let player = QueuedAudioPlayer()
player.remoteCommandController.handlePlayCommand = { (event) in
    // Handle remote command here.
}
```
All available overrides can be found by looking at `RemoteCommandController`.

## Configuration

### AVPlayer
If you need to customize the underlying AVPlayer:
```swift
let player = AVPlayer()
// Configure the player
// ...
//
let audioPlayer = AudioPlayer(avPlayer: player) // The AudioPlayer will then use your custom AVPlayer instance.
```

## Author

Jørgen Henrichsen

## License

SwiftAudio is available under the MIT license. See the LICENSE file for more info.
