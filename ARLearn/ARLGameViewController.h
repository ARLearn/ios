//
//  ARLGameViewController.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/28/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//
#import "ARLAppDelegate.h"
#import "ARLNetworking.h"
#import "ARLBeanNames.h"

#import "ARLDownloadViewController.h"

#import "Game.h"

@interface ARLGameViewController : UIViewController <NSURLSessionDataDelegate, UIAlertViewDelegate, UIWebViewDelegate>

@property (strong, nonatomic) NSNumber *gameId;

@property (strong, nonatomic) NSNumber *runId;

- (void) setBackViewControllerClass:(Class)viewControllerClass;

@end
