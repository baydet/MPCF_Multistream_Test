//
// Created by Alexander Evsyuchenya on 7/26/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation


extension NSData {
    class func randomData(length: Int) -> NSData {
        let bytes = [UInt8](count: length, repeatedValue: 0).map { _ in arc4random() }
        return NSData(bytes: bytes, length: bytes.count * sizeof(UInt8))
    }
}