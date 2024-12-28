//
//  TestHostApp.swift
//  TestHost
//
//  Created by Joe McMahon on 12/26/24.
//

import SwiftUI
import ACWebSocketClient

@main
struct TestHostApp: App {
    let persistenceController = PersistenceController.shared
    let client = AzuracastWebSocketClient(serverName: "example.com", shortCode: "station")

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
