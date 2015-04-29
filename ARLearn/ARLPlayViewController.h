//
//  ARLPlayViewController.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 05/01/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#import "Action.h"
#import "GeneralItem.h"
#import "GeneralItemVisibility.h"
#import "Run.h"

#import "ARLCoreDataUtils.h"
#import "ARLBeanNames.h"
#import "ARLUtils.h"
#import "ARLNetworking.h"
#import "ARLGeneralItemViewController.h"
#import "ARLNarratorItemViewController.h"
#import "ARLMyGamesViewController.h"
#import "ARLAudioPlayer.h"
#import "ARLSynchronisation.h"

@interface ARLPlayViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate, NSFetchedResultsControllerDelegate, UINavigationControllerDelegate, UIWebViewDelegate>

@property (strong, nonatomic) NSNumber *gameId;

@property (strong, nonatomic) NSNumber *runId;

- (void) setBackViewControllerClass:(Class)viewControllerClass;

@end
