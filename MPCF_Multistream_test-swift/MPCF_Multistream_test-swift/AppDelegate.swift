//
//  AppDelegate.swift
//  MPCF_Multistream_test-swift
//
//  Created by Alexander Evsyuchenya on 7/25/16.
//  Copyright © 2016 baydet. All rights reserved.
//

import UIKit

func date_print(items: Any...){
    print("\(NSDate()):  \(items)")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var masters: [Advertiser] = []
    private var slaes: Browser!
    var window: UIWindow?

    let tests: [String : [String] -> ()] = [
        "1" : testHighLoadConnectA1B1B2A2,
        "2" : testConnectA1B1B2A2AndBroadcast,
        "3" : testOneMasterManySlavesConnection,
        "4" : testPartiallyBusyConnection,
        "5" : test3Peers,
        "6" : testCrazy3Peers,
    ]

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        date_print("streamsCount: \(streamsCount)\n size: \(dataLength)")
        var arguments = NSProcessInfo.processInfo().arguments
        let testName = arguments[1]
        arguments.replaceRange(0...1, with: [])
        tests[testName]!(arguments)

        return true
    }

}

let streamsCount: UInt = 2
let dataLength: Int = 1024 * 200

let validationFailedBlock: StreamNotificationBlock = { name in
    dispatch_async(dispatch_get_main_queue()) {
        assert(false, "data is not equal \(name)")
    }
}
let replicationCompletedBlock: StreamNotificationBlock = { name in
    dispatch_async(dispatch_get_main_queue()) {
        date_print("\(name) completed replication")
    }
}

private func createService(isMaster: Bool, name: String, bufferSizes: BufferSizes = defaultBufferSize) -> StreamService {
    let streamer = Streamer(peer: createPeerWithDeviceName(name), streamsCount: streamsCount, dataLength: dataLength, streamValidationFailed: validationFailedBlock, streamRetranslationCompleted: replicationCompletedBlock, bufferSizes: bufferSizes)
    if isMaster {
        return Advertiser(streamer: streamer)
    } else {
        return Browser(streamer: streamer)
    }
}

/**
    ⁃	create A1 <-> B1
    ⁃	create N sessions with high load
    ⁃	try to establish B2<->A2 and start broadcast
*/
func testHighLoadConnectA1B1B2A2(arguments: [String]) {
    let isMaster = NSString(string: arguments[0]).boolValue
    let finished = false
    var service1: StreamService!

    let name = isMaster ? "m1" : "s1"
    let streamService = createService(isMaster, name: name)
    streamService.streamer.didStartedStreaming = {
        let name = isMaster ? "s2" : "m2"
        service1 = createService(!isMaster, name: name)
        service1.start()
    }

    date_print(streamService)
    streamService.start()

    while !finished {
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture())
    }
}

/**
    ⁃	create A1<->B1
    ⁃	wait for B2<->A2 connect
    ⁃	start broadcast A1<->B1 B2<->A2
*/
func testConnectA1B1B2A2AndBroadcast(arguments: [String]) {
    let isMaster = NSString(string: arguments[0]).boolValue
    let finished = false
    var service1: StreamService!

    let name = isMaster ? "m1" : "s1"
    let streamService = createService(isMaster, name: name)
    streamService.streamer.didConnectToPeer = { info in
            let name = isMaster ? "s2" : "m2"
            service1 = createService(!isMaster, name: name)
            service1.start()
        service1.streamer.didStartedStreaming = {
            info.0.startStreamingToPeer(info.1)
        }
    }

    date_print(streamService)
    streamService.start()

    while !finished {
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture())
    }
}

/**

*/
func testOneMasterManySlavesConnection(arguments: [String]) {
    let isMaster = NSString(string: arguments[0]).boolValue
    var services: [StreamService] = []

    var counter = 0
    let max = isMaster ? 1 : 3
    while (counter < max) {
        let name = isMaster ? "m\(counter)" : "s\(counter)"
        let streamService = createService(isMaster, name: name)
        streamService.start()
        streamService.streamer.didConnectToPeer = { _ in

        }
        services.append(streamService)
        counter += 1
    }

    while true {
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture())
    }
}

func testPartiallyBusyConnection(arguments: [String]) {
    let isMaster = NSString(string: arguments[0]).boolValue
    var service1: StreamService!

    let name = isMaster ? "m1" : "s1"
    let buffer: BufferSizes = (minWriteLength: 2, maxWriteLength: 1024, maxReadLength: 1024)
    date_print(buffer)
    let streamService = createService(isMaster, name: name, bufferSizes: buffer)
    streamService.streamer.didStartedStreaming = {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(4 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            let name = isMaster ? "s2" : "m2"
            service1 = createService(!isMaster, name: name)
            service1.start()
        }
    }

    date_print(streamService)
    streamService.start()

    while true {
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture())
    }
}

func test3Peers(arguments: [String]) {
    let isMaster = NSString(string: arguments[0]).boolValue
    var service1: StreamService!

    let name = isMaster ? "m1" : "s1"
    let buffer: BufferSizes = (minWriteLength: 2, maxWriteLength: 64, maxReadLength: 64)
    date_print(buffer)
    let streamService = createService(isMaster, name: name, bufferSizes: buffer)
    streamService.streamer.didStartedStreaming = {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {

            streamService.stopDiscovering()

            if isMaster {
                let name = isMaster ? "m2" : "s2"
                service1 = createService(isMaster, name: name)
                service1.start()
            }
        }
    }

    date_print(streamService)
    streamService.start()

    while true {
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture())
    }
}

//test crazy data flows
func testCrazy3Peers(arguments: [String]) {
    let isMaster = NSString(string: arguments[0]).boolValue
    let finished = false
    var service1: StreamService!

    let name = isMaster ? "m1" : "s1"
    let streamService = createService(isMaster, name: name)
    streamService.streamer.didConnectToPeer = { info in
        let name = isMaster ? "s2" : "m2"
        service1 = createService(!isMaster, name: name)
        service1.start()
        service1.streamer.didStartedStreaming = {
            info.0.startStreamingToPeer(info.1)
        }
    }

    date_print(streamService)
    streamService.start()

    while true {
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture())
    }
}