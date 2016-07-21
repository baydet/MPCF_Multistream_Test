//
//  DataStream.h
//  MPCF_Multistream_test
//
//  Created by Alexander Evsyuchenya on 7/21/16.
//  Copyright © 2016 baydet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultipeerSession.h"
#import "DataGenerators.h"

@class DataStream;
@protocol DataProcessor;

@protocol GeneratorDelegate
- (void)generatorHasNewData:(id<DataStreamGenerator>)generator;
@end


@interface DataStream : NSObject

@property(nonatomic, strong) NSStream *stream;

- (instancetype)initWithStream:(NSStream *)stream;
- (void)start;

@end

@interface OutputDataStream : DataStream <GeneratorDelegate>

@property(nonatomic, strong) id<DataStreamGenerator>dataProvider;

- (instancetype)initWithOutputStream:(NSOutputStream *)outputStream;

@end

@interface InputDataStream: DataStream

@property(nonatomic, strong) id<DataProcessor>dataProcessor;
- (instancetype)initWithInputStream:(NSInputStream *)inputStream;

@end