//
// Created by Alexander Evsyuchenya on 7/26/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation


class OutputDataSource: NSObject, OutputStreamDelegate {
    let writeMaxLength: Int
    let writeMinLength: Int

    var dataDidSentNotification: (NSData? -> Void)?
    private let mutableSentData: NSMutableData?
    var sentData: NSData? {
        return mutableSentData
    }
    let length: Int
    private var sentLength: Int = 0

    init(length: Int, writeMinLength: Int, writeMaxLength: Int) {
        self.length = length
        mutableSentData = NSMutableData(capacity: Int(length))
        self.writeMinLength = writeMinLength
        self.writeMaxLength = writeMaxLength
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
            mutableSentData?.appendData(data)
        } else {
            stream.close()
            dataDidSentNotification?(sentData)
        }
    }

    func streamDidOpen(stream: Stream) {}

    func streamEndEncountered(stream: Stream) {}

}
