//
//  ARLAppDelegate.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/9/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "CoreData+MagicalRecord.h"

#import "ARLUtils.h"
#import "ARLNotificationSubscriber.h"

@interface ARLAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

/*!
 *  Static read-only Property.
 *
 *  @return The NSOperationQueue.
 */
+(NSOperationQueue *) theOQ;

+(CLLocationCoordinate2D) CurrentLocation;

@end
