//
//  ARLButton.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/28/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARLButton : UIButton

-(void)makeButtonWithImage:(NSString *)image
                     title:(NSString *)title
                titleColor:(UIColor *)color;

@end
