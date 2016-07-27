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
    private var isBufferingFinished: Bool = false
    private let dataValidator: ((NSData) -> Bool)?
    var receivingCompleted: (() -> Void)?

    init(readMaxLength: Int, dataValidator:((NSData) -> Bool)? = nil) {
        self.readMaxLength = readMaxLength
        self.dataValidator = dataValidator
    }

    func streamHasSpace(stream: OutputStream) {
        while !(self.buffer.count > 0 || self.isBufferingFinished) {
            /* I replaced busy waiting with this code. In this loop RunLoop checking is there is some other job for him.
            And If there is no job this loop continues. If it necessary I can replace it with more complex Provider Customer multithread logic*/
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
            if let dataValidator = dataValidator where dataValidator(data) == false {
                isBufferingFinished = true
                stream.close()
            }
        }
    }
    
    func streamDidOpen(stream: Stream) {        
    }
    
    func streamEndEncountered(stream: Stream) {
        if stream is InputStream {
            isBufferingFinished = true
            receivingCompleted?()
        }
        stream.close()
    }
    
}
