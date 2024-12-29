//
//  StreamStatus.swift
//  RadioSpiral3
//
//  Created by Joe McMahon on 12/21/24.
//

import Foundation

public class ACStreamStatus: Equatable {
    
    public static func == (lhs: ACStreamStatus, rhs: ACStreamStatus) -> Bool {
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
    
    public var isConnected: Bool
    public var changed: Bool
    public var isLiveDJ: Bool
    public var track: String
    public var artist: String
    public var album: String
    public var dj: String
    public var artwork: URL?
}
