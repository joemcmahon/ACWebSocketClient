# ``ACWebSocketClient``

An Azuracast websocket SSE metadata client written in Swift

## Overview

If you are creating code to monitor playback metadata for an [Azuracast](https://azuracast.com)
streaming radio station, this library provides an interface to fetch the near-realtime metadata
for the stream.

Version 0.1 supports the following metadata. Later versions will support more:

 - track name
 - artist name
 - album name
 - streamer name

## Interface

This library runs an independent process to monitor the Azuracast metadata stream.
You will probably want to ensure that the client object does not go out of scope,
as this will disconnect the client.

### Intializers
- ``ACWebSocketClient``

    let client = ACWebSocketClient(serverName: "example.com", shortCode: "station")

This initializer creates the client and sets up the `wss:` URL for connection to
Azuracast. The initializer *does not* connect to the server.

### Configuration
- ``
