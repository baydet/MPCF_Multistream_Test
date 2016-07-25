//
// Created by Alexander Evsyuchenya on 7/25/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

#include "InputDataBuffer.h"
#import "Constants.h"
#import "DataStream.h"
#import "NSMutableArray+Queue.h"

@interface InputDataBuffer ()
@property(atomic) bool doneBuffering;
@property(nonatomic, copy, nullable) BOOL (^validationBlock)(NSData *);
@end

@implementation InputDataBuffer
{
    NSMutableData *_mutableReceivedData;
}

- (instancetype)initWithValidationBlock:(BOOL (^)(NSData *))validationBlock
{
    self = [super init];
    if (self)
    {
        self.validationBlock = validationBlock;
        self.buffer = [[NSMutableArray alloc] initWithCapacity:10000];
        _mutableReceivedData = [[NSMutableData alloc] initWithCapacity:kPacketLength];
    }

    return self;
}


- (NSData *)receivedData
{
    return _mutableReceivedData;
}

- (void)stopBuffering
{
    self.doneBuffering = true;
}

- (NSData *)getDataChunk
{
    //busy waiting. For test purposes only
    while (self.buffer.count == 0) {
        if (self.doneBuffering) {
            return nil;
        }
    }
    NSData *obj = [self.buffer popObject];
    return obj;
}

- (void)processData:(NSData *)data
{
    if (_validationBlock != nil) {
        NSAssert(_validationBlock(data), @"received data is not valid");
    }
    [_mutableReceivedData appendData: data];
    [self.buffer pushObject:data];
}

@end