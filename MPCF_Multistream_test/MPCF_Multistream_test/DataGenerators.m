//
// Created by Alexander Evsyuchenya on 7/21/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

#import "DataStream.h"
#import "Constants.h"
#import "NSMutableArray+Queue.h"

@implementation NSData(Random)

+(NSData *)randomDataWithLength:(NSUInteger)length
{
    NSMutableData *mutableData = [NSMutableData dataWithCapacity: length];
    for (unsigned int i = 0; i < length; i++) {
        NSInteger randomBits = arc4random();
        [mutableData appendBytes: (void *) &randomBits length: 1];
    }
    return mutableData;
}

@end

@interface OutputBuffer()
@property(nonatomic, strong) NSMutableData *mutableSentData;
@end

@implementation OutputBuffer
{
    int counter;
    NSUInteger _length;
}

- (NSData *)sentData
{
    return _mutableSentData;
}

- (instancetype)initWithDataLength:(NSUInteger) length
{
    self = [super init];
    if (self)
    {
        _length = length;
        counter = 0;
        self.buffer = [NSMutableArray new];
        self.mutableSentData = [[NSMutableData alloc] initWithCapacity:_length];
    }

    return self;
}

- (NSData *)getDataChunk
{
    if (counter < _length) {
        u_int32_t length = 0;
        while (length == 0)
        {
            length = (arc4random_uniform(kStreamWriteMaxLength) / kStreamReadMaxLength) * kStreamReadMaxLength;
            if (counter + length > _length) {
                length = _length - counter;
            }
        }
        NSData * data = [NSData randomDataWithLength:length];
        counter += data.length;
        [self.mutableSentData appendData:data];
        [self.buffer pushObject:data];
        return data;
    } else {
        return nil;
    }
}

@end