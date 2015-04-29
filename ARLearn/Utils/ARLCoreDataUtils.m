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
    Log(@"CreateOrUpdateAction");
    
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

/*!
 *  Mark the ActiveItem as Read.
 */
+ (void)MarkAnswerAsGiven:(NSNumber*)runId
            generalItemid:(NSNumber *)generalItemId
                 answerId:(NSString *)answerId {
    Log(@"MarkAnswerAsGiven");
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"run.runId=%@ AND generalItem.generalItemId=%@ AND action=%@",
                              runId, generalItemId, answerId];
    Action *action = [Action MR_findFirstWithPredicate:predicate];
    
    if (!action) {
        action = [Action MR_createEntity];
        {
            action.account = [ARLNetworking CurrentAccount];
            action.action = answerId;
            action.generalItem = [GeneralItem MR_findFirstByAttribute:@"generalItemId"
                                                            withValue:generalItemId];
            action.run = [Run MR_findFirstByAttribute:@"runId"
                                            withValue:runId];
            action.synchronized = [NSNumber numberWithBool:NO];
            action.time = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
        }
        
        // Saves any modification made after ManagedObjectFromDictionary.
        [[NSManagedObjectContext MR_context] MR_saveToPersistentStoreAndWait];
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        
        DLog(@"Marked Generalitem %@ as '%@' for Run %@", generalItemId, action.action, runId);
    } else {
        DLog(@"Generalitem %@ for Run %@ is already marked as %@", generalItemId, runId, action.action);
    }
    
//    // TODO Find a better spot to publish actions (and make it a NSOperation)!
//    [ARLSynchronisation PublishActionsToServer];
//    
//    // TODO Find a better spot to sync visibility (and make it a NSOperation)!
//    [ARLSynchronisation DownloadGeneralItemVisibilities:runId];
}

@end
