//
//  ARLOperations.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 17/12/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLOperations.h"

// MyOperation.h
@implementation DownloadResourceOperation

- (void)main {
    if ([self isCancelled]) {
        NSLog(@"** operation cancelled **");
    }
    
    //[ARLUtils DownloadResource:self.gameId gameFile:gameFile];
}

@end
