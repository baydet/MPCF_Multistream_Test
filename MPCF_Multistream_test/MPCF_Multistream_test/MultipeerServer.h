//
//  MultipeerServer.h
//  MPCF_Multistream_test
//
//  Created by Alexander Evsyuchenya on 7/21/16.
//  Copyright © 2016 baydet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCSession;
@class MCPeerID;

@interface MultipeerServer : NSObject

- (void)startAdvertise;

@end
