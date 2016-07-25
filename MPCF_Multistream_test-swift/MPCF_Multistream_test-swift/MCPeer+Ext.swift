//
// Created by Alexander Evsyuchenya on 7/25/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import UIKit

extension MCPeerID {
    class func currentPeer() -> MCPeerID {
        return MCPeerID(displayName: UIDevice.currentDevice().name)
    }
}