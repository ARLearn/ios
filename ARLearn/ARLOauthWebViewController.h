//
//  ARLOauthWebViewController.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 11/11/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARLAppDelegate.h"
#import "ARLNetworking.h"

@interface ARLOauthWebViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) NSString * domain;
@property (strong, nonatomic) UINavigationController *NavigationAfterClose;

- (void)loadAuthenticateUrl:(NSString *)authenticateUrl name:(NSString *) name delegate:(id) aDelegate;

@end
