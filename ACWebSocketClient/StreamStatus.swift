//
//  StreamStatus.swift
//  RadioSpiral3
//
//  Created by Joe McMahon on 12/21/24.
//

import Foundation

public class StreamStatus: Equatable {
    
    public static func == (lhs: StreamStatus, rhs: StreamStatus) -> Bool {
           lhs.isConnected == rhs.isConnected
        && lhs.isLiveDJ == rhs.isLiveDJ
        && lhs.track == rhs.track
        && lhs.artist == rhs.artist
        && lhs.album == rhs.album
        && lhs.dj == rhs.dj
    }
    
    init() {
        self.isConnected = false
        self.changed = true
        self.isLiveDJ = false
        self.track = ""
        self.artist = ""
        self.album = ""
        self.dj = ""
    }
    init(isConnected: Bool, changed: Bool, isLiveDJ: Bool, track: String, artist: String, album: String, dj: String, artwork: URL?) {
        self.isConnected = isConnected
        self.changed = changed
        self.isLiveDJ = isLiveDJ
        self.track = track
        self.artist = artist
        self.album = album
        self.dj = dj
        self.artwork = artwork
    }
    
    var isConnected: Bool
    var changed: Bool
    var isLiveDJ: Bool
    var track: String
    var artist: String
    var album: String
    var dj: String
    var artwork: URL?
}
