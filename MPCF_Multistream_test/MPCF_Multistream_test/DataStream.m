//
//  DataStream.m
//  MPCF_Multistream_test
//
//  Created by Alexander Evsyuchenya on 7/21/16.
//  Copyright © 2016 baydet. All rights reserved.
//

#import "DataStream.h"
#import "Constants.h"

@interface DataStream () <NSStreamDelegate>
@property(nonatomic, strong) NSThread *streamThread;
@end

@implementation NSData(Random)

+(instancetype)randomDataWithLength:(NSUInteger)length
{
    NSMutableData* data=[NSMutableData dataWithLength:length];
    [[NSInputStream inputStreamWithFileAtPath:@"/dev/urandom"] read:(uint8_t*)[data mutableBytes] maxLength:length];
    return data;
}
@end

@implementation DataStream

- (instancetype)initWithStream:(NSStream *)stream
{
    self = [super init];
    if (self)
    {
        self.stream = stream;
    }

    return self;
}

- (void)run
{
    @autoreleasepool {
        self.stream.delegate = self;
        [self.stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.stream open];

        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
    }
}

- (void)start
{
    if (![[NSThread currentThread] isEqual:[NSThread mainThread]]) {
        return [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
    }

    self.streamThread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [self.streamThread start];
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
            [self readData];
            break;

        case NSStreamEventHasSpaceAvailable:
            [self writeData];
            break;

        case NSStreamEventEndEncountered:
            NSLog(@"%@ end encountered", aStream);
            break;

        case NSStreamEventErrorOccurred:
            NSLog(@"%@ error occurred", aStream);
            break;

        case NSStreamEventOpenCompleted:
            NSLog(@"open completed");
            break;
        default:
            break;
    }

}

- (void)readData
{

}

- (void)writeData
{

}

@end


@interface OutputDataStream ()
@property(nonatomic, weak) NSOutputStream *outputStream;
@end

@implementation OutputDataStream
{
    NSUInteger _sentLength;
}

- (instancetype)initWithOutputStream:(NSOutputStream *)outputStream
{
    self = [super initWithStream:outputStream];
    if (self)
    {
        self.outputStream = outputStream;
    }

    return self;
}

- (void)writeData {
    NSData *data = [self.dataProvider dataForStream:self];
    if (data == nil) {
        return;
//        [self.outputStream close];
    }

    _sentLength += data.length;
    [self.outputStream write:data.bytes maxLength:data.length];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%u", _sentLength];
}


@end

@interface InputDataStream ()
@property(nonatomic, weak) NSInputStream *inputStream;
@end

@implementation InputDataStream
{
    NSUInteger _receivedLength;
}

- (instancetype)initWithInputStream:(NSInputStream *)inputStream;
{
    self = [super initWithStream:inputStream];
    if (self)
    {
        self.inputStream = inputStream;
    }

    return self;
}

- (void)readData {
    uint8_t bytes[kStreamReadMaxLength];
    NSMutableData *data = [NSMutableData new];
    [self.inputStream read:bytes maxLength:kStreamReadMaxLength];
    [data appendData:[[NSData alloc] initWithBytes:bytes length:kStreamReadMaxLength]];
    [self.dataProcessor stream:self hasData:data];
    _receivedLength += data.length;
}



- (NSString *)description
{
    return [NSString stringWithFormat:@"%u", _receivedLength];
}


@end
