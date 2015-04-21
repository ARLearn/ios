//
//  ARLAppDelegate.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/9/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "CoreData+MagicalRecord.h"

#import "Reachability.h"

#import "ARLUtils.h"
#import "ARLNotificationSubscriber.h"
#import "ARLQueryCache.h"
#import "ARLNetworking.h"

#import "Account.h"
#import "Action.h"
#import "CurrentItemVisibility.h"
#import "Game.h"
#import "GeneralItem.h"
#import "GeneralItemData.h"
#import "GeneralItemVisibility.h"
#import "Inquiry.h"
#import "Message.h"
#import "Response.h"
#import "Run.h"
#import "SynchronizationBookKeeping.h"

@interface ARLAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

/*!
 *  Static read-only Property.
 *
 *  @return The NSOperationQueue.
 */
+(NSOperationQueue *) theOQ;

+(CLLocationCoordinate2D) CurrentLocation;

+(ARLQueryCache *) theQueryCache;

+(NSCondition *) theAbortLock;

- (void) LogOut;

//@property (readonly, strong, nonatomic) NSNumber *isLoggedIn;
//@property (readonly, strong, nonatomic) NSNumber *networkAvailable;
//@property (readonly, strong, nonatomic) Account *CurrentAccount;

@end
