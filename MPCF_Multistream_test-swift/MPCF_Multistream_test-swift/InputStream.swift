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
    weak var inputStreamDelegate: InputStreamDelegate?

    required init(inputStream: NSInputStream, delegate: InputStreamDelegate?) {
        self.inputStream = inputStream
        super.init(stream: inputStream, delegate: delegate)
        inputStreamDelegate = delegate
    }

    func readData(maxLength: Int) -> NSData? {
        let mutableData = NSMutableData()
        var buffer = [UInt8](count: maxLength, repeatedValue: 0)

        let len = inputStream.read(&buffer, maxLength: buffer.count)
        if(len > 0){
            mutableData.appendBytes(&buffer, length: len)
        }

        return mutableData
    }
    
    override func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        super.stream(aStream, handleEvent: eventCode)
        if eventCode == NSStreamEvent.HasBytesAvailable {
            self.inputStreamDelegate?.streamHasBytes(self)
        }
    }
}
