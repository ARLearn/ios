//
//  ARLGeneralItemViewController.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 01/02/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#import "ARLUtils.h"
#import "ARLBeanNames.h"
#import "ARLNetworking.h"
#import "ARLSynchronisation.h"
#import "ARLCoreDataUtils.h"

#import "Action.h"
#import "GeneralItem.h"

@interface ARLGeneralItemViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UIWebViewDelegate>

@property (strong, nonatomic) NSNumber *runId;

@property (strong, nonatomic) GeneralItem *activeItem;

@end
