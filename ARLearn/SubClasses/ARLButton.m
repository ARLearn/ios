//
//  ARLButton.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/28/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLButton.h"

@implementation ARLButton

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
                     title:(NSString *)title
                titleColor:(UIColor *)color {
    
    [self addGradient2:[UIColor yellowColor] end:[UIColor redColor]];
    self.titleLabel.text = title;
    self.titleLabel.textColor = color;
    
    self.imageView.image = [UIImage imageNamed:image];
    
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [self layoutSubviews];
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

-(void) addGradient:(UIColor *)start end:(UIColor *)end {
    CGSize size = self.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Create a colour space:
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    // Now create the gradient:
    
    //size_t gradientNumberOfLocations = 2;
    //CGFloat gradientLocations[2] = { 0.0, 1.0 };
    //    CGFloat gradientComponents[8] = { start.r0, g0, b0, a0,     // Start color
    //        r1, g1, b1, a1, };  // End color
    NSArray *gradientColors = [NSArray arrayWithObjects:start, end, nil];
    
    //CGGradientRef gradient = CGGradientCreateWithColorComponents (colorspace, gradientComponents, gradientLocations, gradientNumberOfLocations);
    CGGradientRef gradient = CGGradientCreateWithColors(colorspace, (CFArrayRef)gradientColors, nil);
    
    // Fill the context with the gradient - this assumes a vertical gradient:
    
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, size.height), 0);
    
    // Now you can create an image from the context:
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Finally release the gradient, colour space and context:
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    UIGraphicsEndImageContext();
}

-(void) addGradient2:(UIColor *)start end:(UIColor *)end {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = self.layer.bounds;
    gradient.locations =  [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
    gradient.colors = [NSArray arrayWithObjects:start, end, nil];
    
    [self.layer addSublayer:gradient];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
