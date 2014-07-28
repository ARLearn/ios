//
//  ARLAppDelegate.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/9/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLAppDelegate.h"

@implementation ARLAppDelegate

#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    Log(@"didFinishLaunchingWithOptions");
    
//TODO: Register and Process APN's found in the launchOptions.
    [ARLUtils LogGitInfo];
    
    // Setup CoreData with MagicalRecord
    // Step 1. Setup Core Data Stack with Magical Record
    // Step 2. Relax. Why not have a beer? Surely all this talk of beer is making you thirsty…
    
    //[MagicalRecord setupAutoMigratingCoreDataStack];
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"ARLearn.sqlite"];
    
    //TESTCODE: ShowAbortMessage on a non main thread.
    {
        //        [[ARLAppDelegate theOQ] addOperationWithBlock:^{
        //            [ARLUtils ShowAbortMessage:@"TEST" withMessage:@"TEST" ];
        //        }];
    }
    
#warning FORCING LOGGING.
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:TRUE] forKey:ENABLE_LOGGING];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(
                                                                           UIRemoteNotificationTypeAlert |
                                                                           UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound
                                                                           )];
    
    [self startStandardUpdates];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [MagicalRecord cleanUp];
}

//TESTCODE: Remote notifications registration
- (void)applicationDidFinishLaunching:(UIApplication *)app {
//    // other setup tasks here....
//    Log(@"applicationDidFinishLaunching");
//    
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

#pragma mark - APN

//TESTCODE: Remote notifications
/*!
 *  Called when receiving a Remote Notification.
 *
 *  @param app   <#app description#>
 *  @param notif <#notif description#>
 */
- (void)application:(UIApplication *)app didReceiveRemoteNotification:(UILocalNotification *)notif {
    //TODO: Implement
    Log(@"didReceiveRemoteNotification: %@", notif.userInfo);
    
    //    NSString *itemName = [notif.userInfo objectForKey:ToDoItemKey];
    //    [viewController displayItem:itemName];  // custom method
    //    app.applicationIconBadgeNumber = notification.applicationIconBadgeNumber - 1;
}

/*!
 *  Registration Success.
 *
 *  @param application The application
 *  @param deviceToken The Device Token
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //TODO: Implement
    
    NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // Store DeviceToken
    [[NSUserDefaults standardUserDefaults] setObject:newToken
                                              forKey:@"deviceToken"];
    
    //!!!: This UID behaves very different on iOS 1-6 and iOS 7.
    UIDevice *device = [UIDevice currentDevice];

    Log(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", newToken);
    Log(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", [device.identifierForVendor UUIDString]);
   
    [[NSUserDefaults standardUserDefaults] setObject:[device.identifierForVendor UUIDString]
                                               forKey:@"deviceUniqueIdentifier"];
    
    [ARLNotificationSubscriber registerAccount:@"2:wim@vander-vegt.nl"];
}

/*!
 *  Registration Failure (for instance when running in the emulator);
 *
 *  @param application The application
 *  @param error       The error
 */
- (void)Implement:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //TODO: Implement
    Log(@"didFailToRegisterForRemoteNotificationsWithError: %@", error.description);
}

#pragma mark - Properties

/*!
 *  Returns the Current Location.
 *
 *  @return the current location.
 */
+ (CLLocationCoordinate2D) CurrentLocation {
    return currentCoordinates;
}

+ (NSOperationQueue *) theOQ {
    static NSOperationQueue *_theOQ;

    @synchronized(_theOQ) {
        if(!_theOQ){
            _theOQ = [[NSOperationQueue alloc] init];
        }
    }
    return _theOQ;
}

+ (ARLQueryCache *) theQueryCache {
    static ARLQueryCache *_theQueryCache;
    
    @synchronized(_theQueryCache) {
        if(!_theQueryCache){
            _theQueryCache = [[ARLQueryCache alloc] init];
        }
    }
    return _theQueryCache;
}

#pragma mark - Methods

static CLLocationManager *locationManager;
static CLLocationCoordinate2D currentCoordinates;

/*!
 *  Use GPS to upate location.
 *
 *  See https://developer.apple.com/library/mac/documentation/General/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html
 */
- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager) {
        locationManager = [[CLLocationManager alloc] init];
    }
    
    if (locationManager && CLLocationManager.locationServicesEnabled) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
        // Set a movement threshold for new events.ß
        locationManager.distanceFilter = 500; // meters
        
        // locationManager.pausesLocationUpdatesAutomatically = YES;
        
        [locationManager startUpdatingLocation];
    }
}

/*!
 *  Use WiFi to update location.
 */
- (void)startSignificantChangeUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager) {
        locationManager = [[CLLocationManager alloc] init];
    }
    
    if (locationManager && CLLocationManager.locationServicesEnabled) {
        
        locationManager.delegate = self;
        
        [locationManager startMonitoringSignificantLocationChanges];
    }
}

/*!
 *  Delegate method from the CLLocationManagerDelegate protocol.
 *
 *  @param manager   The CLLocationManager
 *  @param locations The locations to process.
 */
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    DLog(@"");
    
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation *location = [locations lastObject];
    
    if (location) {
        NSDate *eventDate = location.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        if (abs(howRecent) < 15.0) {
            // If the event is recent, do something with it.
            DLog(@"Lat: %+.6f, Long: %+.6f\n",
                 location.coordinate.latitude,
                 location.coordinate.longitude);
        }
        
        if (CLLocationCoordinate2DIsValid(location.coordinate)) {
            currentCoordinates = location.coordinate;
        }
    }
}

@end
