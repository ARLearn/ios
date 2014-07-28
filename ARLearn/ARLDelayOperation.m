//
//  ARLDelayOperation.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/28/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLDelayOperation.h"

@implementation ARLDelayOperation {
    NSInteger theDelay;
}

- (void)main
{
    @autoreleasepool {
        // 2000ms in 100 ms slices -> 2/100 sec/slice.
        
        for (int i=0;i<theDelay/100;i++) {
            if (self.isCancelled) {
                break;
            }
            
            [NSThread sleepForTimeInterval:0.1];
        }
    }
}

- (id)init {
    return [self initWithDelay:200];
}

- (id)initWithDelay:(int)delay
{
    self = [super init];
    if(self) {
        NSLog(@"_init: %@", self);
        theDelay = delay;
    }
    return self;
}

@end
