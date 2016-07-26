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
    private var streamingService: StreamService?
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let streamsCount: UInt = 10
        let dataLength: UInt = 1024 * 10

        let isServer = NSString(string: NSProcessInfo.processInfo().arguments[2]).boolValue
        if isServer {
            let server = Server(streamer: Streamer(streamsCount: streamsCount, dataLength: dataLength))
            server.startAdvertising()
            streamingService = server
        } else {
            let client = Client(streamer: Streamer(streamsCount: streamsCount))
            client.startBrowsing()
            streamingService = client
        }
        return true
    }

}

