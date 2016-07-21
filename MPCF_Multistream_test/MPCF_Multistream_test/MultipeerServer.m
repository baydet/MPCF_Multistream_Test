//
//  MultipeerServer.m
//  MPCF_Multistream_test
//
//  Created by Alexander Evsyuchenya on 7/21/16.
//  Copyright © 2016 baydet. All rights reserved.
//

#import "MultipeerServer.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "Constants.h"
#import "MCPeerID+MPC.h"
#import "MultipeerSession.h"

@interface MultipeerServer () <MCNearbyServiceAdvertiserDelegate, MultipeerSessionDelegate>

@property(nonatomic, strong) MultipeerSession *session;
@property(nonatomic, strong) MCPeerID *peerId;
@property(nonatomic, strong) MCNearbyServiceAdvertiser *advertiserAssistant;
@end


@implementation MultipeerServer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.peerId = [MCPeerID createPeer];
        self.session = [[MultipeerSession alloc] initWithPeer:self.peerId];
        self.session.delegate = self;
    }
    return self;
}

- (void)startAdvertise {
    self.advertiserAssistant = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerId discoveryInfo:nil serviceType:SERVICE_NAME];
    self.advertiserAssistant.delegate = self;
    [self.advertiserAssistant startAdvertisingPeer];
    NSLog(@"started advertising");
}


#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler
{
    NSLog(@"received invitation from peer = %@", peerID);
    invitationHandler(YES, self.session.mcSession);
}

#pragma mark - MultipeerSessionDelegate

- (void)session:(MultipeerSession *)session didConnectToPeer:(MCPeerID *)peer
{
    [session startStreamingToPeer:peer];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@\n%@", _session.inputStreams.description, _session.outputStreams.description];
}


@end
