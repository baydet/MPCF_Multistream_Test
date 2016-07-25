//
//  MultipeerSession.m
//  MPCF_Multistream_test
//
//  Created by Alexander Evsyuchenya on 7/21/16.
//  Copyright © 2016 baydet. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "MultipeerSession.h"
#import "DataStream.h"
#import "Constants.h"

@interface MultipeerSession () <MCSessionDelegate>
@property(nonatomic, readwrite) MCSession *mcSession;

@end

@implementation MultipeerSession
{
    int _streamsCount;
}

- (instancetype)initWithPeer:(MCPeerID *)peerID
{
    self = [super init];
    if (self)
    {
        _streamsCount = kStreamsCount;
        self.mcSession = [[MCSession alloc] initWithPeer:peerID];
        self.mcSession.delegate = self;
        self.inputStreams = [@{} mutableCopy];
        self.outputStreams = [@{} mutableCopy];
    }

    return self;
}

- (void)startStreamingToPeer:(MCPeerID *)peerId {

    for (int i = 0; i < _streamsCount; ++i)
    {
        NSString *name = [NSString stringWithFormat:@"%@_out_str#%d", [self.mcSession.myPeerID.displayName substringToIndex:4], i];
        self.outputStreams[name] = [self createAndOpenOutputStreamWithName:name toPeer:peerId dataProvider:[[OutputDataGenerator alloc] init]];
    }
}

- (OutputDataStream *)createAndOpenOutputStreamWithName:(NSString *)name toPeer:(MCPeerID *)peer dataProvider:(id <DataStreamGenerator>)dataProvider
{
    NSError *error;
    NSOutputStream *stream = [self.mcSession startStreamWithName:name toPeer:peer error:&error];
    OutputDataStream *dataStream = [[OutputDataStream alloc] initWithOutputStream:stream dataProvider:dataProvider];
    [dataStream start];

    if (error) {
        NSAssert(NO, @"Error: %@", [error userInfo].description);
    }

    return dataStream;
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateConnecting) {
        NSLog(@"Connecting to %@", peerID.displayName);
    } else if (state == MCSessionStateConnected) {
        NSLog(@"Connected to %@", peerID.displayName);
        [self.delegate session:self didConnectToPeer:peerID];
    } else if (state == MCSessionStateNotConnected) {
        NSLog(@"Disconnected from %@", peerID.displayName);
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{

}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"did receive stream: %@", streamName);
    DataBuffer *buffer = [DataBuffer new];
    InputDataStream *inputDataStream = [[InputDataStream alloc] initWithInputStream:stream dataProcessor:buffer];
    inputDataStream.delegate = buffer;
    [inputDataStream start];
    self.inputStreams[streamName] = inputDataStream;
    if (self.shouldRetranslateStream && ![streamName containsString:@"retr_"]) {
        NSString *name = [NSString stringWithFormat:@"retr_%@", streamName];
        OutputDataStream *dataStream = [self createAndOpenOutputStreamWithName:name toPeer:peerID dataProvider:buffer];
        self.outputStreams[name] = dataStream;
    }
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{

}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{

}


@end
