//
// Created by Alexander Evsyuchenya on 7/25/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

#import <objc/NSObject.h>
#include "DataGenerators.h"

@class InputDataBuffer;

@protocol DataProcessor <NSObject>
- (void)processData:(NSData *)data;
@end


@interface InputDataBuffer: NSObject <DataGenerator, DataProcessor>
@property(atomic, strong) NSMutableArray *buffer;
@property(nonatomic, readonly) NSData *receivedData;

- (instancetype)initWithValidationBlock:(BOOL (^)(NSData *))validationBlock;


- (void)stopBuffering;
@end