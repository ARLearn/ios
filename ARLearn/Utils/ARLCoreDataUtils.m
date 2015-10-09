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
    DLog(@"CreateOrUpdateAction");
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"run.runId=%@ AND generalItem.generalItemId=%@ AND action=%@",
//                              runId, activeItem.generalItemId, verb];
//    Action *action = [Action MR_findFirstWithPredicate:predicate];
//    
    //    if (!action) {
    Action *action = [Action MR_createEntity];
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
    
    DLog(@"Created Generalitem %@ as '%@' for Run %@",activeItem.generalItemId, verb, runId);
    
    //    } else {
    //        DLog(@"Generalitem %@ for Run %@ is already marked as %@", activeItem.generalItemId, runId, verb);
//    }
}

/*!
 *  Mark the ActiveItem as Read.
 */
+ (void)MarkAnswerAsGiven:(NSNumber*)runId
            generalItemid:(NSNumber *)generalItemId
                 answerId:(NSString *)answerId {
    DLog(@"MarkAnswerAsGiven");
    
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"run.runId=%@ AND generalItem.generalItemId=%@ AND action=%@",
    //                              runId, generalItemId, answerId];
    //    Action *action = [Action MR_findFirstWithPredicate:predicate];
    //
    //    if (!action) {
    Action *action = [Action MR_createEntity];
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
    //    } else {
    //        DLog(@"Generalitem %@ for Run %@ is already marked as %@", generalItemId, runId, action.action);
    //    }
    
//    // TODO Find a better spot to publish actions (and make it a NSOperation)!
//    [ARLSynchronisation PublishActionsToServer];
//    
//    // TODO Find a better spot to sync visibility (and make it a NSOperation)!
//    [ARLSynchronisation DownloadGeneralItemVisibilities:runId];
}

+ (void)processGameDictionaryItem:(NSDictionary *)dict ctx:(NSManagedObjectContext *)ctx
{
    NSDictionary *datafixups = [NSDictionary dictionary];
                                // Data,                                                        CoreData
    
    NSDictionary *namefixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                // Json,                        CoreData
                                @"description",                  @"richTextDescription",
                                nil];
    
    Game *game = [Game MR_findFirstByAttribute:@"gameId"
                                     withValue:[dict valueForKey:@"gameId"]];
    
    if (game) {
        game = (Game *)[ARLUtils UpdateManagedObjectFromDictionary:dict
                                                     managedobject:game
                                                        nameFixups:namefixups
                                                        dataFixups:datafixups
                                                    managedContext:ctx];
        
    } else {
        game = (Game *)[ARLUtils ManagedObjectFromDictionary:dict
                                                  entityName:[Game MR_entityName]
                                                  nameFixups:namefixups
                                                  dataFixups:datafixups                                                  managedContext:ctx];
    }
    
    game.hasMap = [[dict valueForKey:@"config"] valueForKey:@"mapAvailable"];
}

+ (void)processRunDictionaryItem:(NSDictionary *)dict ctx:(NSManagedObjectContext *)ctx
{
    NSDictionary *namefixups = [NSDictionary dictionary];
                                // Json,                         CoreData
    
    NSDictionary *datafixups = [NSDictionary dictionary];
                                // Data,                         CoreData
                                // Relations cannot be done here easily due to context changes.
                                // [Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId], @"game",
                                // nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"runId==%@", [dict valueForKey:@"runId"]];
    
    Run *run = [Run MR_findFirstWithPredicate: predicate inContext:ctx];
    
    if (run) {
        if (([dict valueForKey:@"deleted"] && [[dict valueForKey:@"deleted"] integerValue] != 0) ||
            ([dict valueForKey:@"revoked"] && [[dict valueForKey:@"revoked"] integerValue] != 0)) {
            DLog(@"Deleting Run: %@", [dict valueForKey:@"title"])
            [run MR_deleteEntity];
        } else {
            DLog(@"Updating Run: %@", [dict valueForKey:@"title"])
            run = (Run *)[ARLUtils UpdateManagedObjectFromDictionary:dict
                                                       managedobject:run
                                                          nameFixups:namefixups
                                                          dataFixups:datafixups
                                                      managedContext:ctx];
            
            // We can only update if both objects share the same context.
            Game *game =[Game MR_findFirstByAttribute:@"gameId"
                                            withValue:[dict valueForKey:@"gameId"]
                                            inContext:ctx];
            run.game = game;
            run.revoked = [NSNumber numberWithBool:NO];
        }
    } else {
        if (([dict valueForKey:@"deleted"] && [[dict valueForKey:@"deleted"] integerValue] != 0) ||
            ([dict valueForKey:@"revoked"] && [[dict valueForKey:@"revoked"] integerValue] != 0)) {
            // Skip creating deleted records.
            DLog(@"Skipping deleted Run: %@", [dict valueForKey:@"title"])
        } else {
            // Uses MagicalRecord for Creation and Saving!
            DLog(@"Creating Run: %@", [dict valueForKey:@"title"])
            run = (Run *)[ARLUtils ManagedObjectFromDictionary:dict
                                                    entityName:[Run MR_entityName] //@"Run"
                                                    nameFixups:namefixups
                                                    dataFixups:datafixups
                                                managedContext:ctx];
            
            // We can only update if both objects share the same context.
            Game *game =[Game MR_findFirstByAttribute:@"gameId"
                                            withValue:[dict valueForKey:@"gameId"]
                                            inContext:ctx];
            run.game = game;
            run.revoked = [NSNumber numberWithBool:NO];
        }
    }
}

@end
