//
// Created by Alexander Evsyuchenya on 7/26/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation

class OutputDataSource: NSObject, OutputStreamDelegate {
    let kStreamWriteMaxLength = 512 * 8
    let kStreamWriteMinLength = 512

    var dataDidSentNotification: (NSData? -> Void)?
    private let mutableSentData: NSMutableData?
    var sentData: NSData? {
        return mutableSentData
    }
    let length: Int
    private var sentLength: Int = 0

    init(length: Int = 1024 * 10) {
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
            sentLength += dataChunkLength
            mutableSentData?.appendData(data)
        } else {
            stream.close()
            dataDidSentNotification?(sentData)
        }
    }

    func streamDidOpen(stream: Stream) {}

    func streamEndEncountered(stream: Stream) {}

}
