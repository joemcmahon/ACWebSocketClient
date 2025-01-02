//
//  ViewController.swift
//  ACWebSocketClient
//
//  Created by joemcmahon on 12/28/2024.
//  Copyright (c) 2024 joemcmahon. All rights reserved.
//

import UIKit
import ACWebSocketClient

class ViewController: UIViewController {
    
    @IBOutlet weak var serverNameLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var albumArtURLText: UITextView!
    
    private var client = ACWebSocketClient.shared
    private var lastStatus: ACStreamStatus?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serverNameLabel.text = ""
        albumNameLabel.text = ""
        trackNameLabel.text = ""
        artistNameLabel.text = ""
        albumArtURLText.text = ""
        
        azuracastMetadataSetup()
    }
    
    func azuracastMetadataSetup() {
        let serverName = "demo.azuracast.com"
        serverNameLabel.text = serverName
        let shortCode  = "azuratest_radio"

        client.configurationDidChange(serverName: serverName, shortCode: shortCode)
        client.addSubscriber(callback: handleStreamStatus)
        client.debug(to: 0)    // See ACWebSocketClient for valid values
        client.setDefaultDJ(name: "No DJ")
        print("done")
    }
        
    func handleStreamStatus(status: ACStreamStatus) {
        print("Function callback received")
        if lastStatus != status && status.changed {
            artistNameLabel.text = status.artist
            trackNameLabel.text = status.track
            albumNameLabel.text = status.album
            albumArtURLText.text = status.artwork?.absoluteString
            lastStatus = status
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

