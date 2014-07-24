//
//  ARLNotificationSubscriber.h
//  ARLearn
//
//  Created by Stefaan Ternier on 1/28/13.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLUtils.h"

//@protocol NotificationHandler <NSObject>
//
//@required
//- (void) onNotification : (NSDictionary*) notification;
//
//@end

@interface ARLNotificationSubscriber : NSObject

//+ (ARLNotificationSubscriber *) sharedSingleton;

+ (void) registerAccount: (NSString* ) fullId;

//- (void) dispatchMessage: (NSDictionary *) message;
//
//- (void) addNotificationHandler: (NSString *) notificationType handler:(id <NotificationHandler>) notificationHandler;
//
@end
