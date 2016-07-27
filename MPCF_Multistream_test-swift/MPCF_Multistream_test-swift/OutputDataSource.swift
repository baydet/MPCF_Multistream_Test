//
// Created by Alexander Evsyuchenya on 7/26/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation


class OutputDataSource: NSObject, OutputStreamDelegate {
    let writeMaxLength: Int
    let writeMinLength: Int

    let buffer: DataBufferType
    let length: Int
    private var sentLength: Int = 0

    init(buffer: DataBufferType, length: Int, writeMinLength: Int, writeMaxLength: Int) {
        self.length = length
        self.writeMinLength = writeMinLength
        self.writeMaxLength = writeMaxLength
        self.buffer = buffer
    }

    func streamHasSpace(stream: OutputStream) {
        if sentLength < length {
            var dataChunkLength = Int(arc4random_uniform(UInt32(writeMaxLength - writeMinLength))) + writeMinLength
            if (sentLength + dataChunkLength > length) {
                dataChunkLength = length - sentLength
            }
            let data = NSData.randomData(Int(dataChunkLength))
            stream.writeData(data)
            sentLength += dataChunkLength
            buffer.appendData(data)
        } else {
            stream.close()
        }
    }

    func streamDidOpen(stream: Stream) {}

    func streamEndEncountered(stream: Stream) {}

}
