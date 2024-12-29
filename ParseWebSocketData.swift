//
//  ParseWebSocketData.swift
//
//  Created by Joe McMahon on 12/21/24.
//

import Foundation
import Combine

public class ParseWebSocketData {
    var data: Data
    var defaultDJ: String?
    private var debugLevel: Int = 0
    
    public init(data: Data, status: ACStreamStatus? = nil, defaultDJ: String?) {
        self.data = data
        self.defaultDJ = defaultDJ
    }
    
    public func debug(to: Int) {
        // 0 - no debug
        // 1 - debug extracted fields
        // 2 - debug subsctructs
        // 4 - full metadata dump
        debugLevel = to
    }
    
    @Published var status: ACStreamStatus = ACStreamStatus()
    
    public func parse(shortCode: String) throws -> ACStreamStatus {
        // First: I know, I know. Codable is the better way to do this.
        // The problem is that there is one weird key that doesn't match
        // standard JSON keying ("station:shortname") which means we can't
        // use Codable.
        //
        // So we're stuck with JSONSerialization, messy as it is.
        // If I do find a way to fix that, I will absolutely switch to Codable.
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        if let nowPlayingData = json as? [String: Any] {
            if debugLevel & 4 != 0 { print("nowPlayingData: \(nowPlayingData)") }
            self.status = ACStreamStatus()
            
            // 'connect' message
            if nowPlayingData["connect"] != nil {
                
                // chain down to the now-playing data
                let connect = nowPlayingData["connect"] as? Dictionary<String, Any>
                let subs = connect?["subs"] as? Dictionary<String, Any>
                let sub = subs?["station:\(shortCode)"] as? Dictionary<String, Any>
                let publications = sub?["publications"] as? [Any]
                if publications == nil {
                    self.status.connection = ACConnectionState.failedSubscribe
                    return self.status
                }
                let pub = publications?[0] as? Dictionary<String, Any>
                let data = pub?["data"] as? Dictionary<String, Any>
                let np = data?["np"] as? Dictionary<String, Any>

                let live = np?["live"] as? Dictionary<String, Any>
                self.status = setDJ(live: live, status: self.status, defaultDJ: defaultDJ)
                if debugLevel & 2 != 0 { print("live: \(String(describing: live))") }

                /*
                 Next song data is available, but StreamStatus doesn't support it yet

                 let next = np?["playing_next"] as? Dictionary<String, Any>
                 let next_song = next?["song"] as? Dictionary<String, Any>
                 let next_album = next_song?["album"] as! String
                 let next_art_url = try URL(from:next_song?["art"] as! Decoder)
                 let next_artist = next_song?["artist"] as! String
                 let next_title = next_song?["title"] as! String
                 */
                
                // Chain down to current song
                let current = np?["now_playing"] as? Dictionary<String, Any>
                let current_song = current?["song"] as? Dictionary<String, Any>
                if debugLevel & 2 != 0 { print("current song: \(String(describing: current_song))") }
                
                // Extract track info
                status.album = current_song?["album"] as! String
                status.artist = current_song?["artist"] as! String
                status.track = current_song?["title"] as! String
                let artURLString = current_song?["art"] as! String
                status.artwork = URL(string: artURLString)
                if debugLevel & 1 != 0 {
                    print("album: \(status.album)")
                    print("track: \(status.track)")
                    print("artist: \(status.artist)")
                    print("art: \(artURLString)")
                }

                // We parsed the data, so this struct has changed
                status.changed = true
            } else if nowPlayingData["channel"] != nil {
                
                // channel data. chain down to now-playing data.
                let pub = nowPlayingData["pub"] as! Dictionary<String, Any>
                let npData = pub["data"] as! Dictionary<String, Any>
                let np = npData["np"] as! Dictionary<String, Any>

                let live = np["live"] as? Dictionary<String, Any>
                self.status = setDJ(live: live, status: self.status, defaultDJ: defaultDJ)
    
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
    
    func setDJ(live: Dictionary<String, Any>?, status: ACStreamStatus, defaultDJ: String?) -> ACStreamStatus {
        // live data: extract dj, set default if no dj and a default was supplied
        status.dj = live?["streamer_name"] as? String ?? ""
        status.isLiveDJ = true
        if status.dj == "" {
            status.isLiveDJ = false
            guard let dj = defaultDJ else {
                if debugLevel & 1 != 0 { print("DJ: \(String(describing: defaultDJ))") }
                return status
            }
                status.dj = dj
                if debugLevel & 1 != 0 { print("DJ: \(dj)") }
        }
        return status
    }
}
