//
//  ParseWebSocketData.swift
//  RadioSpiral3
//
//  Created by Joe McMahon on 12/21/24.
//

import Foundation
import Combine

class ParseWebSocketData {
    var data: Data
    
    init(data: Data, status: StreamStatus? = nil) {
        self.data = data
    }
    
    @Published var status: StreamStatus = StreamStatus()
    
    func parse(shortCode: String) throws -> StreamStatus {
        // First: I know, I know. Codable is the better way to do this.
        // The problem is that there is one weird key that doesn't match
        // standard JSON keying ("station:shortname") which means we can't
        // use Codable.
        //
        // So we're stuck with JSONSerialization, messy as it is.
        // If I do find a way to fix that, I will absolutely switch to Codable.
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        if let nowPlayingData = json as? [String: Any] {
            self.status = StreamStatus()
            if nowPlayingData["connect"] != nil {
                let connect = nowPlayingData["connect"] as? Dictionary<String, Any>
                let subs = connect?["subs"] as? Dictionary<String, Any>
                let sub = subs?["station:\(shortCode)"] as? Dictionary<String, Any>
                let publications = sub?["publications"] as? [Any]
                let pub = publications?[0] as? Dictionary<String, Any>
                let data = pub?["data"] as? Dictionary<String, Any>
                let np = data?["np"] as? Dictionary<String, Any>

                let live = np?["live"] as? Dictionary<String, Any>
                status.dj = live?["streamer_name"] as? String ?? ""
                if status.dj == "" {
                    status.dj = "Spud the Ambient Robot"
                }
                status.isLiveDJ = status.dj !=  "Spud the Ambient Robot"
                /*
                 let next = np?["playing_next"] as? Dictionary<String, Any>
                 let next_song = next?["song"] as? Dictionary<String, Any>
                 let next_album = next_song?["album"] as! String
                 let next_art_url = try URL(from:next_song?["art"] as! Decoder)
                 let next_artist = next_song?["artist"] as! String
                 let next_title = next_song?["title"] as! String
                 */
                let current = np?["now_playing"] as? Dictionary<String, Any>
                let current_song = current?["song"] as? Dictionary<String, Any>
                status.album = current_song?["album"] as! String
                status.artist = current_song?["artist"] as! String
                status.track = current_song?["title"] as! String
                let artURLString = current_song?["art"] as! String
                status.artwork = URL(string: artURLString)
                status.changed = true
            } else if nowPlayingData["channel"] != nil {
                let pub = nowPlayingData["pub"] as! Dictionary<String, Any>
                let npData = pub["data"] as! Dictionary<String, Any>
                let np = npData["np"] as! Dictionary<String, Any>
                let live = np["live"] as? Dictionary<String, Any>
                let isLive = live?["is_live"] as! Int
                status.isLiveDJ = (isLive == 1)
                status.dj = live?["streamer_name"] as! String
                if status.dj == "" {
                    status.dj = "Spud the Ambient Robot"
                }
    
                let nowPlaying = np["now_playing"] as! Dictionary<String, Any>
                let song = nowPlaying["song"] as! Dictionary<String, Any>
                status.album = song["album"] as! String
                status.artist = song["artist"] as! String
                status.track = song["title"] as! String
                let artURLString = song["art"] as! String
                status.artwork = URL(string: artURLString)
                status.changed = true
            }
            else {
                status.changed = false
            }
        }
        return status
    }
}
