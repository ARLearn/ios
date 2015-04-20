//
//  ARLCoreDataUtils.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 20/04/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#import "ARLCoreDataUtils.h"

@implementation ARLCoreDataUtils

+ (void)CreateOrUpdateAction:(NSNumber *)runId
                  activeItem:(GeneralItem *)activeItem
                        verb:(NSString *)verb {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"run.runId=%@ AND generalItem.generalItemId=%@ AND action=%@",
                              runId, activeItem.generalItemId, verb];
    Action *action = [Action MR_findFirstWithPredicate:predicate];
    
    if (!action) {
        action = [Action MR_createEntity];
        {
            action.account = [ARLNetworking CurrentAccount];
            action.action = verb;
            action.generalItem = [GeneralItem MR_findFirstByAttribute:@"generalItemId"
                                                            withValue:activeItem.generalItemId];
            action.run = [Run MR_findFirstByAttribute:@"runId"
                                            withValue:runId];
            action.synchronized = [NSNumber numberWithBool:NO];
            action.time = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
        }
        
        // Saves any modification made after ManagedObjectFromDictionary.
        [[NSManagedObjectContext MR_context] MR_saveToPersistentStoreAndWait];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        DLog(@"Marked Generalitem %@ as '%@' for Run %@",activeItem.generalItemId, verb, runId);
    } else {
        DLog(@"Generalitem %@ for Run %@ is already marked as %@", activeItem.generalItemId, runId, verb);
    }
}

@end
