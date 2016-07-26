//
// Created by Alexander Evsyuchenya on 7/26/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation

class OutputDataSource: NSObject, OutputStreamDelegate {
    let kStreamWriteMaxLength: UInt = 512 * 8
    let kStreamWriteMinLength: UInt = 512

    var dataDidSentNotification: (NSData? -> Void)?
    private let mutableSentData: NSMutableData?
    var sentData: NSData? {
        return mutableSentData
    }
    let length: UInt
    private var sentLength: UInt = 0

    init(length: UInt) {
        self.length = length
        mutableSentData = NSMutableData(capacity: Int(length))
    }

    func streamHasSpace(stream: OutputStream) {
        if sentLength < length {
            var dataChunkLength = UInt(arc4random_uniform(UInt32(kStreamWriteMaxLength - kStreamWriteMinLength))) + kStreamWriteMinLength
            if (sentLength + dataChunkLength > length) {
                dataChunkLength = length - sentLength
            }
            let data = NSData.randomData(Int(dataChunkLength))
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
