//
//  ARLSearchViewController.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/16/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARLAppDelegate.h"
#import "ARLNetworking.h"
#import "ARLUtils.h"
#import "ARLQueryCache.h"
#import "ARLGameViewController.h"

@interface ARLSearchViewController : UITableViewController <UITableViewDataSource, NSURLSessionDataDelegate>

@end
