//
//  INQWebViewController.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 5/8/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARLWebViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSString *html;

@end
