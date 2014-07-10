//
//  ARLNotificationSubscriber.m
//  ARLearn
//
//  Created by Stefaan Ternier on 1/28/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLNotificationSubscriber.h"

@implementation ARLNotificationSubscriber
{
    NSMutableDictionary * notDict;
}

static ARLNotificationSubscriber *_sharedSingleton;

+ (ARLNotificationSubscriber *)sharedSingleton {
    @synchronized(_sharedSingleton) {
        _sharedSingleton = [[ARLNotificationSubscriber alloc] init];
    }
    return _sharedSingleton;
}

- (id) init {
    self = [super init];
    
    notDict = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void) registerAccount: (NSString *) fullId {
    NSString *deviceUniqueIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceUniqueIdentifier"];
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    [self registerDevice:deviceToken
                 withUID:deviceUniqueIdentifier
             withAccount:fullId
            withBundleId:bundleIdentifier];
}

//TODO: Test this code next!
- (void) registerDevice: (NSString *) deviceToken
                withUID: (NSString *) deviceUniqueIdentifier
            withAccount: (NSString *) account
           withBundleId: (NSString *) bundleIdentifier {
    
    //FIXME: Removed account check.
    //if (!account) return;
    
    //TODO: Hardcode bundleIdentifier/account with values from weSPOT PIM.
    
    NSDictionary *apnRegistrationBean = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         @"org.celstec.arlearn2.beans.notification.APNDeviceDescription",   @"type",
                                         account,                                                           @"account",
                                         deviceUniqueIdentifier,                                            @"deviceUniqueIdentifier",
                                         deviceToken,                                                       @"deviceToken",
                                         bundleIdentifier,                                                  @"bundleIdentifier",
                                         nil];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:apnRegistrationBean
                                                       options:0 error:nil];
    
    [self executeARLearnPOST:@"notifications/apn"
                    postData:postData
                  withAccept:nil
             withContentType:applicationjson];
}

//TODO: Sanitize code (static again)?
- (NSMutableURLRequest *) prepareRequest: (NSString *)method
                          requestWithUrl: (NSString *) url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60.0];
    [request
     setHTTPMethod:method];
    
    [request
     setValue:applicationjson
     forHTTPHeaderField:accept];
    
    return request;
}

//TODO: Sanitize code (static again)?
- (id) executeARLearnPOST: (NSString *) path
                 postData: (NSData *) data
               withAccept: (NSString *) acceptValue
          withContentType: (NSString *) ctValue
{
    NSString* urlString;
    
    if ([path hasPrefix:@"/"]) {
        urlString = [NSString stringWithFormat:@"%@%@", serviceUrl, path];
    } else {
        urlString = [NSString stringWithFormat:@"%@/rest/%@", serviceUrl, path];
    }
    
    NSMutableURLRequest *request = [self prepareRequest:@"POST" requestWithUrl:urlString];
    
    [request setHTTPBody:data];
    
    if (ctValue) {
        [request setValue:ctValue forHTTPHeaderField:contenttype];
    }
    
    if (acceptValue) {
        [request setValue:acceptValue forHTTPHeaderField:accept];
    }
    
    NSData *jsonData = [ NSURLConnection sendSynchronousRequest:request
                                              returningResponse: nil
                                                          error: nil];
   
    if ([acceptValue isEqualToString:textplain]) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        // return [NSString stringWithUTF8String:[jsonData bytes]];
    }
    
    // [self dumpJsonData:jsonData url:urlString];
    
    NSError *error = nil;
    return jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData
                                                      options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                        error:&error] : @"error";
}

//- (void) dispatchMessage: (NSDictionary *) message {
//    if (ARLNetwork.networkAvailable) {
//        message = [message objectForKey:@"aps"];
//        
//        if ([@"org.celstec.arlearn2.beans.run.User" isEqualToString:[message objectForKey:@"type"]]) {
//            ARLCloudSynchronizer* synchronizer = [[ARLCloudSynchronizer alloc] init];
//            
//            ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
//            [synchronizer createContext:appDelegate.managedObjectContext];
//            
//            synchronizer.syncRuns = YES;
//            synchronizer.syncGames = YES;
//            
//            [synchronizer sync];
//        }
//        
//        if ([@"org.celstec.arlearn2.beans.notification.RunModification" isEqualToString:[message objectForKey:@"type"]]) {
//            DLog(@"About to update runs %@", [[message objectForKey:@"run"] objectForKey:@"runId"]);
//            
//            ARLCloudSynchronizer* synchronizer = [[ARLCloudSynchronizer alloc] init];
//            
//            ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
//            [synchronizer createContext:appDelegate.managedObjectContext];
//            
//            synchronizer.syncRuns = YES;
//            
//            [synchronizer sync];
//        }
//        
//        if ([@"org.celstec.arlearn2.beans.notification.GeneralItemModification" isEqualToString:[message objectForKey:@"type"]]) {
//            DLog(@"About to update gi %@", [message objectForKey:@"itemId"] );
//            
//            ARLCloudSynchronizer* synchronizer = [[ARLCloudSynchronizer alloc] init];
//            
//            ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
//            [synchronizer createContext:appDelegate.managedObjectContext];
//            
//            synchronizer.gameId = [NSDecimalNumber decimalNumberWithString:[message objectForKey:@"gameId"]];
//            synchronizer.visibilityRunId = [NSDecimalNumber decimalNumberWithString:[message objectForKey:@"runId"]];
//            
//            [synchronizer sync];
//        }
//    }
//    
//    NSMutableSet *set = [notDict objectForKey:[message objectForKey:@"type"]];
//    for (id <NotificationHandler> listener in set) {
//        [listener onNotification:message];
//    }
//}

//- (void) addNotificationHandler: (NSString *) notificationType handler:(id <NotificationHandler>) notificationHandler {
//    if (![notDict valueForKey:notificationType]) {
//        [notDict setObject:[[NSMutableSet alloc] init] forKey:notificationType];
//    }
//    
//    [[notDict valueForKey:notificationType] addObject:notificationHandler];
//}

@end
