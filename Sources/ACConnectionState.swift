//
//  ACConnectionState.swift
//  ACWebSocketClient
//
//  Created by Joe McMahon on 12/29/24.
//

import Foundation

public enum ACConnectionState {
    case connected
    case disconnected
    case stationNotFound
    case failedSubscribe
}
