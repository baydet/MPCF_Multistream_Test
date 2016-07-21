//
// Created by Alexander Evsyuchenya on 7/21/16.
// Copyright (c) 2016 baydet. All rights reserved.
//

#import "NSMutableArray+Queue.h"


@implementation NSMutableArray (Queue)

- (void)pushObject:(id)object
{
    [self addObject:object];
}

- (id)popObject
{
    if (self.count > 0) {
        id object = self[0];
        [self removeObjectAtIndex:0];
        return object;
    }

    return nil;
}

- (id)topObject
{
    if (self.count > 0) {
        return self[0];
    }

    return nil;
}

@end