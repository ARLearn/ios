//
//  INQWebViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 5/8/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "ARLWebViewController.h"

@interface ARLWebViewController ()

@end

@implementation ARLWebViewController

@synthesize html = _html;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    UIWebView *webView = (UIWebView *)self.view;
    
    webView.scalesPageToFit = YES;
    webView.contentMode = UIViewContentModeScaleAspectFit;
    webView.allowsInlineMediaPlayback = YES;
    
    [webView setDelegate:self];
    [webView loadHTMLString:self.html baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //
}

-(void)viewWillDisappear:(BOOL)animated {
//    UIWebView *webView = (UIWebView *)self.view;
//    
//    [webView loadHTMLString:@"<html><head /><body /></html>" baseURL:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIWebViewDelegate

// See http://stackoverflow.com/questions/8490038/open-target-blank-links-outside-of-uiwebview-in-safari
//
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:request.URL];
        return false;
    }
    
    return true;
}

@end
