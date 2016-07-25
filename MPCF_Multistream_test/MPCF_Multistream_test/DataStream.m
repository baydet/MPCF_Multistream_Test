//
//  DataStream.m
//  MPCF_Multistream_test
//
//  Created by Alexander Evsyuchenya on 7/21/16.
//  Copyright © 2016 baydet. All rights reserved.
//

#import "DataStream.h"
#import "Constants.h"
#import "InputDataBuffer.h"

@interface DataStream () <NSStreamDelegate>
@property(nonatomic, strong) NSThread *streamThread;
@property(nonatomic, strong) NSStream *stream;
@end

@implementation DataStream

- (instancetype)initWithStream:(NSStream *)stream name:(NSString *)name
{
    self = [super init];
    if (self)
    {
        self.stream = stream;
        self.name = name;
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
            [self end];
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

- (void)end
{
    [self.stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.stream = nil;
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
@property(nonatomic, strong) id<DataGenerator>dataProvider;
@end

@implementation OutputDataStream
{
    NSUInteger _sentLength;
}

- (instancetype)initWithOutputStream:(NSOutputStream *)outputStream dataProvider:(id <DataGenerator>)dataProvider name:(NSString *)name
{
    self = [super initWithStream:outputStream name:name];
    if (self)
    {
        self.outputStream = outputStream;
        self.dataProvider = dataProvider;
    }

    return self;
}

- (void)writeData {
    NSData *data = [self.dataProvider getDataChunk];
    if (data == nil) {
        [self.outputStream close];
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
@property(nonatomic, strong) id<DataProcessor>dataProcessor;
@end

@implementation InputDataStream
{
    NSUInteger _receivedLength;
}

- (instancetype)initWithInputStream:(NSInputStream *)inputStream dataProcessor:(id <DataProcessor>)dataProcessor name:(NSString *)name
{
    self = [super initWithStream:inputStream name:name];
    if (self)
    {
        self.inputStream = inputStream;
        self.dataProcessor = dataProcessor;
    }

    return self;
}

- (void)readData {
    NSMutableData *data = [NSMutableData data];
    uint8_t buf[kStreamReadMaxLength];
    NSInteger len = [self.inputStream read:buf maxLength:kStreamReadMaxLength];
    if(len) {
        [data appendBytes:(const void *) buf length:(NSUInteger) len];
        [self.dataProcessor processData:data];
        _receivedLength += len;
    } else {
        return;
    }
}

- (void)end
{
    [super end];
    [self.delegate readingDidEndForStream:self];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%u", _receivedLength];
}


@end
