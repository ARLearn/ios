//
//  UIButton+UI.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/15/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "UIButton+UI.h"

@implementation UIButton (UI)

/*!
 *  See https://gist.github.com/jalopezsuarez/2c8f430636d89a58099b
 */
const int kTextTopPadding = 2;

///*!
// *  See https://gist.github.com/jalopezsuarez/2c8f430636d89a58099b
// */
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

    self.titleLabel.text = title;
    self.titleLabel.textColor = color;
    
    self.imageView.image = [UIImage imageNamed:image];
   
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];

    [self layoutSubviews];
}

/*!
 *  See https://gist.github.com/jalopezsuarez/2c8f430636d89a58099b
 */
-(void) layoutSubviews {
    [super layoutSubviews];

    if (self.tag == TILE) {
        // DLog(@"Layout of Button: %@", self.titleLabel.text);
        
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
