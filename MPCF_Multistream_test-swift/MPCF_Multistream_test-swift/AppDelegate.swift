//
//  AppDelegate.swift
//  MPCF_Multistream_test-swift
//
//  Created by Alexander Evsyuchenya on 7/25/16.
//  Copyright © 2016 baydet. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var server: Server!
    private var client: Client!
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let streamsCount: UInt = 20
        let dataLength: Int = (1024 * 100) / Int(streamsCount)

        let validationFailedBlock: StreamNotificationBlock = { name in
            assert(false, "data is not equal \(name)")
        }
        let replicationCompletedBlock: StreamNotificationBlock = { name in
            print("\(name) completed replication")
        }
        let makeDelays = false

        server = Server(streamer: Streamer(peer: createPeerWithDeviceName("server"), streamsCount: streamsCount, dataLength: dataLength, streamValidationFailed: validationFailedBlock, streamRetranslationCompleted: replicationCompletedBlock, makeDelays: makeDelays))
        server.startAdvertising()

        client = Client(streamer: Streamer(peer: createPeerWithDeviceName("client"), streamsCount: streamsCount, dataLength: dataLength, streamValidationFailed: validationFailedBlock, streamRetranslationCompleted: replicationCompletedBlock, makeDelays: makeDelays))
        client.startBrowsing()

        return true
    }

}