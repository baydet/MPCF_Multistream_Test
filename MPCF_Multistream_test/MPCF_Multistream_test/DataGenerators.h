//
// Created by Alexander Evsyuchenya on 7/21/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataGenerator <NSObject>
- (NSData *)getDataChunk;
@end

@interface OutputBuffer: NSObject <DataGenerator>
@property(nonatomic, readonly) NSData* sentData;
@property(atomic, strong) NSMutableArray *buffer;
- (instancetype)initWithDataLength:(NSUInteger)length;
@end
