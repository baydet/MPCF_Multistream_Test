//
// Created by Alexander Evsyuchenya on 7/26/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation

func sync(lock: AnyObject, @noescape closure: () -> Void) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

class TranslateDataSource: NSObject, OutputStreamDelegate, InputStreamDelegate {
    let readMaxLength: Int
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

    init(readMaxLength: Int) {
        self.readMaxLength = readMaxLength
    }

    func streamHasSpace(stream: OutputStream) {
        while !(self.buffer.count > 0 || self.isBufferingFinished) {
            NSRunLoop.currentRunLoop().runMode(NSRunLoopCommonModes, beforeDate: NSDate.distantFuture())
        }
        if self.isBufferingFinished && self.buffer.count == 0 {
            stream.close()
            return
        }
        sync(self) {
            let data = self.buffer.removeAtIndex(0)
            stream.writeData(data)
        }
    }
    
    func streamHasBytes(stream: InputStream) {
        guard let data = stream.readData(self.readMaxLength) else {
            return
        }
        sync(self) {
            self.buffer.append(data)
            self.receivedData.appendData(data)
        }
    }
    
    func streamDidOpen(stream: Stream) {        
    }
    
    func streamEndEncountered(stream: Stream) {
        if stream is InputStream {
            isBufferingFinished = true
            dataDidReceivedNotification?(receivedData)
        }
        stream.close()
    }
    
}
