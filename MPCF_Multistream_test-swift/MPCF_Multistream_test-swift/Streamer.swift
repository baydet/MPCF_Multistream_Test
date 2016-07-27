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

typealias StreamNotificationBlock = (streamName: String) -> Void
typealias BufferSizes = (minWriteLength: Int, maxWriteLength: Int, maxReadLength: Int)
let defaultBufferSize: BufferSizes = (minWriteLength: 512, maxWriteLength: 512 * 2, maxReadLength: 512 * 2)

class Streamer: NSObject, MCSessionDelegate {
    private let retranslatePrefix = "retr_"

    let peerID: MCPeerID
    let session: MCSession
    let streamsCount: UInt
    let dataLength: Int
    let bufferSizes: BufferSizes

    private let streamValidationFailed: StreamNotificationBlock?
    private let streamRetranslationCompleted: StreamNotificationBlock?
    private var outputDataSources: [String : (OutputDataSource, DataValidator)] = [:]
    private var inputDataSources: [String : TranslateDataSource] = [:]
    private var streams: [Stream] = []

    required init(peer: MCPeerID = createPeerWithDeviceName(), streamsCount: UInt = 20, dataLength: Int = 1024 * 1024 * 10, streamValidationFailed: (StreamNotificationBlock)? = nil, streamRetranslationCompleted: (StreamNotificationBlock)? = nil, bufferSizes: BufferSizes = defaultBufferSize) {
        self.peerID = peer
        self.session = MCSession(peer: self.peerID)
        self.streamsCount = streamsCount
        self.dataLength = dataLength
        self.streamValidationFailed = streamValidationFailed
        self.streamRetranslationCompleted = streamRetranslationCompleted
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
            let buffer = DataValidator()
            let outputDataSource = OutputDataSource(buffer: buffer, length: dataLength, writeMinLength: bufferSizes.minWriteLength, writeMaxLength: bufferSizes.maxWriteLength)
            outputDataSources[name] = (outputDataSource, buffer)
            createAndOpenOutputStream(withName: name, toPeer: peer, outputDelegate: outputDataSource)
        }
    }

    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        let inputProcessor = TranslateDataSource(readMaxLength: bufferSizes.maxReadLength, dataValidator: validatorForStream(withName: streamName))
        acceptAndOpenInputStream(stream, withName: streamName, inputProcessor: inputProcessor)
        inputDataSources[streamName] = inputProcessor
        if !isRetranslatedStream(streamName) {
            let retranslatedStreamName = retranslatePrefix + streamName
            createAndOpenOutputStream(withName: retranslatedStreamName, toPeer: peerID, outputDelegate: inputProcessor)
        } else {
            inputProcessor.receivingCompleted = { [weak self] in
//                let originalName = streamName.stringByReplacingOccurrencesOfString(retranslatePrefix, withString: "")
//                let validator = self!.outputDataSources[originalName]!.1
//                logv
                self?.streamRetranslationCompleted?(streamName: streamName)
            }
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
        return inputStream
    }

    private func validatorForStream(withName name: String) -> (NSData -> Bool)? {
        if isRetranslatedStream(name) {
            let originalName = name.stringByReplacingOccurrencesOfString(retranslatePrefix, withString: "")
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
        return name.containsString(retranslatePrefix)
    }

    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {}
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {}
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {}
}