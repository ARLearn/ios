//
//  ARLAudioPlayerControl.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 04/03/16.
//  Copyright © 2016 Open University of the Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARLUtils.h"
#import "ARLCoreDataUtils.h"
#import "ARLBeanNames.h"

IB_DESIGNABLE

@interface ARLAudioPlayerControl : UIControl

//- (id)initWithWidth:(float)width;
- (id) initWithFrame:(CGRect)frame;
- (id) initWithCoder:(NSCoder *)aDecoder;

- (void) load:(NSURL *) audioUrl
     autoPlay:(BOOL) autoPlay
   completion:(ARLCompletion) completion;

-(void) unload;

@property (strong, nonatomic) IBOutlet UIView *view;

@end
