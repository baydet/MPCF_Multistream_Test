//
// Created by Alexander Evsyuchenya on 7/26/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation

protocol OutputStreamDelegate: StreamDelegate {
    func streamHasSpace(stream: OutputStream)
}

class OutputStream: Stream {
    private let outputStream: NSOutputStream
    private weak var outputStreamDelegate: OutputStreamDelegate?

    required init(outputStream: NSOutputStream, delegate: OutputStreamDelegate?) {
        self.outputStream = outputStream
        super.init(stream: outputStream, delegate: delegate)
        outputStreamDelegate = delegate
    }

    func writeData(data: NSData) -> Int {
        print("write")
        return outputStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }

    override func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        super.stream(aStream, handleEvent: eventCode)
        if eventCode == NSStreamEvent.HasSpaceAvailable {
            self.outputStreamDelegate?.streamHasSpace(self)
        }
    }
}
