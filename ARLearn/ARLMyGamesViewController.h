//
//  ARLMyGamesViewController.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/29/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARLAppDelegate.h"
#import "ARLNetworking.h"
#import "ARLUtils.h"
#import "ARLQueryCache.h"
#import "ARLDownloadViewController.h"

@interface ARLMyGamesViewController : UITableViewController <UITableViewDataSource, NSURLSessionDataDelegate>

@end
