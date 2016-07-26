//
//  Streamer.swift
//  MPCF_Multistream_test-swift
//
//  Created by Alexander Evsyuchenya on 7/25/16.
//  Copyright © 2016 baydet. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol StreamService {
    init(streamer: Streamer)
}

class Streamer: NSObject, MCSessionDelegate {
    private let retranslatePrefix = "retr_"

    let peerID: MCPeerID
    let session: MCSession
    let streamsCount: Int = 20

    required init(peer: MCPeerID = MCPeerID.currentPeer()) {
        self.peerID = peer;
        self.session = MCSession(peer: self.peerID)
        super.init()
        self.session.delegate = self
    }

    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("\(state) - \(peerID.displayName)")
        switch state {
        case .Connected:
            startStreamingToPeer(peerID)
            break
        default:
            break
        }
    }

    private func startStreamingToPeer(peer: MCPeerID) {
        for i in 0..<streamsCount {
            let name = "\(self.peerID.displayName)_out#\(i)"
            createAndOpenOutputStream(withName: name, toPeer: peer, outputDelegate: OutputDataSource())
//            createOutputStream(name)

            //op
        }
    }

    private func createAndOpenOutputStream(withName name: String, toPeer peer: MCPeerID, outputDelegate: OutputStreamDelegate) -> OutputStream {
        do {
            let nsOutputStream = try session.startStreamWithName(name, toPeer: peer)
            return OutputStream(outputStream: nsOutputStream, delegate: outputDelegate)
        } catch let error {
            assert(false, "cannot start stream: \(error)")
        }
    }

    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        if streamName.containsString(retranslatePrefix) {

        }
    }


    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {}
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {}
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {}
}