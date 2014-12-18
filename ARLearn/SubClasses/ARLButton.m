//
//  ARLButton.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/28/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLButton.h"

@implementation ARLButton

static float radius = 10.f;

/*!
 *  See https://gist.github.com/jalopezsuarez/2c8f430636d89a58099b
 */
const int kTextTopPadding = 2;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*!
 *  Fix for Black Text and other missing/default properties.
 *
 *  This method must be called inside teh ViewController's viewDidLoad.
 *
 *  @param image the Image Name.
 *  @param title the Button Title.
 *  @param color the Button Text Color.
 */
-(void)makeButtonWithImage:(NSString *)image
                 titleText:(NSString *)title
                titleColor:(UIColor *)color {
    
    // Fails to set the title!
    // self.titleLabel.text = title;
    
    // This however works!
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateDisabled];
    // [self setTitle:title forState:UIControlStateSelected];
    // [self setTitle:title forState:UIControlStateHighlighted];
    
    // Fails to set the color!
    // self.titleLabel.textColor = color;
    
    // This however works!
    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateDisabled];
    // [self setTitleColor:color forState:UIControlStateSelected];
    // [self setTitleColor:color forState:UIControlStateHighlighted];
    
    self.backgroundColor = [UIColor clearColor];
    
    [self setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [self setImage:[ARLUtils grayishImage:[UIImage imageNamed:image]] forState:UIControlStateDisabled];
    //[ARLUtils grayishImage:[UIImage imageNamed:image]]
    // self.imageView.image = [UIImage imageNamed:image];
    
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
}

-(void)makeButtonWithImageAndGradient:(NSString *)image
                            titleText:(NSString *)title
                           titleColor:(UIColor *)color
                           startColor:(UIColor *)start
                             endColor:(UIColor *)end {
    
    [self makeButtonWithImage:image titleText:title titleColor:color];
    
    //    for(CALayer* layer in self.layer.sublayers)
    //    {
    //        if ([layer isKindOfClass:[CAGradientLayer class]])
    //        {
    //            [layer removeFromSuperlayer];
    //        }
    //    }
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = self.layer.bounds;
    gradient.locations =  [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
    gradient.colors = [NSArray arrayWithObjects:(id)start.CGColor, (id)end.CGColor, nil];
    //BottomLeft
    gradient.startPoint = CGPointMake(0, 0);
    //TopRight
    gradient.endPoint = CGPointMake(1, 1);
    gradient.cornerRadius = radius;
    
    // [self.layer insertSublayer:gradient atIndex:1];
    if (self.layer.sublayers.count>0)
    {
        [self.layer insertSublayer:gradient atIndex:self.layer.sublayers.count-2];
    } else {
        [self.layer addSublayer:gradient];
    }
}

-(void) layoutSubviews {
    [super layoutSubviews];
    
    CGSize labelSize =[self.titleLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                                         options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                      attributes:@{
                                                                   NSFontAttributeName:self.titleLabel.font
                                                                   }
                                                         context:nil].size;
    // 1) Adjust image size and location.
    
    CGRect imageFrame = self.imageView.frame;
    
    CGSize fitBoxSize = (CGSize){
        .height = labelSize.height + kTextTopPadding +  imageFrame.size.height,
        .width = MAX(imageFrame.size.width, labelSize.width)
    };
    
    CGRect fitBoxRect = CGRectInset(self.bounds,
                                    2*(self.bounds.size.width - fitBoxSize.width)/3,
                                    2*(self.bounds.size.height - fitBoxSize.height)/3);
    
    imageFrame.origin.y = fitBoxRect.origin.y;
    imageFrame.origin.x = CGRectGetMidX(fitBoxRect) - (imageFrame.size.width/2);
    self.imageView.frame = imageFrame;
    
    // 2) Adjust the label size to fit the text, and move it below the image
    
    CGRect titleLabelFrame = self.titleLabel.frame;
    
    titleLabelFrame.size.width = labelSize.width;
    titleLabelFrame.size.height = labelSize.height;
    titleLabelFrame.origin.x = (self.frame.size.width / 2) - (labelSize.width / 2);
    titleLabelFrame.origin.y = fitBoxRect.origin.y + imageFrame.size.height + kTextTopPadding;
    
    self.titleLabel.frame = titleLabelFrame;
}

@end
