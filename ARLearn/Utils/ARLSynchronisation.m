//
//  ARLSynchronisation.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 28/04/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#import "ARLSynchronisation.h"

@implementation ARLSynchronisation

/*!
 *  Post all unsynced Actions to the server.
 */
+(void) PublishActionsToServer {
    Log(@"PublishActionsToServer");
    
    // TODO Filter on runId too?
    
    if ([ARLNetworking networkAvailable]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"synchronized!=%@", @YES];
        
        NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
        
        for (Action *action in [Action MR_findAllWithPredicate:predicate inContext:ctx]) {
            NSString *userEmail = [NSString stringWithFormat:@"%@:%@", action.account.accountType, action.account.localId];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  action.action,                        @"action",
                                  action.run.runId,                     @"runId",
                                  action.generalItem.generalItemId,     @"generalItemId",
                                  userEmail,                            @"userEmail",
                                  action.time,                          @"time",
                                  action.generalItem.type,              @"generalItemType",
                                  nil];
            
            [ARLNetworking sendHTTPPostWithAuthorization:@"actions" json:dict];
            
            action.synchronized = [NSNumber numberWithBool:YES];
            
            // Saves any modification made after ManagedObjectFromDictionary.
            [ctx MR_saveToPersistentStoreAndWait];
        }
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ARL_SYNCREADY
                                                            object:NSStringFromClass([Action class])];
    }
}

/*!
 *  Retrieve GeneralItemVisibility records from the server.
 *
 *  Runs in a background thread.
 */
+(void) DownloadGeneralItemVisibilities:(NSNumber *)runId {
    Log(@"DownloadGeneralItemVisibilities:%@", runId);

    // TODO Add TimeStamp to url retrieve less records?
    
    NSString *service = [NSString stringWithFormat:@"generalItemsVisibility/runId/%lld", [runId longLongValue]];
    
    NSData *data = [ARLNetworking sendHTTPGetWithAuthorization:service];
    
    NSError *error = nil;
    NSDictionary *response = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                      error:&error] : nil;
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
    
    if (error == nil) {
        // [ARLUtils LogJsonDictionary:response url:[ARLNetworking MakeRestUrl:service]];
        
        for (NSDictionary *item in [response valueForKey:@"generalItemsVisibility"])
        {
            // DLog(@"GeneralItem: %lld has Status %@,", [[item valueForKey:@"generalItemId"] longLongValue], [item valueForKey:@"status"]);
            
            //{
            //    "type": "org.celstec.arlearn2.beans.run.GeneralItemVisibilityList",
            //    "serverTime": 1421237978494,
            //    "generalItemsVisibility": [
            //                               {
            //                                   "type": "org.celstec.arlearn2.beans.run.GeneralItemVisibility",
            //                                   "runId": 4977978815545344,
            //                                   "deleted": false,
            //                                   "lastModificationDate": 1417533139703,
            //                                   "timeStamp": 1417533139537,
            //                                   "status": 1,
            //                                   "email": "2:103021572104496509774",
            //                                   "generalItemId": 6180497885495296
            //                               },
            //                               {
            //                                   "type": "org.celstec.arlearn2.beans.run.GeneralItemVisibility",
            //                                   "runId": 4977978815545344,
            //                                   "deleted": false,
            //                                   "lastModificationDate": 1421237415947,
            //                                   "timeStamp": 1421237414637,
            //                                   "status": 1,
            //                                   "email": "2:103021572104496509774",
            //                                   "generalItemId": 5232076227870720
            //                               }
            //                               ]
            //}
            
            //            @dynamic email;                   mapped
            //            @dynamic generalItemId;           mapped
            //            @dynamic runId;                   mapped
            //            @dynamic status;                  mapped
            //            @dynamic timeStamp;               mapped
            
            //            @dynamic correspondingRun;        manual
            //            @dynamic generalItem;             manual
            
            // Check if a record is already present.
            //
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"generalItemId=%lld AND runId=%lld",
                                      [[item valueForKey:@"generalItemId"] longLongValue],
                                      [runId longLongValue]];
            
            GeneralItemVisibility *giv = [GeneralItemVisibility MR_findFirstWithPredicate:predicate
                                                                                inContext:ctx];
            
            if (giv == nil) {
                
                // Create a new Record.
                //
                giv = (GeneralItemVisibility *)[ARLUtils ManagedObjectFromDictionary:item
                                                                          entityName:[GeneralItemVisibility MR_entityName] // @"GeneralItemVisibility"
                                                                      managedContext:ctx];
                
                giv.correspondingRun = [Run MR_findFirstByAttribute:@"runId"
                                                          withValue:giv.runId
                                                          inContext:ctx];
                
                giv.generalItem = [GeneralItem MR_findFirstByAttribute:@"generalItemId"
                                                             withValue:giv.generalItemId
                                                             inContext:ctx];
                
                Log(@"Created GeneralItemVisibility for %@ ('%@') with status %@", giv.generalItemId, giv.generalItem.name, giv.status);
            } else {
                if (!giv.correspondingRun) {
                    giv.correspondingRun = [Run MR_findFirstByAttribute:@"runId"
                                                              withValue:giv.runId
                                                              inContext:ctx];
                }
                if (!giv.generalItem) {
                    giv.generalItem = [GeneralItem MR_findFirstByAttribute:@"generalItemId"
                                                                 withValue:giv.generalItemId
                                                                 inContext:ctx];
                }
                // Only update when visibility status is still smaller then 2.
                //
                if (! [giv.status isEqualToNumber:[NSNumber numberWithInt:2]]) {
                    giv.status = [item valueForKey:@"status"];
                    giv.timeStamp = [item valueForKey:@"timeStamp"];
                    
                    Log(@"Updated GeneralItemVisibility of %@ ('%@') to status %@", giv.generalItemId, giv.generalItem.name, giv.status);
                }
                
                [ctx MR_saveToPersistentStoreAndWait];
            }
        }
    }
    
    // Saves any modification made after ManagedObjectFromDictionary.
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ARL_SYNCREADY
                                                        object:NSStringFromClass([GeneralItemVisibility class])];
    
    // [self performSelectorOnMainThread:@selector(UpdateItemVisibility) withObject:nil waitUntilDone:YES];
}

/*!
 *  Downloads the general items and stores/update or deletes them in/from the database.
 *
 *  Runs in a background thread.
 */
+(void) DownloadResponses:(NSNumber *)runId {
    Log(@"DownloadResponses:%@", runId);

    NSString *service = [NSString stringWithFormat:@"response/runId/%@",
                         runId];
    NSData *data = [ARLNetworking sendHTTPGetWithAuthorization:service];
    
    NSError *error = nil;
    
    NSDictionary *response = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                      error:&error] : nil;
    ELog(error);
    
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
    
    //#pragma warn Debug Code
    // [ARLUtils LogJsonDictionary:response url:service];
    
    NSDictionary *responses = [response objectForKey:@"responses"];
    
    for (NSDictionary *response in responses) {
        
        // Sample JSON:
        //{
        //    "type": "org.celstec.arlearn2.beans.run.ResponseList",
        //    "deleted": false,
        //    "responses": [
        //                  {
        //                      "type": "org.celstec.arlearn2.beans.run.Response",
        //                      "timestamp": 1429778810783,
        //                      "runId": 5777243095695360,
        //                      "deleted": false,
        //                      "responseId": 5313819882553344,
        //                      "generalItemId": 5800061720068096,
        //                      "userEmail": "2:103021572104496509774",
        //                      "responseValue": "{\"imageUrl\":\"http:\\/\\/streetlearn.appspot.com\\/uploadService\\/5777243095695360\\/2:103021572104496509774\\/image1816922733.jpg\",\"width\":1024,\"height\":720,\"contentType\":\"image\\/jpeg\"}",
        //                      "lastModificationDate": 1429778806816,
        //                      "revoked": false
        //                  },
        //                  {
        //                      "type": "org.celstec.arlearn2.beans.run.Response",
        //                      "timestamp": 1429778585233,
        //                      "runId": 5777243095695360,
        //                      "deleted": false,
        //                      "responseId": 5796436767670272,
        //                      "generalItemId": 5800061720068096,
        //                      "userEmail": "2:103021572104496509774",
        //                      "responseValue": "{\"value\":258}",
        //                      "lastModificationDate": 1429778582920,
        //                      "revoked": false
        //                  }
        //                  ]
        //}
        
        //        @property (nonatomic, retain) NSString * contentType;
        //        @property (nonatomic, retain) NSData * data;
        //        @property (nonatomic, retain) NSString * fileName;
        //        @property (nonatomic, retain) NSNumber * height;
        //        @property (nonatomic, retain) NSNumber * lat;
        //        @property (nonatomic, retain) NSNumber * lng;
        //        @property (nonatomic, retain) NSNumber * responseId;
        //        @property (nonatomic, retain) NSNumber * responseType;
        //        @property (nonatomic, retain) NSNumber * synchronized;
        //        @property (nonatomic, retain) NSData * thumb;
        //        @property (nonatomic, retain) NSNumber * timeStamp;
        //        @property (nonatomic, retain) NSString * value;
        //        @property (nonatomic, retain) NSNumber * width;
        //        @property (nonatomic, retain) NSNumber * revoked;
        //        @property (nonatomic, retain) Account *account;
        //        @property (nonatomic, retain) GeneralItem *generalItem;
        //        @property (nonatomic, retain) Run *run;

        // fout als responseId=0;
        
        Response *item = [Response MR_findFirstByAttribute:@"responseId"
                                                 withValue:[response valueForKey:@"responseId"]
                                                 inContext:ctx];
        
        if (!item) {
            // NSString* accountType = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"];
            // NSString* accountLocalId = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"];
            // NSString* account = [NSString stringWithFormat:@"%@:%@", accountType, accountLocalId];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"responseId = 0 and timeStamp = %lld && account.accountType = %d && account.localId = %@",
                                      [[response objectForKey:@"timestamp"] longLongValue],
                                      [[ARLNetworking CurrentAccount].accountType intValue],
                                      [ARLNetworking CurrentAccount].localId
                                      ];
            item = [Response MR_findFirstWithPredicate:predicate];
            
            if (item) {
                item.responseId = [response valueForKey:@"responseId"];
            }
        }
        
        NSDictionary *namefixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                    // Json,                         CoreData
                                    @"timestamp",                    @"timeStamp",
                                    @"responseValue",                @"value",
                                    nil];
        
        NSDictionary *datafixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                    // Data,                                                        CoreData
                                    // [NSKeyedArchiver archivedDataWithRootObject:generalItem],       @"json",
                                    // Relations cannot be done here easily due to context changes.
                                    // [Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId], @"ownerGame",
                                    nil];
        
        //DONE: Test record deletion.
        //TODO: Find out what to do with linked records in other tables (like GeneralItemVisibility).
        
        BOOL deleted = NO;
        
        if (item) {
            if (([response valueForKey:@"deleted"] && [[response valueForKey:@"deleted"] integerValue] != 0) ||
                ([response valueForKey:@"revoked"] && [[response valueForKey:@"revoked"] integerValue] != 0)) {
                DLog(@"Deleting Response: %@", [response valueForKey:@"responseId"])
                [item MR_deleteEntity];
                
                deleted = YES;
            } else {
                DLog(@"Updating Response: %@", [response valueForKey:@"responseId"])
                item = (Response *)[ARLUtils UpdateManagedObjectFromDictionary:response
                                                                 managedobject:item
                                                                    nameFixups:namefixups
                                                                    dataFixups:datafixups
                                                                managedContext:ctx];
            }
        } else {
            if (([response valueForKey:@"deleted"] && [[response valueForKey:@"deleted"] integerValue] != 0) ||
                ([response valueForKey:@"revoked"] && [[response valueForKey:@"revoked"] integerValue] != 0)) {
                // Skip creating deleted records.
                DLog(@"Skipping deleted Response: %@", [response valueForKey:@"responseId"])
            } else {
                // Uses MagicalRecord for Creation and Saving!
                DLog(@"Creating Response: %@", [response valueForKey:@"responseId"])
                item = (Response *)[ARLUtils ManagedObjectFromDictionary:response
                                                              entityName:[Response MR_entityName] // @"Response"
                                                              nameFixups:namefixups
                                                              dataFixups:datafixups
                                                          managedContext:ctx];
            }
        }
        
        // We can only update if both objects share the same context.
        
        if (!deleted) {
            
            // 0) Items from the serve are always sychronized.
            item.synchronized = @YES;
            
            // 1) Update Run
            if (!(item.run && [item.run.runId isEqualToNumber:runId])) {
                Run *run =[Run MR_findFirstByAttribute:@"runId"
                                             withValue:runId
                                             inContext:ctx];
                item.run = run;
            }
            
            // 2) Update Account
            NSArray *userComponents = [[response valueForKey:@"userEmail"] componentsSeparatedByString:@":"];
            
            NSString *accountType = [userComponents objectAtIndex:0];
            NSString *accountId =[userComponents objectAtIndex:1];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(localId = %@) AND (accountType = %@)", accountId, accountType];
            
            Account *account = [Account MR_findFirstWithPredicate:predicate inContext:ctx];
            if (!account) {
                NSData *data = [ARLNetworking getUserInfo:runId
                                                   userId:accountId
                                               providerId:accountType];
                
                NSDictionary *dict = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                            options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                              error:&error] : nil;
                if (dict) {
                    
                    NSURL *url = [NSURL URLWithString:[dict objectForKey:[dict objectForKey:@"picture"] ? @"picture": @"icon"]];
                    NSData *urlData = [NSData dataWithContentsOfURL:url];
                    if (!urlData) {
                        urlData = [[NSData alloc] init];
                    }
                    NSDictionary *datafixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                                // Data,                                                        CoreData
                                                urlData,                                                        @"picture",
                                                // Relations cannot be done here easily due to context changes.
                                                // [Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId], @"ownerGame",
                                                nil];
                    
                    account = (Account *)[ARLUtils ManagedObjectFromDictionary:dict
                                                                    entityName:[Account MR_entityName]
                                                                    nameFixups:nil
                                                                    dataFixups:datafixups
                                                                managedContext:ctx];
                }
            }
            item.account = account;
            
            // 3) Update GeneratItem
            if (!(item.generalItem && [item.generalItem.generalItemId isEqualToNumber:[response valueForKey:@"generalItemId"]])) {
                GeneralItem *generalitem =[GeneralItem MR_findFirstByAttribute:@"generalItemId"
                                                                     withValue:[response valueForKey:@"generalItemId"]
                                                                     inContext:ctx];
                item.generalItem = generalitem;
            }
            
            // 4) Update responseType
            NSError *error = nil;
            NSData *data = [[response objectForKey:@"responseValue"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *value = [NSJSONSerialization JSONObjectWithData:data
                                                                  options: NSJSONReadingMutableContainers
                                                                    error: &error];
            ELog(error);
            
            if (value) {
                if ([value objectForKey:@"imageUrl"]) {
                    item.height = [NSNumber numberWithInt:[[value objectForKey:@"height"] integerValue]];
                    item.width = [NSNumber numberWithInt:[[value objectForKey:@"width"] integerValue]];
                    item.fileName = [value objectForKey:@"imageUrl"];
                    item.contentType = @"application/jpg";
                    item.responseType = [NSNumber numberWithInt:PHOTO];
                } else if ([value objectForKey:@"videoUrl"]) {
                    item.fileName = [value objectForKey:@"videoUrl"];
                    item.contentType = @"video/quicktime";
                    item.responseType = [NSNumber numberWithInt:VIDEO];
                } else if ([value objectForKey:@"audioUrl"]) {
                    item.fileName = [value objectForKey:@"audioUrl"];
                    if ([item.fileName hasSuffix:@".m4a"]) {
                        item.contentType = @"audio/aac";
                    } else  if ([item.fileName hasSuffix:@".mp3"]) {
                        item.contentType = @"audio/mp3";
                    } else  if ([item.fileName hasSuffix:@".amr"]) {
                        item.contentType = @"audio/amr";
                    } else {
                        // Fallback.
                        item.contentType = @"audio/aac";
                    }
                    item.responseType = [NSNumber numberWithInt:AUDIO];
                } else if ([value objectForKey:@"text"]) {
                    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    item.value = jsonString;//[valueDict objectForKey:@"text"];
                    item.responseType = [NSNumber numberWithInt:TEXT];
                } else if ([value objectForKey:@"value"]) {
                    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    item.value = jsonString;//[valueDict objectForKey:@"value"];
                    item.responseType = [NSNumber numberWithInt:NUMBER];
                }
            }
        }
        
        [ctx MR_saveToPersistentStoreAndWait];
    }
    
    // Saves any modification made after ManagedObjectFromDictionary.
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ARL_SYNCREADY
                                                        object:NSStringFromClass([Response class])];
}

/*!
 *  Downloads the general items and stores/update or deletes them in/from the database.
 *
 *  Runs in a background thread.
 */
+(void) DownloadGeneralItems:(NSNumber *)gameId {
    NSString *service = [NSString stringWithFormat:@"generalItems/gameId/%@", gameId];
    NSData *data = [ARLNetworking sendHTTPGetWithAuthorization:service];
    
    NSError *error = nil;
    
    NSDictionary *response = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                      error:&error] : nil;
    ELog(error);
    
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
    
    //#pragma warn Debug Code
    // [ARLUtils LogJsonDictionary:response url:service];
    
    NSDictionary *generalItems = [response objectForKey:@"generalItems"];
    
    for (NSDictionary *generalItem in generalItems) {
        // [ARLUtils LogJsonDictionary:generalItem url:NULL];
        
        // @property (nonatomic, retain) NSNumber * deleted;                     handled
        
        // @property (nonatomic, retain) NSString * descriptionText;                fixup ( description, cannot rename field as descrition is reserved ).
        // @property (nonatomic, retain) NSNumber * gameId;                      mapped    ( same as ownerGame )?
        // @property (nonatomic, retain) NSNumber * generalItemId;                  fixup ( id).
        // @property (nonatomic, retain) NSData * json;                             fixup ( generalItem as json).
        // @property (nonatomic, retain) NSNumber * lat;                         mapped
        // @property (nonatomic, retain) NSNumber * lng;                         mapped
        // @property (nonatomic, retain) NSString * name;                        mapped
        // @property (nonatomic, retain) NSString * richText;                    mapped
        // @property (nonatomic, retain) NSNumber * sortKey;                        todo  ( ??? ).
        // @property (nonatomic, retain) NSString * type;                        mapped
        
        // @property (nonatomic, retain) NSSet *actions;                             todo  ( relation ).
        // @property (nonatomic, retain) NSSet *currentVisibility;                   todo  ( relation ).
        // @property (nonatomic, retain) NSSet *data;                                todo  ( relation ).
        // @property (nonatomic, retain) Game *ownerGame;                           manual ( relation ).
        // @property (nonatomic, retain) NSSet *responses;                           todo  ( relation ).
        // @property (nonatomic, retain) NSSet *visibility;                          todo  ( relation ).
        
        // Sample JSON:
        //{
        //    autoLaunch = 0;
        //    deleted = 0;
        //    dependsOn =             {
        //        lat = "51.22182818142593";
        //        lng = "6.805556677490245";
        //        radius = 1000;
        //        type = "org.celstec.arlearn2.beans.dependencies.ProximityDependency";
        //    };
        //    description = "";
        //    fileReferences =             (
        //    );
        //    gameId = 13876002;
        //    id = 13876003;
        //    lastModificationDate = 1385113739048;
        //    lat = "51.21817260455731";
        //    lng = "6.804355047851573";
        //    name = "Welcome at MDH Stefaan";
        //    richText = "";
        //    roles =             (
        //    );
        //    scope = user;
        //    showCountDown = 0;
        //    sortKey = 0;
        //    type = "org.celstec.arlearn2.beans.generalItem.NarratorItem";
        //},
        
        NSDictionary *namefixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                    // Json,                         CoreData
                                    @"description",                  @"descriptionText",
                                    @"id",                           @"generalItemId",
                                    nil];
        
        NSDictionary *datafixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                    // Data,                                                        CoreData
                                    [NSKeyedArchiver archivedDataWithRootObject:generalItem],       @"json",
                                    // Relations cannot be done here easily due to context changes.
                                    // [Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId], @"ownerGame",
                                    nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gameId==%@ && generalItemId==%@", gameId, [generalItem valueForKey:@"id"]];
        GeneralItem *item = [GeneralItem MR_findFirstWithPredicate: predicate inContext:ctx];
        
        //DONE: Test record deletion.
        //TODO: Find out what to do with linked records in other tables (like GeneralItemVisibility).
        if (item) {
            if (([generalItem valueForKey:@"deleted"] && [[generalItem valueForKey:@"deleted"] integerValue] != 0) ||
                ([generalItem valueForKey:@"revoked"] && [[generalItem valueForKey:@"revoked"] integerValue] != 0)) {
                DLog(@"Deleting GeneralItem: %@", [generalItem valueForKey:@"name"])
                [item MR_deleteEntity];
            } else {
                DLog(@"Updating GeneralItem: %@", [generalItem valueForKey:@"name"])
                item = (GeneralItem *)[ARLUtils UpdateManagedObjectFromDictionary:generalItem
                                                                    managedobject:item
                                                                       nameFixups:namefixups
                                                                       dataFixups:datafixups
                                                                   managedContext:ctx];
                
                // We can only update if both objects share the same context.
                Game *game =[Game MR_findFirstByAttribute:@"gameId"
                                                withValue:gameId
                                                inContext:ctx];
                item.ownerGame = game;
            }
        } else {
            if (([generalItem valueForKey:@"deleted"] && [[generalItem valueForKey:@"deleted"] integerValue] != 0) ||
                ([generalItem valueForKey:@"revoked"] && [[generalItem valueForKey:@"revoked"] integerValue] != 0)) {
                // Skip creating deleted records.
                DLog(@"Skipping deleted GeneralItem: %@", [generalItem valueForKey:@"name"])
            }else {
                // Uses MagicalRecord for Creation and Saving!
                DLog(@"Creating GeneralItem: %@", [generalItem valueForKey:@"name"])
                item = (GeneralItem *)[ARLUtils ManagedObjectFromDictionary:generalItem
                                                                 entityName:[GeneralItem MR_entityName] // @"GeneralItem"
                                                                 nameFixups:namefixups
                                                                 dataFixups:datafixups
                                                             managedContext:ctx];
                
                // We can only update if both objects share the same context.
                Game *game =[Game MR_findFirstByAttribute:@"gameId"
                                                withValue:gameId
                                                inContext:ctx];
                item.ownerGame = game;
            }
        }
        
        [ctx MR_saveToPersistentStoreAndWait];
        
        //TODO: Handle and resolved rest of the fields later.
        
        // DLog(@"GeneralItem ID: %@", generalitem.generalItemId);
        // DLog(@"GeneralItem Type: %@", generalitem.type);
        // DLog(@"GeneralItem Description: %@", generalitem.descriptionText);
    }
    
    // Saves any modification made after ManagedObjectFromDictionary.
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ARL_SYNCREADY
                                                        object:NSStringFromClass([GeneralItem class])];
}

/*!
 *  Downloads Actions of the Run we're participating in.
 *
 *  Runs in a background thread.
 */
+(void) DownloadActions:(NSNumber *)runId {
     Log(@"DownloadActions:%@", runId);
    
    if (runId) {
        NSString *service = [NSString stringWithFormat:@"actions/runId/%@", runId];
        NSData *data = [ARLNetworking sendHTTPGetWithAuthorization:service];
        
        NSError *error = nil;
        
        NSDictionary *response = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                          error:&error] : nil;
        ELog(error);
        
        //#pragma warn Debug Code
        // [ARLUtils LogJsonDictionary:response url:service];
        
        NSDictionary *actions = [response objectForKey:@"actions"];
        
        NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
        
        //{
        //    "type": "org.celstec.arlearn2.beans.run.ActionList",
        //    "runId": 4977978815545344,
        //    "deleted": false,
        //    "actions": [
        //                {
        //                    "type": "org.celstec.arlearn2.beans.run.Action",
        //                    "timestamp": 1421241029935,
        //                    "runId": 4977978815545344,
        //                    "deleted": false,
        //                    "identifier": 5807073128349696,
        //                    "generalItemId": 6180497885495296,
        //                    "generalItemType": "org.celstec.arlearn2.beans.generalItem.AudioObject",
        //                    "userEmail": "2:103021572104496509774",
        //                    "time": 1421241029935,
        //                    "action": "read"
        //                },
        //                {
        //                    "type": "org.celstec.arlearn2.beans.run.Action",
        //                    "timestamp": 1421237414637,
        //                    "runId": 4977978815545344,
        //                    "deleted": false,
        //                    "identifier": 5861948851748864,
        //                    "generalItemId": 6180497885495296,
        //                    "generalItemType": "org.celstec.arlearn2.beans.generalItem.AudioObject",
        //                    "userEmail": "2:103021572104496509774",
        //                    "time": 1421237414637,
        //                    "action": "read"
        //                },
        //                {
        //                    "type": "org.celstec.arlearn2.beans.run.Action",
        //                    "timestamp": 1421242040473,
        //                    "runId": 4977978815545344,
        //                    "deleted": false,
        //                    "identifier": 5865743723790336,
        //                    "generalItemId": 6180497885495296,
        //                    "generalItemType": "org.celstec.arlearn2.beans.generalItem.AudioObject",
        //                    "userEmail": "2:103021572104496509774",
        //                    "time": 1421242040473,
        //                    "action": "read"
        //                }
        //                ]
        //}
        
        for (NSDictionary *item in actions) {
            
            // @property (nonatomic, retain) NSString * action;          mapped
            // @property (nonatomic, retain) NSNumber * synchronized;    yes (hardcoded value as it comes from the server)
            // @property (nonatomic, retain) NSNumber * time;            mapped
            
            // @property (nonatomic, retain) Account *account;           manual
            // @property (nonatomic, retain) GeneralItem *generalItem;   manual
            // @property (nonatomic, retain) Run *run;                   manual
            
            NSString *userEmail = (NSString *)[item valueForKey:@"userEmail"];
            
            NSArray *userComponents = [userEmail componentsSeparatedByString:@":"];
            
            NSString *accountType = [userComponents objectAtIndex:0];
            NSString *accountId =[userComponents objectAtIndex:1];
            
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"run.runId==%lld && generalItem.generalItemId==%lld && account.accountType==%@ && account.localId==%@",
                                       [[item valueForKey:@"runId"] longLongValue],
                                       [[item valueForKey:@"generalItemId"] longLongValue],
                                       accountType,
                                       accountId
                                       ];
            
            Action *action = [Action MR_findFirstWithPredicate:predicate1 inContext:ctx];
            
            Run *r;
            GeneralItem *gi;
            Account *a;
            
            if (action==nil) {
                Log(@"Creating Action");
                action = (Action *)[ARLUtils ManagedObjectFromDictionary:item
                                                              entityName:[Action MR_entityName] // @"Action"
                                                          managedContext:ctx];
                
                // Manual Fixups;
                {
#warning BAD-ACCESS can occur.
                    action.synchronized = [NSNumber numberWithBool:YES];
                }
                
                if ([item valueForKey:@"runId"] && [[item valueForKey:@"runId"] longLongValue] != 0)
                {
                    r = [Run MR_findFirstByAttribute:@"runId"
                                           withValue:[item valueForKey:@"runId"]
                                           inContext:ctx];
                    if (r) {
                        action.run = r;
                    } else {
                        Log("Run %@ for Action not found", [item valueForKey:@"runId"]);
                    }
                }
                
                if ([item valueForKey:@"generalItemId"] && [[item valueForKey:@"generalItemId"] longLongValue] != 0)
                {
                    gi = [GeneralItem MR_findFirstByAttribute:@"generalItemId"
                                                    withValue:[item valueForKey:@"generalItemId"]
                                                    inContext:ctx];
                    if (gi) {
                        action.generalItem = gi;
                    } else {
                        Log("GeneralItem %@ for Action not found", [item valueForKey:@"generalItemId"]);
                    }
                }
                
                {
                    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"accountType==%@ && localId==%@",
                                               accountType,
                                               accountId];
                    
                    a = [Account MR_findFirstWithPredicate:predicate2
                                                 inContext:ctx];
                    
                    if (a) {
                        action.account = a;
                    }
                }
                
                [ctx MR_saveToPersistentStoreAndWait];
            }
        }
        
        // Saves any modification made after ManagedObjectFromDictionary.
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:ARL_SYNCREADY
                                                        object:NSStringFromClass([Action class])];
}

/*!
 *  Downloads Runs we're participating in.
 *
 *  Runs in a background thread.
 */
+(void) DownloadRuns {
    Log(@"DownloadRuns");
    
    NSString *service = @"myRuns/participate";
    NSData *data = [ARLNetworking sendHTTPGetWithAuthorization:service];

    NSError *error = nil;
    
    NSDictionary *response = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                      error:&error] : nil;
    ELog(error);
    
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
    
    //#pragma warn Debug Code
    // [ARLUtils LogJsonDictionary:response url:service];
    
    NSDictionary *runs = [response objectForKey:@"runs"];
    
    for (NSDictionary *run in runs) {
        //        @property (nonatomic, retain) NSNumber * deleted;         handled
        //        @property (nonatomic, retain) NSNumber * gameId;          mapped
        //        @property (nonatomic, retain) NSString * owner;
        //        @property (nonatomic, retain) NSNumber * runId;           mapped
        //        @property (nonatomic, retain) NSString * title;           mapped
        //        @property (nonatomic, retain) NSSet *actions;
        //        @property (nonatomic, retain) NSSet *currentVisibility;
        //        @property (nonatomic, retain) Game *game;                     relation      ( relation).
        //        @property (nonatomic, retain) Inquiry *inquiry;
        //        @property (nonatomic, retain) NSSet *itemVisibilityRules;
        //        @property (nonatomic, retain) NSSet *messages;
        //        @property (nonatomic, retain) NSSet *responses;
        
            NSDictionary *namefixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                        // Json,                         CoreData
                                        nil];
            
            NSDictionary *datafixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                        // Data,                                                        CoreData
                                        // Relations cannot be done here easily due to context changes.
                                        // [Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId], @"game",
                                        nil];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"runId==%@", [run valueForKey:@"runId"]];
            
            Run *item = [Run MR_findFirstWithPredicate: predicate inContext:ctx];
            
            if (item) {
                if (([run valueForKey:@"deleted"] && [[run valueForKey:@"deleted"] integerValue] != 0) ||
                    ([run valueForKey:@"revoked"] && [[run valueForKey:@"revoked"] integerValue] != 0)) {
                    DLog(@"Deleting Run: %@", [run valueForKey:@"title"])
                    [item MR_deleteEntity];
                } else {
                    DLog(@"Updating Run: %@", [run valueForKey:@"title"])
                    item = (Run *)[ARLUtils UpdateManagedObjectFromDictionary:run
                                                                managedobject:item
                                                                   nameFixups:namefixups
                                                                   dataFixups:datafixups
                                                               managedContext:ctx];
                    
                    // We can only update if both objects share the same context.
                    Game *game =[Game MR_findFirstByAttribute:@"gameId"
                                                    withValue:[run valueForKey:@"gameId"]
                                                    inContext:ctx];
                    item.game = game;
                    item.revoked = [NSNumber numberWithBool:NO];
                }
            } else {
                if (([run valueForKey:@"deleted"] && [[run valueForKey:@"deleted"] integerValue] != 0) ||
                    ([run valueForKey:@"revoked"] && [[run valueForKey:@"revoked"] integerValue] != 0)) {
                    // Skip creating deleted records.
                    DLog(@"Skipping deleted Run: %@", [run valueForKey:@"title"])
                } else {
                    // Uses MagicalRecord for Creation and Saving!
                    DLog(@"Creating Run: %@", [run valueForKey:@"title"])
                    item = (Run *)[ARLUtils ManagedObjectFromDictionary:run
                                                             entityName:[Run MR_entityName] //@"Run"
                                                             nameFixups:namefixups
                                                             dataFixups:datafixups
                                                         managedContext:ctx];
                    
                    // We can only update if both objects share the same context.
                    Game *game =[Game MR_findFirstByAttribute:@"gameId"
                                                    withValue:[run valueForKey:@"gameId"]
                                                    inContext:ctx];
                    item.game = game;
                    item.revoked = [NSNumber numberWithBool:NO];
                }
            }
        }
    
    // Saves any modification made after ManagedObjectFromDictionary.
    [ctx MR_saveToPersistentStoreAndWait];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ARL_SYNCREADY
                                                        object:NSStringFromClass([Run class])];
}

+(void) PublishResponsesToServer {
    Log(@"PublishResponsesToServer");
    
    if (ARLNetworking.networkAvailable) {
        NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];

        NSArray *responses = [Response MR_findByAttribute:@"synchronized"
                                                withValue:@NO
                                                inContext:ctx];

        for (Response *response in responses) {
            
            if ([response.revoked isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                // Deleted Revoked Responses.
                
                //if (ARLAppDelegate.SyncAllowed) {
                [ARLNetworking executeARLearnDeleteWithAuthorization:
                 [NSString stringWithFormat:@"response/responseId/%lld", [response.responseId longLongValue]]];
                
                [response MR_deleteEntityInContext:ctx];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:ARL_SYNCPROGRESS
                                                                    object:NSStringFromClass([Response class])];
                //}
            } else if (response.value) {
                // Text
                // Number
                [ARLSynchronisation publishResponse:response.run.runId
                                      responseValue:response.value
                                             itemId:response.generalItem.generalItemId
                                          timeStamp:response.timeStamp];
                
                response.synchronized = [NSNumber numberWithBool:YES];
            } else {
                
                // VEG NOT neccesay anymore as the filename already has a random number prepended.
                u_int32_t random = arc4random();
                NSString* imageName = [NSString stringWithFormat:@"%u.%@", random, response.fileName];
                
                if (response.run.runId) {
                    NSString* uploadUrl = [ARLSynchronisation RequestUploadUrl:imageName
                                                                       withRun:response.run.runId];
                    
                    Log(@"Upload URL: %@", uploadUrl);
                    
                    [ARLSynchronisation PerfomUploadToServer:uploadUrl
                                                withFileName:imageName
                                                 contentType:response.contentType
                                                    withData:response.data];
                    
                    NSString *uploadedUrl = [NSString stringWithFormat:@"%@/uploadService/%@/%@:%@/%@",
                                             serverUrl,
                                             response.run.runId,
                                             [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"],
                                             [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"],
                                             imageName];
                    
                    response.fileName = uploadedUrl;
                    
                    // Log(@"Uploaded: %@", serverUrl);
                    
                    NSDictionary *myDictionary;
                    
                    NSString * urlType;
                    
                    if ([response.contentType isEqualToString:@"audio/aac"]) urlType = @"audioUrl";
                    if ([response.contentType isEqualToString:@"audio/mp3"]) urlType = @"audioUrl";
                    if ([response.contentType isEqualToString:@"audio/amr"]) urlType = @"audioUrl";
                    if ([response.contentType isEqualToString:@"application/jpg"]) urlType = @"imageUrl";
                    if ([response.contentType isEqualToString:@"video/quicktime"]) urlType = @"videoUrl";
                    
                    if ([response.width intValue] == 0) {
                        myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        uploadedUrl,            urlType,
                                        nil];
                        
                    } else {
                        myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        response.width,         @"width",
                                        response.height,        @"height",
                                        uploadedUrl,            urlType,
                                        nil];
                    }
                    
                    NSString* jsonString = [ARLUtils jsonString:myDictionary];
                    
                    [ARLSynchronisation publishResponse:response.run.runId
                                          responseValue:jsonString
                                                 itemId:response.generalItem.generalItemId
                                              timeStamp:response.timeStamp];
                    
                    response.synchronized = [NSNumber numberWithBool:YES];
                }
            }
            
            // Saves any modification made after ManagedObjectFromDictionary.
            [ctx MR_saveToPersistentStoreAndWait];

            [[NSNotificationCenter defaultCenter] postNotificationName:ARL_SYNCPROGRESS
                                                                object:NSStringFromClass([Response class])];
        }

        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ARL_SYNCREADY
                                                        object:NSStringFromClass([Response class])];
}

+ (void) publishResponse:(NSNumber *)runId
           responseValue:(NSString *)value
                  itemId:(NSNumber *)generalItemId
               timeStamp:(NSNumber *)timeStamp
{
    NSString* accountType = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"];
    NSString* accountLocalId = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"];
    NSString* account = [NSString stringWithFormat:@"%@:%@", accountType, accountLocalId];
    
    NSDictionary *responseDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  value,              @"responseValue",
                                  runId,              @"runId",
                                  generalItemId,      @"generalItemId",
                                  timeStamp,          @"timestamp",
                                  account,            @"userEmail",
                                  nil];
    
    [ARLNetworking sendHTTPPostWithAuthorization:@"response"
                                            json:responseDict];
}

/*!
 *  Generate the upload Url.
 *
 *  @param fileName <#fileName description#>
 *  @param runId    <#runId description#>
 *
 *  @return <#return value description#>
 */
+ (NSString *) RequestUploadUrl:(NSString *)fileName
                        withRun:(NSNumber *)runId {
    NSString *str =[NSString stringWithFormat:@"runId=%@&account=%@:%@&fileName=%@",
                    runId,
                    [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"],
                    [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"],
                    fileName];
    
    NSData *data = [ARLNetworking sendHTTPPostWithAuthorization:@"/uploadServiceWithUrl"
                                                           data:[str dataUsingEncoding:NSUTF8StringEncoding]
                                                     withAccept:textplain
                                                withContentType:xwwformurlencode];
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return response;
}

/*!
 *  Perform an upload of a File.
 *
 *  @param uploadUrl     <#uploadUrl description#>
 *  @param fileName      <#fileName description#>
 *  @param contentTypeIn <#contentTypeIn description#>
 *  @param data          <#data description#>
 */
+ (void) PerfomUploadToServer:(NSString *)uploadUrl
                 withFileName:(NSString *)fileName
                  contentType:(NSString *)contentTypeIn
                     withData:(NSData *)data {
    DLog(@"Uploading %@ - %@", contentTypeIn, fileName);
    
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    if (data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploaded_file\"; filename=\"%@\"\r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", contentTypeIn] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // uploadUrl = [uploadUrl stringByReplacingOccurrencesOfString:@"localhost:8888" withString:@"192.168.1.8:8080"];
    [request setURL:[NSURL URLWithString: uploadUrl]];
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:&error];
    ELog(error);
    
    if (response.statusCode!=200) {
        DLog(@"%@ %d", response.URL, response.statusCode);
    }
    
    DLog(@"Uploaded %@ - %@", contentTypeIn, fileName);
}

@end
