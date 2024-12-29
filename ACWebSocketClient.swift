//
//  ACWebSocketClient.swift
//
//  Created by Joe McMahon on 12/18/24.
//

import Foundation
import Combine

public typealias MetadataCallback<T> = (T) -> Void

public class ACWebSocketClient: ObservableObject {
    // Anyone subscribed to the metadata stream
    private var subscribers: [MetadataCallback<ACStreamStatus>] = []
    
    var status = ACStreamStatus()
        
    private var cancellables = Set<AnyCancellable>()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession = URLSession(configuration: .default)
    private var webSocketURL: URL?

    
    var serverName: String?
    var shortCode: String?
    var defaultDJ: String?
    var debugLevel: Int = 0
    
    private var lastResult: ACStreamStatus?
        
    public init (serverName: String?, shortCode: String?, defaultDJ: String? = "") {
        if let defaultDJ {
            self.defaultDJ = defaultDJ
        }
        if let serverName {
            self.serverName = serverName
        }
        if let shortCode {
            self.shortCode = shortCode
        }
    }

    /// Add a subscriber for metadata updates
    public func addSubscriber(callback: @escaping MetadataCallback<ACStreamStatus>) {
            subscribers.append(callback)
    }

    public func setDefaultDJ(name: String) {
        defaultDJ = name
    }
    
    public func debug(to: Int) {
        debugLevel = to
    }
    
    /// Notify all suscribers when an update occurs
    private func notifySubscribers(with data: ACStreamStatus) {
        for callback in subscribers {
            callback(data)
        }
    }
    
    
    /// Use configurationDidChange() to (re)configure an AzuracastWebSocketClient.
    public func configurationDidChange(serverName: String, shortCode: String) {
        self.serverName = serverName
        self.shortCode = shortCode
        self.disconnect()
        guard let webSocketURL = URL(string: "wss://\(String(describing: serverName))/api/live/nowplaying/websocket") else {
                fatalError("Invalid server name for WebSocket URL")
        }
        self.webSocketURL = webSocketURL
        self.connect()
        self.lastResult = ACStreamStatus()
    }
    
    /// Connects to the WebSocket API and sends the subscription message.
    public func connect() {
        if status.connection == ACConnectionState.connected { disconnect() }
        webSocketTask = urlSession.webSocketTask(with: self.webSocketURL!)
        webSocketTask?.resume()
        DispatchQueue.main.async {
            self.status.connection = ACConnectionState.connected
        }
        
        sendSubscriptionMessage()
        listenForMessages()
    }
    
    /// Disconnects from the WebSocket API.
    public func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        DispatchQueue.main.async {
            self.status.connection = ACConnectionState.disconnected
        }
    }
    
    /// Sends the subscription message for the specified station.
    private func sendSubscriptionMessage() {
        guard let webSocketTask = webSocketTask else { return }
        
        let subscriptionMessage = ["subs": ["station:\(self.shortCode!)": ["recover": true]]]
        if let jsonData = try? JSONSerialization.data(withJSONObject: subscriptionMessage, options: []) {
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            webSocketTask.send(.string(jsonString)) { error in
                if let error = error {
                    print("Failed to send subscription message: \(error)")
                } else {
                    print("Subscription message sent: \(jsonString)")
                }
            }
        } else {
            print("Failed to encode subscription message")
            status.connection = ACConnectionState.failedSubscribe
        }
    }
    
    /// Listens for incoming messages from the WebSocket server.
    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleMessage(text)
                case .data(let data):
                    print("Received binary data: \(data)")
                @unknown default:
                    print("Received unknown message type")
                }
            case .failure(let error):
                print("WebSocket error: \(error)")
                DispatchQueue.main.async {
                    self.status.connection = ACConnectionState.disconnected
                }
            }
            
            // Keep listening for new messages
            self.listenForMessages()
        }
    }
    
    /// Handles incoming messages and updates the `nowPlayingData`.
    private func handleMessage(_ message: String) {
        
        guard let data = message.data(using: .utf8) else {
            print("Failed to decode message to data")
            return
        }
        
        lastResult?.album = status.album
        lastResult?.artist = status.artist
        lastResult?.track = status.track
        lastResult?.artwork = status.artwork
        lastResult?.dj = status.dj
        
        do {
            print("parsing metadata")
            let parser = ParseWebSocketData(data: data, defaultDJ: defaultDJ)
            parser.debug(to: debugLevel)
            
            // I can hard-unwrap this because I had to have a value to connect at all.
            let result = try parser.parse(shortCode: shortCode!)
            DispatchQueue.main.async {
                if result != self.lastResult {
                    self.status = result
                    self.notifySubscribers(with: self.status)
                } else {
                    print("no change, no set")
                }
            }
        } catch {
            print("Failed to parse JSON: \(error)")
        }
        
    }
}
