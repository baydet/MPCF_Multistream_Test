//
// Created by Alexander Evsyuchenya on 7/25/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Client: NSObject, StreamService, MCNearbyServiceBrowserDelegate {
    private let streamer: Streamer
    let browser: MCNearbyServiceBrowser

    required init(streamer: Streamer = Streamer()) {
        self.streamer = streamer
        browser = MCNearbyServiceBrowser(peer: streamer.peerID, serviceType: ksServiceName)
        super.init()
    }

    func startBrowsing() {
        browser.delegate = self
        browser.startBrowsingForPeers()
        print("started browsing \(streamer.peerID.displayName)")
    }

    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("found peer \(peerID)")
        if !(peerID.displayName.containsString(UIKit.UIDevice.currentDevice().name)) {
            browser.invitePeer(peerID, toSession: self.streamer.session, withContext: nil, timeout: 30)
        }
    }

    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {

    }
}

