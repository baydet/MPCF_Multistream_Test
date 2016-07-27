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
        sync(self){
            mutableData.appendData(data)
        }
    }

    func isReceivedDataValid(receivedData: NSData) -> Bool {
        return sync(self) {
            let range = NSRange(location: 0, length: receivedData.length)
            let subdata = mutableData.subdataWithRange(range)
            guard subdata.isEqualToData(receivedData) else {
                print("received\n \(receivedData)")
                print("actual\n \(mutableData)")
                return false
            }
            mutableData.replaceBytesInRange(range, withBytes: nil, length: 0)
            return true
        }
    }
}
