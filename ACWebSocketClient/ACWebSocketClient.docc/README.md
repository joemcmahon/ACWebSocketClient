# ACWebSocketClient
An Azuracast websocket SSE metadata client written in Swift

## Who this library is for

If you are creating code to monitor playback metadata for an [Azuracast](https://azuracast.com)
streaming radio station, this library provides an interface to fetch the near-realtime metadata
for the stream.

Version 0.1 supports the following metadata. Later versions will support more:

 - track name
 - artist name
 - album name
 - streamer name

# Using this library

To use this library you wil first need to connect the client, and then use the `@Published`
variables from the class to receive the updates from the server.

    let client = ACWebSocketClient(servername: "example.com", shortCode: "stationname")
    client.connect()

The variables available are
    client.nowPlayingData       The raw JSON struct from the websocket client
    client.isConnected          true if the client is connected, false if not
    client.songTitle            Current track title
    client.artistName           Current artist name
    client.albumName            Current album name
    client.artworkURL           URL pointing to the artwork extracted from the track's metadata
    client.dj                   The current streamer's name

Full documentation of the nowPlayingData format forthcoming.
