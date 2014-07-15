//
//  ARLCategoryViewController.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/15/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLStoreViewController.h"

@interface ARLStoreViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (weak, nonatomic) IBOutlet UIButton *SearchButton;
@property (weak, nonatomic) IBOutlet UIButton *CategoryButton;
@property (weak, nonatomic) IBOutlet UIButton *TopGamesButton;
@property (weak, nonatomic) IBOutlet UIButton *NearByButton;

- (IBAction)SearchButtonAction:(UIButton *)sender;
- (IBAction)CategoryButtonAction:(UIButton *)sender;
- (IBAction)TopGamesButtonAction:(UIButton *)sender;
- (IBAction)NearByButtonAction:(UIButton *)sender;

@end

@implementation ARLStoreViewController

#pragma mark - ViewController

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
    
    [self applyConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.SearchButton makeButtonWithImage:@"Search"
                                     title:NSLocalizedString(@"SearchLabel", @"SearchLabel")
                                titleColor:[UIColor whiteColor]];
    [self.CategoryButton makeButtonWithImage:@"Category"
                                       title:NSLocalizedString(@"CategoryLabel", @"CategoryLabel")
                                  titleColor:[UIColor whiteColor]];
    [self.TopGamesButton makeButtonWithImage:@"TopGames"
                                       title:NSLocalizedString(@"TopGamesLabel", @"TopGamesLabel")
                                  titleColor:[UIColor whiteColor]];
    [self.NearByButton makeButtonWithImage:@"NearBy"
                                     title:NSLocalizedString(@"NearByLabel", @"NearByLabel")
                                titleColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Properties

/*************************************************************************************/

#pragma mark - Methods

- (void) applyConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.backgroundImage,  @"backgroundImage",
                                     
                                     self.SearchButton,     @"SearchButton",
                                     self.CategoryButton,   @"CategoryButton",
                                     self.TopGamesButton,   @"TopGamesButton",
                                     self.NearByButton,     @"NearByButton",
                                     
                                     nil];
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.SearchButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.CategoryButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.TopGamesButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.NearByButton.translatesAutoresizingMaskIntoConstraints = NO;

    // Fix Background.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"V:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"H:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    // Fix Buttons Horizontal.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[SearchButton]-[CategoryButton(==SearchButton)]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[TopGamesButton]-[NearByButton(==TopGamesButton)]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    // Make Buttons Square.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.SearchButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.SearchButton
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.CategoryButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.CategoryButton
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];
    
    // Fix Top Images Position Vertically.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.SearchButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:10.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.CategoryButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:10.0]];
    
    // Fix other Buttons.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[SearchButton]-[TopGamesButton(==SearchButton)]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[CategoryButton]-[NearByButton(==CategoryButton)]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}

- (IBAction)SearchButtonAction:(UIButton *)sender {
    DLog(@"");
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice"
//                                                    message:@"Message:"
//                                                   delegate:self
//                                          cancelButtonTitle:@"OK1"
//                                          otherButtonTitles:@"OK2",nil];
//
//    [alert show];
}

- (IBAction)CategoryButtonAction:(UIButton *)sender {
    DLog(@"");
}

- (IBAction)TopGamesButtonAction:(UIButton *)sender {
    DLog(@"");
}

- (IBAction)NearByButtonAction:(UIButton *)sender {
    DLog(@"");
}

@end