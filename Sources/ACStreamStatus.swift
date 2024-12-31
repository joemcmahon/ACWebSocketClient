//
//  ACStreamStatus.swift
//
//  Created by Joe McMahon on 12/21/24.
//

import Foundation

public class ACStreamStatus: Equatable {
    
    public static func == (lhs: ACStreamStatus, rhs: ACStreamStatus) -> Bool {
        lhs.connection == rhs.connection
        && lhs.isLiveDJ == rhs.isLiveDJ
        && lhs.track == rhs.track
        && lhs.artist == rhs.artist
        && lhs.album == rhs.album
        && lhs.dj == rhs.dj
    }
    
    public init() {
        self.connection = ACConnectionState.disconnected
        self.changed = true
        self.isLiveDJ = false
        self.track = ""
        self.artist = ""
        self.album = ""
        self.dj = ""
    }
    
    public init(connection: ACConnectionState, changed: Bool, isLiveDJ: Bool, track: String, artist: String, album: String, dj: String, artwork: URL?) {
        self.connection = connection
        self.changed = changed
        self.isLiveDJ = isLiveDJ
        self.track = track
        self.artist = artist
        self.album = album
        self.dj = dj
        self.artwork = artwork
    }
    
    public var connection: ACConnectionState
    public var changed: Bool
    public var isLiveDJ: Bool
    public var track: String
    public var artist: String
    public var album: String
    public var dj: String
    public var artwork: URL?
}
