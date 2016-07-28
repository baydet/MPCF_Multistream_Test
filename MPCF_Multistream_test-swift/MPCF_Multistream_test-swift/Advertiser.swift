//
// Created by Alexander Evsyuchenya on 7/25/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation
import MultipeerConnectivity

let ksServiceName = "baydet-mltstrm"

class Advertiser: NSObject, StreamService, MCNearbyServiceAdvertiserDelegate {
    let streamer: Streamer
    private let advertiser: MCNearbyServiceAdvertiser

    required init(streamer: Streamer = Streamer()) {
        self.streamer = streamer
        self.advertiser = MCNearbyServiceAdvertiser(peer: streamer.peerID, discoveryInfo: nil, serviceType: ksServiceName)
        super.init()
    }

    func start() {
        startAdvertising()
    }

    func stopDiscovering() {
        advertiser.stopAdvertisingPeer()
    }

    func startAdvertising() {
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        date_print("started advertising \(streamer.peerID.displayName)")
    }

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        date_print("received invitation from peer \(peerID.displayName)")
        invitationHandler(true, streamer.session)
    }

}
