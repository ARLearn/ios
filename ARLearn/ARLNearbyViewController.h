//
//  ARLNearbyViewController.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/22/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//
#import "UIViewController+UI.h"

#import "ARLAppDelegate.h"
#import "ARLNetworking.h"
#import "ARLUtils.h"
#import "ARLGamePin.h"
#import "ARLGameViewController.h"

@interface ARLNearbyViewController : UIViewController <MKMapViewDelegate, NSURLSessionDataDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@end
