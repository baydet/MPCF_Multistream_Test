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
    private var validatedDataLength: Int = 0

    func appendData(data: NSData) {
        sync(self){
            mutableData.appendData(data)
        }
    }

    func isReceivedDataValid(receivedData: NSData) -> Bool {
        return sync(self) {
            let range = NSRange(location: 0, length: receivedData.length)
            let subdata = mutableData.subdataWithRange(range)
            guard subdata.isEqualToData(receivedData) else {
                date_print("received\n \(receivedData)")
                date_print("actual\n \(mutableData)")
                return false
            }
            mutableData.replaceBytesInRange(range, withBytes: nil, length: 0)
            validatedDataLength += receivedData.length
            return true
        }
    }

    var validationCompleted: Bool {
        print("validated length \(validatedDataLength)")
        return mutableData.length == 0
    }
}
