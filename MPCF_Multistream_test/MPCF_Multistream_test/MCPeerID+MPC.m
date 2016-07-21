//
// Created by Alexander Evsyuchenya on 7/21/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

#import "MCPeerID+MPC.h"


@implementation MCPeerID (MPC)

+ (instancetype)createPeer
{
    return [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];;
}


@end