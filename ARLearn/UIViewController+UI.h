//
//  UITableViewController_uistuff.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 7/3/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (UI)

@property (readonly, nonatomic) CGFloat navbarWidth;
@property (readonly, nonatomic) CGFloat navbarHeight;
@property (readonly, nonatomic) CGFloat tabbarHeight;
@property (readonly, nonatomic) CGFloat statusbarHeight;

@property (readonly, nonatomic) UIInterfaceOrientation interfaceOrientation;

@property (readonly, nonatomic) CGFloat screenWidth;
@property (readonly, nonatomic) CGFloat screenHeight;

@end

