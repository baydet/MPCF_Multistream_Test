//
// Created by Alexander Evsyuchenya on 7/26/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation

class TranslateDataSource: NSObject, OutputStreamDelegate, InputStreamDelegate {
    let kStreamReadMaxLength = 512

    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.HasSpaceAvailable:
            break;
        default:
            break;
        }
    }
    
    func streamHasSpace(stream: OutputStream) {
//        stream.writeData(<#T##data: NSData##NSData#>)
    }
    
    func streamHasBytes(stream: InputStream) {
        stream.readData()
    }
    
    func streamDidOpen(stream: Stream) {        
    }
    
    func streamEndEncountered(stream: Stream) {
    }
    
    func streamHasError(stream: Stream) {
    }
}
