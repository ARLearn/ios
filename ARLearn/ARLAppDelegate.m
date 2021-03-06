//
//  ARLAppDelegate.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/9/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLAppDelegate.h"

@interface ARLAppDelegate ()

@property (readonly, strong, nonatomic) NSNumber *isLoggedIn;
@property (readonly, strong, nonatomic) NSNumber *networkAvailable;
@property (readonly, strong, nonatomic) Account *CurrentAccount;

@end

@implementation ARLAppDelegate

@synthesize isLoggedIn = _isLoggedIn;
@synthesize CurrentAccount = _CurrentAccount;
@synthesize networkAvailable = _networkAvailable;

static NSCondition *_theAbortLock;

/*!
 *  The Lock for the AbortDialog Code (wait until dismissed before continuing code).
 *
 *  @return <#return value description#>
 */
+ (NSCondition *) theAbortLock {
    if(!_theAbortLock){
        _theAbortLock = [[NSCondition alloc] init];
        //[_theAbortLock setName:@"Show Abort Condition"];
    }
    return _theAbortLock;
}

#pragma mark - AppDelegate

/*!
 *  Override point for customization after application launch.
 *
 *  @param application   <#application description#>
 *  @param launchOptions <#launchOptions description#>
 *
 *  @return <#return value description#>
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    DLog(@"didFinishLaunchingWithOptions");
     
    NSSetUncaughtExceptionHandler(&exceptionHandler);

    //TODO: Register and Process APN's found in the launchOptions.
    
    [ARLUtils LogGitInfo];
    
    _networkAvailable = [NSNumber numberWithBool:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    Reachability *reach = [Reachability reachabilityWithHostname:serverUrl];
    
    [reach startNotifier];
    
    [self setup_MR_DB];

    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:ENABLE_LOGGING];
    
    // DLog(@"Logging: %d", [[NSUserDefaults standardUserDefaults] boolForKey:ENABLE_LOGGING]);
    // DLog(@"Logging: %@", [NSNumber numberWithBool:[ARLLog LogOn]]);
    
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(
    //                                                                           UIRemoteNotificationTypeAlert |
    //                                                                           UIRemoteNotificationTypeBadge |
    //                                                                           UIRemoteNotificationTypeSound
    //                                                                           )];
    
    [self startStandardUpdates];
    
    _networkAvailable = [NSNumber numberWithBool:[self connected] && [self serverok]];
    
    if (ARLNetworking.networkAvailable) {
        [ARLNetworking setupOauthInfo];
    }
    
    [self doRegisterForAPN:application];
    
    // See User Interface Customizatin in iOS 6.0 Ray Wenderlich
    // See http://www.raywenderlich.com/21703/user-interface-customization-in-ios-6
    
    // [self customizeAppearance];
    
    return YES;
}

/*!
 *  Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions 
 *  (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
 *  Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
 *
 *  @param application <#application description#>
 */
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    DLog(@"%@", @"applicationWillResignActive");
    
    // TODO Save Database.
}

/*!
 *   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore 
 *   your application to its current state in case it is terminated later.
 *   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
 *
 *  @param application <#application description#>
 */
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    // 2) PRESSING HOME.
    
    DLog(@"%@", @"applicationDidEnterBackground");
    
    // [MagicalRecord cleanUp];
}

/*!
 *  Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
 *
 *  @param application <#application description#>
 */
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    DLog(@"%@", @"applicationWillEnterForeground");
    
    // [self setup_MR_DB];
    
    // 3) REACTIVATIONS #1.
    _networkAvailable = [NSNumber numberWithBool:[self connected] && [self serverok]];
    
    if (![_networkAvailable isEqualToNumber:[NSNumber numberWithInt:0]]) {
        // TODO Add code to sync right after restarting/re-activation.
    }
}

/*!
 *  Restart any tasks that were paused (or not yet started) while the application was inactive. 
 *  If the application was previously in the background, optionally refresh the user interface.
 *
 *  @param application <#application description#>
 */

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  
    DLog(@"%@", @"applicationDidBecomeActive");
    
    // 1) AFTER STARTUP.
    // 4) REACTIVATIONS #2.
    
    // DLog(@"%@", @"applicationDidBecomeActive");

}

/*!
 *  Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
 *
 *  @param application <#application description#>
 */
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    DLog(@"%@", @"applicationWillTerminate");
    
    [MagicalRecord cleanUp];
}

#pragma mark - APN

/*!
 * Register for APN with Apple.
 *
 *  @param application <#application description#>
 */
- (void)doRegisterForAPN:(UIApplication *)application
{
    // See http://stackoverflow.com/questions/24216632/remote-notification-ios-8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
#ifdef __IPHONE_8_0
        //Right, that is the point
       UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                      |UIRemoteNotificationTypeSound) categories:nil];
        [application registerUserNotificationSettings:settings];
#endif
    } else {
        //register to receive notifications
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
        
    }
}

//TESTCODE: Remote notifications
/*!
 *  Called when receiving a Remote Notification.
 *
 *  @param app   <#app description#>
 *  @param notif <#notif description#>
 */
- (void)application:(UIApplication *)app didReceiveRemoteNotification:(UILocalNotification *)notif {
    //TODO: Implement
    DLog(@"didReceiveRemoteNotification: %@", notif.userInfo);
    
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
    NSString* newToken = [deviceToken description];
    
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // Store DeviceToken
    [[NSUserDefaults standardUserDefaults] setObject:newToken
                                              forKey:@"deviceToken"];
    
    //!!!: This UID behaves very different on iOS 1-6 and iOS 7.
    UIDevice *device = [UIDevice currentDevice];

    DLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", newToken);
    DLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", [device.identifierForVendor UUIDString]);
   
    [[NSUserDefaults standardUserDefaults] setObject:[device.identifierForVendor UUIDString]
                                               forKey:@"deviceUniqueIdentifier"];
    
    [ARLNotificationSubscriber registerAccount:@"2:wim@vander-vegt.nl"];
}

#ifdef __IPHONE_8_0
/*!
 *  See http://stackoverflow.com/questions/24485681/registerforremotenotifications-method-not-being-called-properly
 *
 *  @param application          <#application description#>
 *  @param notificationSettings <#notificationSettings description#>
 */
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    DLog(@"didRegisterUserNotificationSettings");
    
    // Register to receive notifications
    [application registerForRemoteNotifications];
}

//- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
//{
//    //handle the actions
//    if ([identifier isEqualToString:@"declineAction"]){
//    }
//    else if ([identifier isEqualToString:@"answerAction"]){
//    }
//}
#endif


/*!
 *  Registration Failure (for instance when running in the emulator);
 *
 *  @param application The application
 *  @param error       The error
 */
- (void)Implement:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //TODO: Implement
    DLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error.description);
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

/*!
 *  Retrn the Background Operations Qeueu
 *
 *  @return <#return value description#>
 */
+ (NSOperationQueue *) theOQ {
    static NSOperationQueue *_theOQ;

    @synchronized(_theOQ) {
        if(!_theOQ){
            _theOQ = [[NSOperationQueue alloc] init];
        }
    }
    return _theOQ;
}

/*!
 *  Return the Query Cache.
 *
 *  @return <#return value description#>
 */
+ (ARLQueryCache *) theQueryCache {
    static ARLQueryCache *_theQueryCache;
    
    @synchronized(_theQueryCache) {
        if(!_theQueryCache){
            _theQueryCache = [[ARLQueryCache alloc] init];
        }
    }
    return _theQueryCache;
}

/*!
 *  Getter for CurrentAccount.
 *
 *  Note: we need to cache the account because retrieving it
 *        in a different context or in the main ui thread might cause deadlock.
 *  Note: because IsLoggedIn is also a rad-only property we need to update the
 *        backing field.
 *  @return The Current Account.
 */
- (Account *) CurrentAccount {
    if (!_CurrentAccount) {
        
        DLog(@"accountLocalId: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"]);
        DLog(@"accountType: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"]);
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(localId = %@) AND (accountType = %@)",
                                  [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"],
                                  [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"]];
        
        NSArray *results = [Account MR_findAllWithPredicate:predicate];
        if ([results count]) {
            _CurrentAccount =  [results objectAtIndex:0];
        }
    }
    
    _isLoggedIn = [NSNumber numberWithBool:(_CurrentAccount)?YES:NO];
    
    return _CurrentAccount;
}

#pragma mark - Methods

/*!
 *  See http://stackoverflow.com/questions/10501358/objective-c-getting-line-number-or-full-stack-trace-from-debugger-error
 *
 *  @param exception <#exception description#>
 */
void exceptionHandler(NSException *exception)
{
    Log(@"%@",[exception name]);
    Log(@"%@",[exception reason]);
    Log(@"%@",[exception userInfo]);
    Log(@"%@",[exception callStackSymbols]);
    Log(@"%@",[exception callStackReturnAddresses]);
}

/*!
 * See User Interface Customizatin in iOS 6.0 Ray Wenderlich
 * See http://www.raywenderlich.com/21703/user-interface-customization-in-ios-6 
 */
- (void)customizeAppearance
{
    {
        // Create UINavigationBar Gradient
        //
       UIImage *gradient = [ARLUtils GradientImageFromColors:[UIColor redColor]
                                               bottomRightColor:[UIColor yellowColor]
                                                          width:[ARLUtils ScreenWidthForOrientation:UIInterfaceOrientationPortrait]
                                                         height:44];
        // Apply Portrait Gradient
        //
        [[UINavigationBar appearance] setBackgroundImage:gradient
                                           forBarMetrics:UIBarMetricsDefault];
    }
    
    {
        // Create UINavigationBar Gradient
        //
        UIImage *gradient = [ARLUtils GradientImageFromColors:[UIColor redColor]
                                               bottomRightColor:[UIColor yellowColor]
                                                          width:[ARLUtils ScreenWidthForOrientation:UIInterfaceOrientationLandscapeLeft]
                                                         height:32];
        
        // Apply Landscape Gradient
        //
        [[UINavigationBar appearance] setBackgroundImage:gradient
                                           forBarMetrics:UIBarMetricsCompact];
    }
    
    {
        // Customize the title text for *all* UINavigationBars
        //
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor blackColor],                                  UITextAttributeTextColor,
          
          //[UIColor blackColor],                                 UITextAttributeTextShadowColor,
          //[NSValue valueWithUIOffset:UIOffsetMake(0, -1)],      UITextAttributeTextShadowOffset,
          
          //[UIFont fontWithName:@"Arial-Bold" size:0.0],         UITextAttributeFont,
          nil]];
    }
    
    {
        // Shadow underneath the UINavigationBar.
        //
        UIImage *gradient = [ARLUtils GradientImageFromColors:[ARLUtils MakeColorTransparent:[UIColor yellowColor] alpha:0.5]
                                                   bottomRightColor:[ARLUtils MakeColorTransparent:[UIColor grayColor] alpha:0.0]
                                                              width:1
                                                             height:12];
        
        [[UINavigationBar appearance] setShadowImage:gradient];
    }
    
    {
        // Portrait Background Gradient.
        //
        UIImage *gradient = [ARLUtils GradientImageFromColors:[UIColor greenColor]
                                             bottomRightColor:[UIColor yellowColor]
                                                        width:1
                                                       height:30];
        
        // UIBarButtonItem Background Gradient.
        //
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[gradient resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)]
                                                          forState:UIControlStateNormal
                                                        barMetrics:UIBarMetricsDefault];
    }
    
    {
        // Landscape Background Gradient.
        //
        UIImage *gradient = [ARLUtils GradientImageFromColors:[UIColor greenColor]
                                             bottomRightColor:[UIColor yellowColor]
                                                        width:1
                                                       height:30];
        
        // UIBarButtonItem Background Gradient.
        //
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[gradient resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 5)]

                                                          forState:UIControlStateNormal
                                                        barMetrics:UIBarMetricsCompact];
    }
    
    {
        // UITableView
        //
        [[UITableView appearance] setTintColor:[UIColor redColor]];
        [[UITableView appearance] setSeparatorColor:[UIColor redColor]];
     
        // UITableViewItem
        [[UITableViewCell appearance] setBackgroundColor:[UIColor greenColor]];
    }
    
    {
        // UITableView
        //
        [[UITableView appearance] setTintColor:[UIColor redColor]];
        [[UITableView appearance] setSeparatorColor:[UIColor redColor]];
    }
    
    {
        UIImage *gradient = [ARLUtils GradientImageFromColors:[UIColor redColor]
                                             bottomRightColor:[UIColor yellowColor]
                                                        width:[ARLUtils ScreenWidthForOrientation:UIInterfaceOrientationPortrait]
                                                       height:44];
        
        [[UIToolbar appearance] setBackgroundImage:gradient
                                forToolbarPosition:UIBarPositionBottom
                                        barMetrics:UIBarMetricsDefault];
    }
    
    {
        // [UIView appearance] setBackgroundColor:<#(UIColor *)#>
    }
}

/*!
 *  Setup Magical Records controlled database.
 */
- (void)setup_MR_DB
{
    // Setup CoreData with MagicalRecord
    // Step 1. Setup Core Data Stack with Magical Record
    // Step 2. Relax. Why not have a beer? Surely all this talk of beer is making you thirsty…
    //
    //    [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:managedObjectStore.persistentStoreCoordinator];
    //    [NSManagedObjectContext MR_setRootSavingContext:managedObjectStore.persistentStoreManagedObjectContext];
    
    [MagicalRecord setShouldAutoCreateDefaultPersistentStoreCoordinator:YES];
    
    [NSManagedObjectContext MR_initializeDefaultContextWithCoordinator:[NSPersistentStoreCoordinator MR_defaultStoreCoordinator]];
    
    //[MagicalRecord setupAutoMigratingCoreDataStack];
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"ARLearn.sqlite"];
    
    Log(@"%@", [MagicalRecord currentStack]);
}

/*!
 *  Because CurrentAccount is a read-only property
 *  we need to reset the backing field when doing a logout.
 */
- (void) LogOut {
    // ARLAppDelegate.SyncAllowed = NO;
    
    [ARLAppDelegate deleteCurrentAccount];
    
    _CurrentAccount = nil;
    _isLoggedIn = FALSE;
}

/*!
 *  Remove all accounts and associated data.
 *
 *  Do not call this method directly  but use ARLAppDelegate.LogOut instead.
 *
 *  @param context The NSManagedObjectContext
 */
+ (void) deleteCurrentAccount {
    // Delete only the current account.
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(localId = %@) AND (accountType = %d)",
                              [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"],
                              [[[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"] intValue]];
    
    [ARLQueryCache clearCache];
    
    [Account MR_deleteAllMatchingPredicate:predicate];
    
    [Account MR_truncateAll];
    
    [Action MR_truncateAll];
    [CurrentItemVisibility MR_truncateAll];
    [Game MR_truncateAll];
    [GeneralItem MR_truncateAll];
    [GeneralItemData MR_truncateAll];
    [GeneralItemVisibility MR_truncateAll];
    
#warning include Inquiry table in ARLearn?
        
    [Inquiry MR_truncateAll];
    [Message MR_truncateAll];
    [Response MR_truncateAll];
    [Run MR_truncateAll];
    [SynchronizationBookKeeping MR_truncateAll];

    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

static CLLocationManager *locationManager;
static CLLocationCoordinate2D currentCoordinates;

/*!
 *  Use GPS to upate location.
 *
 *  See https://developer.apple.com/library/mac/documentation/General/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html
 */
- (void)startStandardUpdates
{
    // GPS Stein   is 50,9743553 - 5,7675690
    // GPS Heerlen is 50,8746769 - 5,950582172
    
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager) {
        locationManager = [[CLLocationManager alloc] init];
        
        // veg 02-10-2015 iOS 8+
        // see http://nevan.net/2014/09/core-location-manager-changes-in-ios-8/
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
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
        // veg 02-10-2015 iOS 8+
        // see http://nevan.net/2014/09/core-location-manager-changes-in-ios-8/
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
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
        
        if (ABS(howRecent) < 15.0) {
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

#pragma mark Reachability

/*!
 *  Getter for isLoggedIn property.
 *
 *  @return If TRUE the user is logged-in.
 */
- (NSNumber *)networkAvailable {
    // DLog(@"networkAvailable: %@", _networkAvailable);
    
    return _networkAvailable;
}

/*!
 *  Notification Handler for Reachability.
 *  Sets the networkAvailable property.
 *
 *  @param note The Reachability object.
 */
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability *reach = [note object];
    
    //WARNING: DEBUG LOGGING.
    
    DLog(@"Reachability Changed");
    DLog(@"From: %@", _networkAvailable);
    
    _networkAvailable = [NSNumber numberWithBool:[reach isReachable]];
    
    DLog(@"To: %@", _networkAvailable);
    
    DLog(@" All:  %d", [reach isReachable]);
    DLog(@" Wifi: %d", [reach isReachableViaWiFi]);
    DLog(@" WWan: %d", [reach isReachableViaWWAN]);
}


/*!
 *  Check if an internet connection exists.
 *
 *  @return <#return value description#>
 */
-(BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    return !(networkStatus == NotReachable);
}

/*!
 *  Check if the arlearn server is reachable.
 *
 *  @return <#return value description#>
 */
-(BOOL)serverok
{
    Reachability *reachability = [Reachability reachabilityWithHostname:serverUrl];
    
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    return !(networkStatus == NotReachable);
}

+(NSString *)deviceLanguage {
    return [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    //return [[NSLocale preferredLanguages] objectAtIndex:0];
}

@end

// See http://stackoverflow.com/questions/21025622/http-load-failed-kcfstreamerrordomainssl-9813-in-cordova-app
//@implementation NSURLRequest(DataController)
//+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
//{
//    Log(@"Host=%@", host);
//    
//    return YES;
//}
//"h@end