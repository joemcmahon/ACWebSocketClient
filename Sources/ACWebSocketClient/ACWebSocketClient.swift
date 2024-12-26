//
//  AzuracastWebSocketClient.swift
//
//  Created by Joe McMahon on 12/18/24.
//

import Foundation
import Combine

public typealias MetadataCallback<T> = (T) -> Void

public class AzuracastWebSocketClient: ObservableObject {
    // Anyone subscribed to the metadata stream
    private var subscribers: [MetadataCallback<StreamStatus>] = []
    
    var status = StreamStatus()
    
    @Published var nowPlayingData: [String: Any]? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession = URLSession(configuration: .default)
    private var webSocketURL: URL?

    
    var serverName: String?
    var shortCode: String?
    
    private var lastResult: StreamStatus?
    
    /// Add a subscriber for metadata updates
    func addSubscriber(callback: @escaping MetadataCallback<StreamStatus>) {
            subscribers.append(callback)
    }

    /// Notify all suscribers when an update occurs
    private func notifySubscribers(with data: StreamStatus) {
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
        self.lastResult = StreamStatus()
    }
    
    /// Connects to the WebSocket API and sends the subscription message.
    public func connect() {
        if status.isConnected { disconnect() }
        webSocketTask = urlSession.webSocketTask(with: self.webSocketURL!)
        webSocketTask?.resume()
        DispatchQueue.main.async {
            self.status.isConnected = true
        }
        
        sendSubscriptionMessage()
        listenForMessages()
    }
    
    /// Disconnects from the WebSocket API.
    public func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        DispatchQueue.main.async {
            self.status.isConnected = false
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
            status.isConnected = false
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
                    self.status.isConnected = false
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
            let parser = ParseWebSocketData(data: data, defaultDJ: "Spud")
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
