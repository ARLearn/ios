//
//  ARLGameViewController.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/28/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//
#import "ARLAppDelegate.h"
#import "ARLNetworking.h"

#import "Game.h"

@interface ARLGameViewController : UIViewController <NSURLSessionDataDelegate>

@property (strong, nonatomic) NSNumber *gameId;

@end
