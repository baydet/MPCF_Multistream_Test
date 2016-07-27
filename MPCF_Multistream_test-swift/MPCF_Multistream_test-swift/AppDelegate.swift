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
        let dataLength: Int = (1024 * 1024 * 1024) / Int(streamsCount)

        let validationFailedBlock: StreamNotificationBlock = { name in
            assert(false, "data is not equal \(name)")
        }
        let retranslationCompletedBlock: StreamNotificationBlock = { name in
            print("\(name) completed retranslation")
        }
        server = Server(streamer: Streamer(peer: createPeerWithDeviceName("server"), streamsCount: streamsCount, dataLength: dataLength, streamValidationFailed: validationFailedBlock, streamRetranslationCompleted: retranslationCompletedBlock))
        server.startAdvertising()

        client = Client(streamer: Streamer(peer: createPeerWithDeviceName("client"), streamsCount: streamsCount, dataLength: dataLength, streamValidationFailed: validationFailedBlock, streamRetranslationCompleted: retranslationCompletedBlock))
        client.startBrowsing()

        return true
    }

}