//
//  ARLAudioPlayer.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 23/04/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "GeneralItem.h"

#include "ARLCoreDataUtils.h"
#include "ARLBeanNames.h"

@interface ARLAudioPlayer : UIViewController <AVAudioPlayerDelegate, UIWebViewDelegate>

@property (strong, nonatomic) GeneralItem *activeItem;

@property (strong, nonatomic) NSNumber *runId;

@end
