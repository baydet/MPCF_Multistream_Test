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

@interface DataStream : NSObject
@property(nonatomic, copy) NSString *name;

- (instancetype)initWithStream:(NSStream *)stream name:(NSString *)name;
- (void)start;

@end

@interface OutputDataStream : DataStream

- (instancetype)initWithOutputStream:(NSOutputStream *)outputStream dataProvider:(id <DataGenerator>)dataProvider name:(NSString *)name;

@end

@protocol InputStreamDelegate <NSObject>
- (void)readingDidEndForStream:(InputDataStream *)stream;
@end

@interface InputDataStream: DataStream

@property(nonatomic, weak) id<InputStreamDelegate> delegate;

- (instancetype)initWithInputStream:(NSInputStream *)inputStream dataProcessor:(id <DataProcessor>)dataProcessor name:(NSString *)name;

@end