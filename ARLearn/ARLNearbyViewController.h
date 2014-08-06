//
//  ARLNearbyViewController.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/22/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "TPMultiLayoutViewController.h"

#import "ARLAppDelegate.h"
#import "ARLNetworking.h"
#import "ARLUtils.h"
#import "ARLGamePin.h"

@interface ARLNearbyViewController : TPMultiLayoutViewController <MKMapViewDelegate, NSURLSessionDataDelegate>

@end
