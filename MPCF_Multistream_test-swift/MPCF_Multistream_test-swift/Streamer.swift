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

typealias StreamerCompletionBlock = (sentData: NSData?, receivedData: NSData?, name: String) -> Void
typealias BufferSizes = (minWriteLength: Int, maxWriteLength: Int, maxReadLength: Int)
let defaultBufferSize: BufferSizes = (minWriteLength: 512, maxWriteLength: 512 * 2, maxReadLength: 512 * 2)

class Streamer: NSObject, MCSessionDelegate {
    private let retranslatePrefix = "retr_"

    let peerID: MCPeerID
    let session: MCSession
    let streamsCount: UInt
    let dataLength: Int
    let bufferSizes: BufferSizes

    private let streamTransferCompletion: StreamerCompletionBlock?
    private var outputDataSources: [String : OutputDataSource] = [:]
    private var inputDataSources: [String : TranslateDataSource] = [:]
    private var streams: [Stream] = []

    required init(peer: MCPeerID = MCPeerID.currentPeer(), streamsCount: UInt = 20, dataLength: Int = 1024 * 1024 * 10, streamTransferCompletion: ((sentData: NSData?, receivedData: NSData?, streamName: String) -> Void)? = nil, bufferSizes: BufferSizes = defaultBufferSize) {
        self.peerID = peer
        self.session = MCSession(peer: self.peerID)
        self.streamsCount = streamsCount
        self.dataLength = dataLength
        self.streamTransferCompletion = streamTransferCompletion
        self.bufferSizes = bufferSizes
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
            let outputDataSource = OutputDataSource(length: dataLength, writeMinLength: bufferSizes.minWriteLength, writeMaxLength: bufferSizes.maxWriteLength)
            outputDataSources[name] = outputDataSource
            createAndOpenOutputStream(withName: name, toPeer: peer, outputDelegate: outputDataSource)
        }
    }

    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        let inputProcessor = TranslateDataSource(readMaxLength: bufferSizes.maxReadLength)
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
            stream.start()
            streams.append(stream)
            return stream
        } catch let error {
            assert(false, "cannot start stream: \(error)")
        }
    }

    private func acceptAndOpenInputStream(stream: NSInputStream, withName name: String, inputProcessor: TranslateDataSource) -> InputStream {
        let inputStream = InputStream(inputStream: stream, delegate: inputProcessor)
        inputStream.start()
        streams.append(inputStream)
        if name.containsString(retranslatePrefix) {
            let originalName = name.stringByReplacingOccurrencesOfString(retranslatePrefix, withString: "")
            let sentData = outputDataSources[originalName]?.sentData
            inputProcessor.dataDidReceivedNotification = { receivedData in
                self.streamTransferCompletion?(sentData: sentData, receivedData: receivedData, name: originalName)
            }
            
        }
        return inputStream
    }

    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {}
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {}
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {}
}