//
//  ARLSettingsViewController.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 30/11/15.
//  Copyright © 2015 Open University of the Netherlands. All rights reserved.
//

#import "ARLSettingsViewController.h"

@interface ARLSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIView *logoutView;
@property (weak, nonatomic) IBOutlet UILabel *logoutLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

- (IBAction)LogoutAction:(UIButton *)sender;

@end

@implementation ARLSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.logoutButton.layer.cornerRadius = 4;
    self.logoutButton.layer.borderWidth = 2;
    self.logoutButton.layer.borderColor =  self.logoutButton.tintColor.CGColor;
    // (note - may prefer to use the tintColor of the control)
    
    [self.logoutButton setEnabled:ARLNetworking.isLoggedIn];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void) applyConstraints {
    NSDictionary *viewsDictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      self.view,             @"view",
                                      
                                      self.backgroundImage,  @"backgroundImage",
                                      
                                      self.logoutView,       @"logoutView",
                                      
                                      nil];
    
    // See http://stackoverflow.com/questions/17772922/can-i-use-autolayout-to-provide-different-constraints-for-landscape-and-portrait
    // See https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/Bars.html
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.logoutView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.logoutLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.logoutButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Fix Background.
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|[backgroundImage]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary1]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[backgroundImage]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary1]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[logoutView]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary1]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-[logoutView]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary1]];
    
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.logoutView,       @"logoutView",
                                     
                                     self.logoutLabel,      @"logoutLabel",
                                     self.logoutButton,     @"logoutButton",
                                     
                                     nil];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-[logoutLabel(==logoutButton)]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[logoutLabel]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[logoutButton]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Actions

- (IBAction)LogoutAction:(UIButton *)sender {
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate LogOut];
    
    [self.logoutButton setEnabled:ARLNetworking.isLoggedIn];
}

@end
