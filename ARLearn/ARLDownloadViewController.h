//
//  ARLDownloadViewController.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 05/12/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLAppDelegate.h"
#import "ARLNetworking.h"

#import "GeneralItem.h"

@interface ARLDownloadViewController : UIViewController

@property (strong, nonatomic) NSNumber *gameId;
@property (strong, nonatomic) NSArray *gameFiles;

@end
