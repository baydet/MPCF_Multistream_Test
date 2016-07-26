//
// Created by Alexander Evsyuchenya on 7/26/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation

protocol StreamDelegate: class {
    func streamDidOpen(stream: Stream)
    func streamEndEncountered(stream: Stream)
    func streamHasError(stream: Stream)
}

class Stream: NSObject, NSStreamDelegate {
    private let stream: NSStream
    private var streamThread: NSThread?
    private weak var delegate: StreamDelegate?

    init(stream: NSStream, delegate: StreamDelegate?) {
        self.stream = stream
        self.delegate = delegate
        super.init()
    }

    @objc private func run() {
        autoreleasepool {
            self.stream.delegate = self
            self.stream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            self.stream.open()

            NSRunLoop.currentRunLoop().runUntilDate(NSDate.distantFuture())
        }
    }

    @objc func start() {
        if !NSThread.currentThread().isEqual(NSThread.mainThread()) {
            return performSelectorOnMainThread(#selector(start), withObject: nil, waitUntilDone: true)
        }

        streamThread = NSThread(target: self, selector: #selector(run), object: nil)
        streamThread?.start()
    }

    func close() {
        stream.close()
    }

    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.OpenCompleted:
            delegate?.streamDidOpen(self)
        case NSStreamEvent.EndEncountered:
            delegate?.streamEndEncountered(self)
        case NSStreamEvent.ErrorOccurred:
            delegate?.streamHasError(self)
        default:
            break
        }
    }
}
