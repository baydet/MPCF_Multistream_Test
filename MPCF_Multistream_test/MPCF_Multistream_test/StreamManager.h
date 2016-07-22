//
// Created by Alexander Evsyuchenya on 7/22/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MultipeerSession;
@class MCPeerID;


@interface StreamManager : NSObject
@property(nonatomic, strong) MCPeerID *peerId;
@property(nonatomic, strong) MultipeerSession *session;
@end