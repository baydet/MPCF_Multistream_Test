//
// Created by Alexander Evsyuchenya on 7/22/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "StreamManager.h"
#import "MultipeerSession.h"
#import "MCPeerID+MPC.h"

@interface StreamManager() <MultipeerSessionDelegate>
@end


@implementation StreamManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.peerId = [MCPeerID createPeer];
        self.session = [[MultipeerSession alloc] initWithPeer:self.peerId];
        self.session.shouldRetranslateStream = YES;
        self.session.delegate = self;
    }
    return self;
}

#pragma mark - MultipeerSessionDelegate

- (void)session:(MultipeerSession *)session didConnectToPeer:(MCPeerID *)peer
{
    [session startStreamingToPeer:peer];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"INPUT\n%@\nOUTPUT\n%@", _session.inputStreams.description, _session.outputStreams.description];
}

@end