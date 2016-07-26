//
// Created by Alexander Evsyuchenya on 7/25/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation
import MultipeerConnectivity

let ksServiceName = "baydet-mltstrm"

class Server: NSObject, StreamService, MCNearbyServiceAdvertiserDelegate {
    private let streamer: Streamer

    required init(streamer: Streamer = Streamer()) {
        self.streamer = streamer
        super.init()
    }

    func startAdvertising() {
        let advertiser = MCNearbyServiceAdvertiser(peer: streamer.peerID, discoveryInfo: nil, serviceType: ksServiceName)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        print("started advertising")
    }

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        print("received invitation from peer \(peerID.displayName)")
        invitationHandler(true, streamer.session)
    }

}
