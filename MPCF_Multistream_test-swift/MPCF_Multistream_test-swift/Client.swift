//
// Created by Alexander Evsyuchenya on 7/25/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Client: NSObject, StreamService, MCNearbyServiceBrowserDelegate {
    private let streamer: Streamer

    required init(streamer: Streamer) {
        self.streamer = streamer
        super.init()
    }

    func startBrowsing() {
        let browser = MCNearbyServiceBrowser(peer: self.streamer.peerID, serviceType: ksServiceName)
        browser.delegate = self
        browser.startBrowsingForPeers()
        print("started browsing")
    }

    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, toSession: self.streamer.session, withContext: nil, timeout: 30)
    }

    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {

    }
}

