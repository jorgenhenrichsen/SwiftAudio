# SwiftAudio

[![Build Status](https://travis-ci.org/jorgenhenrichsen/SwiftAudio.svg?branch=master)](https://travis-ci.org/jorgenhenrichsen/SwiftAudio)
[![Version](https://img.shields.io/cocoapods/v/SwiftAudio.svg?style=flat)](http://cocoapods.org/pods/SwiftAudio)
[![codecov](https://codecov.io/gh/jorgenhenrichsen/SwiftAudio/branch/master/graph/badge.svg)](https://codecov.io/gh/jorgenhenrichsen/SwiftAudio)
[![License](https://img.shields.io/cocoapods/l/SwiftAudio.svg?style=flat)](http://cocoapods.org/pods/SwiftAudio)
[![Platform](https://img.shields.io/cocoapods/p/SwiftAudio.svg?style=flat)](http://cocoapods.org/pods/SwiftAudio)

SwiftAudio is an audio player written in Swift, making it simpler to work with audio playback from streams and files.

## Example

To see the audio player in action, run the example project!
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 10.0+

## Installation

### CocoaPods
SwiftAudio is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftAudio', '~> 0.4.0'
```

### Carthage
SwiftAudio supports [Carthage](https://github.com/Carthage/Carthage). Add this to your Cartfile:
```ruby
github "jorgenhenrichsen/SwiftAudio" ~> 0.4.0
```
Then follow the rest of Carthage instructions on [adding a framework](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

## Usage

### AudioPlayer
To get started playing some audio:
```swift
let player = AudioPlayer()
let audioItem = DefaultAudioItem(audioUrl: "someUrl", sourceType: .stream, pitchAlgorithmType: .lowQualityZeroLatency)
player.load(item: audioItem, playWhenReady: true) // Load the item and start playing when the player is ready.
```

Implement `AudioPlayerDelegate` to get notified about useful events and updates to the state of the `AudioPlayer`.

#### QueuedAudioPlayer
The `QueuedAudioPlayer` is asubclass of `AudioPlayer` that maintains a queue of audio tracks.
```swift
let player = QueuedAudioPlayer()
let audioItem = DefaultAudioItem(audioUrl: "someUrl", sourceType: .stream, pitchAlgorithmType: .lowQualityZeroLatency)
player.add(item: audioItem, playWhenReady: true) // Since this is the first item, we can supply playWhenReady: true to immedietaly start playing when the item is loaded.
```

When a track is done playing, the player will load the next track and update the queue, as long as `automaticallyPlayNextSong` is `true` (default).

##### Navigating the queue
All `AudioItem`s are stored in either `previousItems` or `nextItems`, which refers to items that come prior to the `currentItem` and after, respectively. The queue is navigated with:
```swift
player.next() // Increments the queue, and loads the next item.
player.previous() // Decrements the queue, and loads the previous item.
player.jumpToItem(atIndex:) // Jumps to a certain item and loads that item.
```

##### Manipulating the queue
```swift
 player.removeItem(at:) // Remove a specific item from the queue.
 player.removeUpcomingItems() // Remove all items in nextItems.
```

### Configuring the AudioPlayer
Current options for configuring the `AudioPlayer`:
- `bufferDuration`: The amount of seconds to be buffered by the player.
- `timeEventFrequency`: How often the player should call the delegate with time progress events.
- `automaticallyWaitsToMinimizeStalling`: Indicates whether the player should automatically delay playback in order to minimize stalling.
- `volume`
- `isMuted`
- `rate`

### Audio Session
Remember to activate an audio session with an appropriate category for your app. This can be done with `AudioSessionController`:
```swift
try? AudioSessionController.set(category: .playback)
//...
// You should wait with activating the session until you actually start playback of audio.
// This is to avoid interrupting other audio without the need to do it.
try? AudioSessionController.activateSession()
```

**Important**: If you want audio to continue playing when the app is inactive, remember to activate background audio:
App Settings -> Capabilities -> Background Modes -> Check 'Audio, AirPlay, and Picture in Picture'.

#### Interruptions
If you are using the `AudioSessionController` for setting up the audio session, you can use it to handle interruptions too.
Implement `AudioSessionControllerDelegate` and you will be notified by `handleInterruption(type: AVAudioSessionInterruptionType)`.
If you are storing progress for playback time on items when the app quits, it can be a good idea to do it on interruptions as well.
To disable interruption notifcations set `isObservingForInterruptions` to `false`.

### Now Playing Info
The `AudioPlayer` will automatically update the `MPNowPlayingInfoCenter` with artist, title, album, artwork and time if the passed in `AudioItem` supports this. This functionality can be turned off by setting `automaticallyUpdateNowPlayingInfo` to `false`.
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
These commands will be activated for each `AudioItem`. If you need some audio items to have different commands, implement `RemoteCommandable` in a custom `AudioItem`-subclass. These commands will override the commands found in `AudioPlayer.remoteCommands` so make sure to supply all commands you need for that particular `AudioItem`.

#### Custom handlers for remote commands
To supply custom handlers for your remote commands, just override the handlers contained in the player's `RemoteCommandController`:
```swift
let player = QueuedAudioPlayer()
player.remoteCommandController.handlePlayCommand = { (event) in
    // Handle remote command here.
}
```
All available overrides can be found by looking at `RemoteCommandController`.

## Author

Jørgen Henrichsen

## License

SwiftAudio is available under the MIT license. See the LICENSE file for more info.
