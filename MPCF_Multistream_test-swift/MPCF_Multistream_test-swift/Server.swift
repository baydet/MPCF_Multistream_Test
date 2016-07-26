//
// Created by Alexander Evsyuchenya on 7/25/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation
import MultipeerConnectivity

let ksServiceName = "baydet-mltstrm"

class Server: NSObject, StreamService, MCNearbyServiceAdvertiserDelegate {
    private let streamer: Streamer
    private let advertiser: MCNearbyServiceAdvertiser

    required init(streamer: Streamer = Streamer()) {
        self.streamer = streamer
        self.advertiser = MCNearbyServiceAdvertiser(peer: streamer.peerID, discoveryInfo: nil, serviceType: ksServiceName)
        super.init()
    }

    func startAdvertising() {
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        print("started advertising \(streamer.peerID.displayName)")
    }

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        print("received invitation from peer \(peerID.displayName)")
        invitationHandler(true, streamer.session)
    }

}
