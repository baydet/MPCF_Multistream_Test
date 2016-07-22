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
#import "MultipeerSession.h"

@interface MultipeerServer () <MCNearbyServiceAdvertiserDelegate>
@property(nonatomic, strong) MCNearbyServiceAdvertiser *advertiserAssistant;
@end


@implementation MultipeerServer

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

@end
