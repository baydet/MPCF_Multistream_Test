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
    var streamer: Streamer { get }
    init(streamer: Streamer)
    func start()
    func stopDiscovering()
}

typealias StreamNotificationBlock = (streamName: String) -> Void
typealias BufferSizes = (minWriteLength: Int, maxWriteLength: Int, maxReadLength: Int)
let defaultBufferSize: BufferSizes = (minWriteLength: 512, maxWriteLength: 512 * 2, maxReadLength: 512 * 2)

class Streamer: NSObject, MCSessionDelegate {
    private let replicaPrefix = "repl_"

    let peerID: MCPeerID
    let session: MCSession
    let streamsCount: UInt
    let dataLength: Int
    let bufferSizes: BufferSizes
    let makeDelays: Bool
    private var globalCounter: Int = 0
    var didStartedStreaming: () -> () = {  }
    var didConnectToPeer: (Streamer, MCPeerID) -> () = { streamer, peer in
        streamer.startStreamingToPeer(peer)
    }

    private let streamValidationFailed: StreamNotificationBlock?
    private let streamRetranslationCompleted: StreamNotificationBlock?
    private var outputDataSources: [String : (OutputDataSource, DataValidator)] = [:]
    private var inputDataSources: [String :ReplicateDataSource] = [:]
    private var streams: [Stream] = []

    required init(peer: MCPeerID = createPeerWithDeviceName(), streamsCount: UInt = 20, dataLength: Int = 1024 * 1024 * 50, streamValidationFailed: (StreamNotificationBlock)? = nil, streamRetranslationCompleted: (StreamNotificationBlock)? = nil, bufferSizes: BufferSizes = defaultBufferSize, makeDelays: Bool = false) {
        self.peerID = peer
        self.session = MCSession(peer: self.peerID)
        self.streamsCount = streamsCount
        self.dataLength = dataLength
        self.streamValidationFailed = streamValidationFailed
        self.streamRetranslationCompleted = streamRetranslationCompleted
        self.bufferSizes = bufferSizes
        self.makeDelays = makeDelays
        super.init()
        self.session.delegate = self
    }

    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        date_print("\(self.peerID.displayName) \(state.rawValue) - \(peerID.displayName)")
        switch state {
        case .Connected:
            didConnectToPeer(self, peerID)
            break
        default:
            break
        }
    }

    func startStreamingToPeer(peer: MCPeerID) {
        date_print("start streaming \(peer)")
        for i in 0..<streamsCount {
            let name = "\(self.peerID.displayName)_\(globalCounter)_out#\(i)"
            let buffer = DataValidator()
            let outputDataSource = OutputDataSource(buffer: buffer, length: dataLength, writeMinLength: bufferSizes.minWriteLength, writeMaxLength: bufferSizes.maxWriteLength)
            outputDataSources[name] = (outputDataSource, buffer)
            do {
                try createAndOpenOutputStream(withName: name, toPeer: peer, outputDelegate: outputDataSource)
            } catch let error {
                print("cannot start stream: \(error)")
            }
        }
        globalCounter += 1
        didStartedStreaming()
    }

    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        let inputProcessor = ReplicateDataSource(readMaxLength: bufferSizes.maxReadLength, dataValidator: validatorForStream(withName: streamName))
        acceptAndOpenInputStream(stream, withName: streamName, inputProcessor: inputProcessor)
        inputDataSources[streamName] = inputProcessor
        if !isRetranslatedStream(streamName) {
            let replicatedStreamName = replicaPrefix + streamName
            do {
                try createAndOpenOutputStream(withName: replicatedStreamName, toPeer: peerID, outputDelegate: inputProcessor)
            } catch let error {
                print("cannot start stream: \(error)")
            }
        } else {
            inputProcessor.receivingCompleted = { [weak self] in
                let origName = streamName.stringByReplacingOccurrencesOfString(self!.replicaPrefix, withString: "")
                if !self!.outputDataSources[origName]!.1.validationCompleted {
                    date_print("validation not finished \(origName)")
                }
                self?.streamRetranslationCompleted?(streamName: streamName)
            }
        }
    }

    private func createAndOpenOutputStream(withName name: String, toPeer peer: MCPeerID, outputDelegate: OutputStreamDelegate) throws -> OutputStream {
        let nsOutputStream = try session.startStreamWithName(name, toPeer: peer)
        let stream = OutputStream(outputStream: nsOutputStream, delegate: outputDelegate, makeRandomDelay: self.makeDelays)
        stream.start()
        streams.append(stream)
        return stream
    }

    private func acceptAndOpenInputStream(stream: NSInputStream, withName name: String, inputProcessor: ReplicateDataSource) -> InputStream {
        let inputStream = InputStream(inputStream: stream, delegate: inputProcessor)
        inputStream.start()
        streams.append(inputStream)
        return inputStream
    }

    private func validatorForStream(withName name: String) -> (NSData -> Bool)? {
        if isRetranslatedStream(name) {
            let originalName = name.stringByReplacingOccurrencesOfString(replicaPrefix, withString: "")
            if let validator = outputDataSources[originalName]?.1 {
                return { [weak self] data in
                    let res = validator.isReceivedDataValid(data)
                    if !res {
                        self?.streamValidationFailed?(streamName: originalName)
                    }
                    return res
                }
            }
        }
        return nil
    }

    private func isRetranslatedStream(name: String) -> Bool {
        return name.containsString(replicaPrefix)
    }

    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {}
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {}
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {}
}