//
//  MultipeerClient.m
//  MPCF_Multistream_test
//
//  Created by Alexander Evsyuchenya on 7/21/16.
//  Copyright © 2016 baydet. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "MultipeerClient.h"
#import "Constants.h"
#import "MCPeerID+MPC.h"
#import "MultipeerSession.h"

@interface MultipeerClient () <MCNearbyServiceBrowserDelegate>
@property(nonatomic, strong) MCPeerID *peerId;
@property(nonatomic, strong) MCNearbyServiceBrowser *browser;
@property(nonatomic, strong) MultipeerSession *session;
@end

@implementation MultipeerClient

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.peerId = [MCPeerID createPeer];
        self.session = [[MultipeerSession alloc] initWithPeer:self.peerId];
        self.session.shouldRetranslateStream = YES;
    }

    return self;
}


- (void)startBrowsing
{
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerId serviceType:SERVICE_NAME];
    self.browser.delegate = self;
    [self.browser startBrowsingForPeers];
    NSLog(@"started browsing");
}

#pragma mark - MCNearbyServiceBrowserDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    [browser invitePeer:peerID toSession:self.session.mcSession withContext:nil timeout:30];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{

}


@end
