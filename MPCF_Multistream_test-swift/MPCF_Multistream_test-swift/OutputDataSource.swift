//
// Created by Alexander Evsyuchenya on 7/26/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation

class OutputDataSource: NSObject, OutputStreamDelegate {
    let kStreamWriteMaxLength = 512 * 8
    let kStreamWriteMinLength = 512

    let mutableSentData: NSMutableData?
    let length: Int
    private var sentLength: Int = 0

    init(length: Int = 1024 * 200) {
        self.length = length
        mutableSentData = NSMutableData(capacity: length)
    }

    func streamHasSpace(stream: OutputStream) {
        if sentLength < length {
            var dataChunkLength = Int(arc4random_uniform(UInt32(kStreamWriteMaxLength - kStreamWriteMinLength))) + kStreamWriteMinLength
            if (sentLength + dataChunkLength > length) {
                dataChunkLength = length - sentLength
            }
            let data = NSData.randomData(dataChunkLength)
            stream.writeData(data)
            mutableSentData?.appendData(data)
        } else {
            //todo close stream
            //todo notify about end
        }
    }

    func streamDidOpen(stream: Stream) {}
    func streamEndEncountered(stream: Stream) {}
    func streamHasError(stream: Stream) {}

}
