//
//  ARLSettingsViewController.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 30/11/15.
//  Copyright © 2015 Open University of the Netherlands. All rights reserved.
//

#import "ARLSettingsViewController.h"

@interface ARLSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *Logout;

- (IBAction)LogoutAction:(UIButton *)sender;

@end

@implementation ARLSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.Logout.layer.cornerRadius = 4;
    self.Logout.layer.borderWidth = 2;
    self.Logout.layer.borderColor =  self.Logout.tintColor.CGColor;
    // (note - may prefer to use the tintColor of the control)
    
    [self.Logout setEnabled:ARLNetworking.isLoggedIn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
 }
 */

- (IBAction)LogoutAction:(UIButton *)sender {
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate LogOut];
    
    [self.Logout setEnabled:ARLNetworking.isLoggedIn];
}

@end
