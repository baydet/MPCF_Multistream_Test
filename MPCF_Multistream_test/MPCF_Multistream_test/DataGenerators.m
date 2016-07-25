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

@interface OutputDataGenerator()
@property(nonatomic, strong) NSMutableData *mutableSentData;
@end

@implementation OutputDataGenerator
{
    int counter;
    NSUInteger _length;
}

- (NSData *)sentData
{
    return _mutableSentData;
}

- (instancetype)initWithLength:(NSUInteger) length
{
    self = [super init];
    if (self)
    {
        _length = length;
        counter = 0;
        self.mutableSentData = [[NSMutableData alloc] initWithCapacity:_length];
    }

    return self;
}

- (NSData *)dataForStream:(DataStream *)stream
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
        return data;
    } else {
        return nil;
    }
}

@end