//
//  ARLVideoPlayerViewController.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 09/10/15.
//  Copyright © 2015 Open University of the Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GeneralItem.h"

#import "ARLCoreDataUtils.h"
#import "ARLBeanNames.h"

@interface ARLVideoPlayerViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) GeneralItem *activeItem;
@property (strong, nonatomic) NSNumber *runId;

@end
