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

        let isServer = NSString(string: NSProcessInfo.processInfo().arguments[2]).boolValue
        if isServer {
            let server = Server()
            server.startAdvertising()
            streamingService = server
        } else {
            let client = Client()
            client.startBrowsing()
            streamingService = client
        }
        print(streamingService)
        return true
    }

}

