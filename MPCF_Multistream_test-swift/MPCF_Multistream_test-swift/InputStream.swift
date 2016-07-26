//
// Created by Alexander Evsyuchenya on 7/26/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation

protocol InputStreamDelegate: StreamDelegate {
    func streamHasBytes(stream: InputStream)
}

class InputStream: Stream {
    private let inputStream: NSInputStream
    private weak var inputStreamDelegate: InputStreamDelegate?

    required init(inputStream: NSInputStream, delegate: InputStreamDelegate?) {
        self.inputStream = inputStream
        super.init(stream: inputStream, delegate: delegate)
    }

    func readData() -> NSData {
        return NSData()
//        self.inputStream.rea
    }
    
    override func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        super.stream(aStream, handleEvent: eventCode)
        if eventCode == NSStreamEvent.HasBytesAvailable {
            self.inputStreamDelegate?.streamHasBytes(self)
        }
    }
}
