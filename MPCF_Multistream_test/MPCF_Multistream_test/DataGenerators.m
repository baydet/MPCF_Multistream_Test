//
// Created by Alexander Evsyuchenya on 7/21/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

#import "DataGenerators.h"
#import "Constants.h"
#import "NSMutableArray+Queue.h"

@implementation NSData(Random)

+(id)randomDataWithLength:(NSUInteger)length
{
    NSMutableData* data = [NSMutableData dataWithLength:length];
    [[NSInputStream inputStreamWithFileAtPath:@"/dev/urandom"] read:(uint8_t*)[data mutableBytes] maxLength:length];
    return data;
}

@end

@interface DataBuffer ()
@property(atomic) bool doneBuffering;
@end

@implementation DataBuffer


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.buffer = [[NSMutableArray alloc] initWithCapacity:100000];
    }

    return self;
}

- (void)readingDidEndForStream:(InputDataStream *)stream
{
    self.doneBuffering = true;
}

- (NSData *)dataForStream:(DataStream *)stream
{
    while (self.buffer.count == 0) {
        if (self.doneBuffering) {
            return nil;
        }
    }
    id obj = [self.buffer popObject];
    return obj;
}

- (void)stream:(DataStream *)stream hasData:(NSData *)data
{
    [self.buffer pushObject:data];
}

@end

@implementation OutputDataGenerator
{
    int counter;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        counter = 0;
    }

    return self;
}

- (NSData *)dataForStream:(DataStream *)stream
{
    if (counter < kPacketLength) {
        u_int32_t length = 0;
        while (length == 0)
        {
            length = kStreamReadMaxLength;//(arc4random_uniform(kStreamWriteMaxLength) / kStreamReadMaxLength) * kStreamReadMaxLength;
        }
        NSData * data = [NSData randomDataWithLength:length];
        counter += data.length;
        return data;
    } else {
        return nil;
    }
}

@end