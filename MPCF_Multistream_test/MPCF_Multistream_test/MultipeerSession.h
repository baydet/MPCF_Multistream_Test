//
//  MultipeerSession.h
//  MPCF_Multistream_test
//
//  Created by Alexander Evsyuchenya on 7/21/16.
//  Copyright © 2016 baydet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@class MCPeerID;
@class MultipeerSession;
@class OutputDataStream;
@class InputDataStream;
@protocol DataStreamGenerator;

@protocol MultipeerSessionDelegate
- (void)session:(MultipeerSession *)session didConnectToPeer:(MCPeerID *)peer;
@end

@interface MultipeerSession : NSObject

@property(nonatomic, readonly) MCSession *mcSession;
@property(nonatomic, weak) id<MultipeerSessionDelegate> delegate;
@property(nonatomic, assign) BOOL shouldRetranslateStream;
@property(nonatomic, strong) NSMutableDictionary<NSString *, InputDataStream *> *inputStreams;
@property(nonatomic, strong) NSMutableDictionary<NSString *, OutputDataStream *> *outputStreams;


- (instancetype)initWithPeer:(MCPeerID *)peerID;
- (void)startStreamingToPeer:(MCPeerID *)peerId;

@end
