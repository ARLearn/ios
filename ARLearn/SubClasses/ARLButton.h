//
//  ARLButton.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/28/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

//#import <UIKit/UIKit.h>
//#import <QuartzCore/QuartzCore.h>

#import "ARLUtils.h"

@interface ARLButton : UIButton

-(void)makeButtonWithImage:(NSString *)image
                 titleText:(NSString *)title
                titleColor:(UIColor *)color;

-(void)makeButtonWithImageAndGradient:(NSString *)image
                            titleText:(NSString *)title
                           titleColor:(UIColor *)color
                           startColor:(UIColor *)start
                             endColor:(UIColor *)end;
@end
