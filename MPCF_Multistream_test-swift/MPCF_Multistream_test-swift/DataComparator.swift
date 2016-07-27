//
// Created by Alexander Evsyuchenya on 7/27/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation

protocol DataBufferType: class {
    func appendData(data: NSData)
}

protocol DataValidatorType {
    func isReceivedDataValid(receivedData: NSData) -> Bool
}

class DataValidator: DataBufferType, DataValidatorType {
    private let mutableData = NSMutableData()

    func appendData(data: NSData) {
        mutableData.appendData(data)
    }

    func isReceivedDataValid(receivedData: NSData) -> Bool {
        let range = NSRange(location: 0, length: receivedData.length)
        guard mutableData.subdataWithRange(range).isEqualToData(receivedData) else {
            return false
        }
        mutableData.replaceBytesInRange(range, withBytes: nil, length: 0)
        return true
    }
}
