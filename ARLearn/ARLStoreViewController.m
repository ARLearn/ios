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

@property (weak, nonatomic) IBOutlet ARLButton *SearchButton;
@property (weak, nonatomic) IBOutlet ARLButton *CategoryButton;
@property (weak, nonatomic) IBOutlet ARLButton *TopGamesButton;
@property (weak, nonatomic) IBOutlet ARLButton *NearByButton;
@property (weak, nonatomic) IBOutlet UILabel *featuredLabel;
@property (weak, nonatomic) IBOutlet UITableView *featuredable;

- (IBAction)SearchButtonAction:(ARLButton *)sender;
- (IBAction)CategoryButtonAction:(ARLButton *)sender;
- (IBAction)TopGamesButtonAction:(ARLButton *)sender;
- (IBAction)NearByButtonAction:(ARLButton *)sender;

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
    
    [self applyConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.SearchButton makeButtonWithImageAndGradient:@"Search"
                                            titleText:NSLocalizedString(@"SearchLabel", @"SearchLabel")
                                           titleColor:[UIColor whiteColor]
                                           startColor:UIColorFromRGB(0xff664c)
                                             endColor:UIColorFromRGB(0xe94a35)];
    
    [self.CategoryButton makeButtonWithImageAndGradient:@"Category"
                                              titleText:NSLocalizedString(@"CategoryLabel", @"CategoryLabel")
                                             titleColor:[UIColor whiteColor]
                                             startColor:UIColorFromRGB(0xff664c)
                                               endColor:UIColorFromRGB(0xe94a35)];
    
    [self.TopGamesButton makeButtonWithImageAndGradient:@"TopGames"
                                              titleText:NSLocalizedString(@"TopGamesLabel", @"TopGamesLabel")
                                             titleColor:[UIColor whiteColor]
                                             startColor:UIColorFromRGB(0xff664c)
                                               endColor:UIColorFromRGB(0xe94a35)];
    
    [self.NearByButton makeButtonWithImageAndGradient:@"NearBy"
                                            titleText:NSLocalizedString(@"NearByLabel", @"NearByLabel")
                                           titleColor:[UIColor whiteColor]
                                           startColor:UIColorFromRGB(0xff664c)
                                             endColor:UIColorFromRGB(0xe94a35)];
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
                                     self.view,             @"view",
                                     
                                     self.backgroundImage,  @"backgroundImage",
                                     
                                     self.SearchButton,     @"SearchButton",
                                     self.CategoryButton,   @"CategoryButton",
                                     self.TopGamesButton,   @"TopGamesButton",
                                     self.NearByButton,     @"NearByButton",
                                     
                                     nil];
    
    // See http://stackoverflow.com/questions/17772922/can-i-use-autolayout-to-provide-different-constraints-for-landscape-and-portrait
    // See https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/Bars.html
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.SearchButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.CategoryButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.TopGamesButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.NearByButton.translatesAutoresizingMaskIntoConstraints = NO;

    CGFloat sw = self.screenWidth;
    CGFloat bw = sw/2 - 3*8.0;
    
    // Fix Background.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    // Fix Buttons Horizontal.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-[SearchButton(==%f)]-[CategoryButton(==%f)]-|", bw, bw]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-[TopGamesButton(==%f)]-[NearByButton(==%f)]-|", bw, bw]
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

#pragma mark - Actions

- (IBAction)SearchButtonAction:(ARLButton *)sender {
    DLog(@"");
}

- (IBAction)CategoryButtonAction:(ARLButton *)sender {
    DLog(@"");
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice"
//                                                    message:@"Message:"
//                                                   delegate:self
//                                          cancelButtonTitle:@"OK1"
//                                          otherButtonTitles:@"OK2",nil];
//    
//    [alert show];
}

- (IBAction)TopGamesButtonAction:(ARLButton *)sender {
    DLog(@"");
}

- (IBAction)NearByButtonAction:(ARLButton *)sender {
    DLog(@"");
}

@end
