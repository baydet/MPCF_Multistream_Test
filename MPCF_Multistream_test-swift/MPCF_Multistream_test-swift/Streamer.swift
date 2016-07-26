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
    private var outputDataSources: [String : OutputStreamDelegate] = [:]
    private var inputDataSources: [String : InputStreamDelegate] = [:]
    private var streams: [Stream] = []

    required init(peer: MCPeerID = MCPeerID.currentPeer()) {
        self.peerID = peer
        self.session = MCSession(peer: self.peerID)
        super.init()
        self.session.delegate = self
    }

    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("\(state.rawValue) - \(peerID.displayName)")
        switch state {
        case .Connected:
            startStreamingToPeer(peerID)
            break
        default:
            break
        }
    }

    private func startStreamingToPeer(peer: MCPeerID) {
        print("start streaming")
        for i in 0..<streamsCount {
            let name = "\(self.peerID.displayName)_out#\(i)"
            let outputDataSource = OutputDataSource()
            createAndOpenOutputStream(withName: name, toPeer: peer, outputDelegate: outputDataSource)
        }
    }

    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        let inputProcessor = TranslateDataSource()
        acceptAndOpenInputStream(stream, withName: streamName, inputProcessor: inputProcessor)
        inputDataSources[streamName] = inputProcessor
        if !streamName.containsString(retranslatePrefix) {
            let retranslatedStreamName = retranslatePrefix + streamName
            createAndOpenOutputStream(withName: retranslatedStreamName, toPeer: peerID, outputDelegate: inputProcessor)
        }
    }

    private func createAndOpenOutputStream(withName name: String, toPeer peer: MCPeerID, outputDelegate: OutputStreamDelegate) -> OutputStream {
        do {
            let nsOutputStream = try session.startStreamWithName(name, toPeer: peer)
            let stream = OutputStream(outputStream: nsOutputStream, delegate: outputDelegate)
            outputDataSources[name] = outputDelegate
            stream.start()
            streams.append(stream)
            return stream
        } catch let error {
            assert(false, "cannot start stream: \(error)")
        }
    }

    private func acceptAndOpenInputStream(stream: NSInputStream, withName name: String, inputProcessor: InputStreamDelegate) -> InputStream {
        let inputStream = InputStream(inputStream: stream, delegate: inputProcessor)
        inputStream.start()
        streams.append(inputStream)
        if name.containsString(retranslatePrefix) {
            //todo compare data on completion
        }
        return inputStream
    }


    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {}
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {}
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {}
}