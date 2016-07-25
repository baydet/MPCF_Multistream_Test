//
// Created by Alexander Evsyuchenya on 7/21/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InputStreamDelegate;
@class DataStream;

@protocol DataProcessor <NSObject>
- (void)stream:(DataStream *)stream hasData:(NSData *)data;
@end

@protocol DataGenerator <NSObject>
- (NSData*)dataForStream:(DataStream *)stream;
@end

@interface InputDataBuffer: NSObject <DataGenerator, DataProcessor>
@property(atomic, strong) NSMutableArray *buffer;
@property(nonatomic, readonly) NSData *receivedData;

- (void)stopBuffering;
@end

@interface OutputBuffer: NSObject <DataGenerator>
@property(nonatomic, readonly) NSData* sentData;
- (instancetype)initWithDataLength:(NSUInteger)length;
@end
