# ACWebSocketClient
An Azuracast websocket SSE metadata client written in Swift

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

## Interface

You establish a websocket connection by creating a client:

    let client = AzuracastWebSocketClient(
                     serverName: "example.com", shortCode: "station")

This creates the the client but does nothing else. To actually connect to the
server, you need a `connect` call:

    client.connect()
    
This runs the server and monitors the streaming data.

To actually access the data, you'll need to subscribe to it:

    client.addSubscriber(callbackFunc)
    
    func callbackFunc(status: StreamStatus) {
        // process data from the StreamStatus struct
    }
    
The callback will be called when the stream data changes. The stream data does
contain empty "ping" JSON to keep the connection alive; the library ignores these
and doesn't call the callback for them.

See the `StreamStatus` struct in this library for details on what is there; as
of this initial release, the data is

 - track name
 - artist name
 - album name
 - streamer name
 - isConnected (true if the client is connected)
 - changed (true if the metadata updated)
 - isLiveDJ (true if there is a live streamer)




