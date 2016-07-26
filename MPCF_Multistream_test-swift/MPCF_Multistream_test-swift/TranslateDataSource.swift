//
// Created by Alexander Evsyuchenya on 7/26/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation

class TranslateDataSource: NSObject, OutputStreamDelegate, InputStreamDelegate {
    let kStreamReadMaxLength = 512
    private var buffer: [NSData] = []
    private let receivedData = NSMutableData()
    private var isBufferingFinished: Bool = false

    var dataDidReceivedNotification: (NSData? -> Void)?
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.HasSpaceAvailable:
            break
        default:
            break
        }
    }

    func streamHasSpace(stream: OutputStream) {
        while self.buffer.count == 0 {
            if isBufferingFinished {
                stream.close()
                return
            }
        }
        let data = self.buffer.removeAtIndex(0)
        stream.writeData(data)
    }
    
    func streamHasBytes(stream: InputStream) {
        guard let data = stream.readData(kStreamReadMaxLength) else {
            return
        }
        buffer.append(data)
        receivedData.appendData(data)
    }
    
    func streamDidOpen(stream: Stream) {        
    }
    
    func streamEndEncountered(stream: Stream) {
        stream.close()
        if stream is InputStream {
            isBufferingFinished = true
            dataDidReceivedNotification?(receivedData)
        }
    }
    
}
