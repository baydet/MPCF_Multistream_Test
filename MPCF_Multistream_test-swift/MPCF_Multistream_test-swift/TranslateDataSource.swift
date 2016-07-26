//
// Created by Alexander Evsyuchenya on 7/26/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation

class TranslateDataSource: NSObject, OutputStreamDelegate, InputStreamDelegate {
    let kStreamReadMaxLength = 512
    private var buffer: [NSData] = []

    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.HasSpaceAvailable:
            break
        default:
            break
        }
    }

    func streamHasSpace(stream: OutputStream) {
        while buffer.count == 0 {}
        let data = buffer.removeAtIndex(0)
        stream.writeData(data)
    }
    
    func streamHasBytes(stream: InputStream) {
        guard let data = stream.readData(kStreamReadMaxLength) else {
            return
        }
        buffer.append(data)
    }
    
    func streamDidOpen(stream: Stream) {        
    }
    
    func streamEndEncountered(stream: Stream) {
    }
    
}
