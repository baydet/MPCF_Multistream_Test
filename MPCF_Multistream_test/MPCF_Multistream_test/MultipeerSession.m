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
#import "InputDataBuffer.h"
#import "NSMutableArray+Queue.h"

@interface MultipeerSession () <MCSessionDelegate, InputStreamDelegate>
@property(nonatomic, readwrite) MCSession *mcSession;
@property(nonatomic, strong) NSMutableDictionary<NSString *, OutputBuffer *> *outputBuffer;
@property(nonatomic, strong) NSMutableDictionary<NSString *, InputDataBuffer *> *inputBuffer;

@end

@implementation MultipeerSession
{
    NSInteger _streamsCount;
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

        self.inputBuffer = [@{} mutableCopy];
        self.outputBuffer = [@{} mutableCopy];
    }

    return self;
}

- (void)startStreamingToPeer:(MCPeerID *)peerId {

    for (int i = 0; i < _streamsCount; ++i)
    {
        NSString *name = [NSString stringWithFormat:@"%@_out_str#%d", [self.mcSession.myPeerID.displayName substringToIndex:4], i];
        OutputBuffer *provider = [[OutputBuffer alloc] initWithDataLength:kPacketLength];
        self.outputBuffer[name] = provider;
        self.outputStreams[name] = [self createAndOpenOutputStreamWithName:name toPeer:peerId dataProvider:provider];
    }
}

- (OutputDataStream *)createAndOpenOutputStreamWithName:(NSString *)name toPeer:(MCPeerID *)peer dataProvider:(id <DataGenerator>)dataProvider
{
    NSError *error;
    NSOutputStream *stream = [self.mcSession startStreamWithName:name toPeer:peer error:&error];
    OutputDataStream *dataStream = [[OutputDataStream alloc] initWithOutputStream:stream dataProvider:dataProvider name:name];
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
    OutputBuffer *outputBuffer = self.outputBuffer[[self originalStreamName:streamName]];
    BOOL (^ validationBlock)(NSData *) = nil;
    if (outputBuffer != nil)
    {
//        validationBlock = ^BOOL(NSData *data) {
//            id sentData = [outputBuffer.buffer popObject];
//            return [sentData isEqualToData:data];
//        };
    }
    InputDataBuffer *buffer = [[InputDataBuffer alloc] initWithValidationBlock:validationBlock];
    InputDataStream *inputDataStream = [[InputDataStream alloc] initWithInputStream:stream dataProcessor:buffer name:streamName];
    inputDataStream.delegate = self;
    [inputDataStream start];
    self.inputStreams[streamName] = inputDataStream;
    self.inputBuffer[streamName] = buffer;
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

#pragma mark - InputStreamDelegate

- (void)readingDidEndForStream:(InputDataStream *)stream
{
    InputDataBuffer *const buffer = self.inputBuffer[stream.name];
    [buffer stopBuffering];
    if ([stream.name containsString:@"retr_"]) {
        NSString *originalName = [self originalStreamName:stream.name];
        NSAssert([self.outputBuffer[originalName].sentData isEqualToData:buffer.receivedData], @"%@ retranslated data is not equal", originalName);
        NSLog(@"\"%@\" retranslated equally", originalName);
    }
}

- (NSString *)originalStreamName:(NSString *)name
{
    NSString *originalName = [name stringByReplacingOccurrencesOfString:@"retr_" withString:@""];
    return originalName;
}

@end
