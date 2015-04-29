//
//  ARLDownloadViewController.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 05/12/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "UIViewController+UI.h"
#import "UIImage-categories/UIImage+Alpha.h"

#import "ARLAppDelegate.h"
#import "ARLNetworking.h"
#import "ARLPlayViewController.h"

#import "GeneralItem.h"
#import "Run.h"
#import "Game.h"

@interface ARLDownloadViewController : UIViewController

@property (strong, nonatomic) NSNumber *gameId;

@property (strong, nonatomic) NSNumber *runId;

- (void) setBackViewControllerClass:(Class)viewControllerClass;

@end
