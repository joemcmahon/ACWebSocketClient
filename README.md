# ACWebSocketClient

[![CI Status](https://img.shields.io/travis/joemcmahon/ACWebSocketClient.svg?style=flat)](https://travis-ci.org/joemcmahon/ACWebSocketClient)
[![Version](https://img.shields.io/cocoapods/v/ACWebSocketClient.svg?style=flat)](https://cocoapods.org/pods/ACWebSocketClient)
[![License](https://img.shields.io/cocoapods/l/ACWebSocketClient.svg?style=flat)](https://cocoapods.org/pods/ACWebSocketClient)
[![Platform](https://img.shields.io/cocoapods/p/ACWebSocketClient.sg?style=flat)](https://cocoapods.org/pods/ACWebSocketClient)

An Azuracast websocket SSE metadata client written in Swift

## NOTE: this client is based on `URLSessionWebSocketTask`. As such, its error recovery is poor, and this class isn't suitable for production use.

If you've set up an Azuracast streaming radio station and attempted to use
the Apple-recommended way of fetching the stream metadata, you will discover
that you never get any updates.

Whether this is a bug in Apple's code or in Azuracast's code is a moot point;
as things currently stand (December 2024), the stream metadata can't be fetched
with the standard interface.

## Azuracast SSE

Fortunately, Azuracast supplies a now-playing data interface that can
push the stream metadata updates to you via either websockets or server-side
events. This module uses the websocket interface to fetch the data. Updates are
close to real-time, sent as JSON.

### Notes

The JSON is slightly non-standard; in particular, there is one key which doesn't
conform to the key naming conventions that Codable uses, so it's necessary to
use JSONSerialization to transform the JSON into nested `Dictionary<String, Any>`
structs and manually chase down the substructures.

The high-frequency now-playing interface provide a lot more data than the standard
metadata interface. In addition to the track name and artist name, we get the
album, any data available about a live streamer, the next song up (if available),
and the song play history, with all the same info as the current and next song.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

ACWebSocketClient is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ACWebSocketClient'
```

## Author

joemcmahon, joe.mcmahon@gmail.com

## License
ACWebSocketClient is available under the MIT license. See the LICENSE file for more info.
