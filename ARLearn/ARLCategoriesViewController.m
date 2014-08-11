//
//  ARLCategoriesViewController.m
//  ARLearn
//
//  Created by Wim van der Vegt on 8/7/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLCategoriesViewController.h"

@interface ARLCategoriesViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (weak, nonatomic) IBOutlet ARLButton *Category1Button;
@property (weak, nonatomic) IBOutlet ARLButton *Category2Button;
@property (weak, nonatomic) IBOutlet ARLButton *Category3Button;
@property (weak, nonatomic) IBOutlet ARLButton *Category4Button;

- (IBAction)SearchButtonAction:(ARLButton *)sender;
- (IBAction)CategoryButtonAction:(ARLButton *)sender;
- (IBAction)TopGamesButtonAction:(ARLButton *)sender;
- (IBAction)NearByButtonAction:(ARLButton *)sender;

@end

@implementation ARLCategoriesViewController

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
    
    [self.Category1Button makeButtonWithImageAndGradient:@"Culture"
                                            titleText:NSLocalizedString(@"CultureCategoryLabel", @"CultureCategoryLabel")
                                           titleColor:[UIColor whiteColor]
                                           startColor:UIColorFromRGB(0xff664c)
                                             endColor:UIColorFromRGB(0xe94a35)];
    
    [self.Category2Button makeButtonWithImageAndGradient:@"Category"
                                              titleText:NSLocalizedString(@"CategoryLabel", @"CategoryLabel")
                                             titleColor:[UIColor whiteColor]
                                             startColor:UIColorFromRGB(0xff664c)
                                               endColor:UIColorFromRGB(0xe94a35)];
    
    [self.Category3Button makeButtonWithImageAndGradient:@"Category"
                                              titleText:NSLocalizedString(@"CategoryLabel", @"TopGamesLabel")
                                             titleColor:[UIColor whiteColor]
                                             startColor:UIColorFromRGB(0xff664c)
                                               endColor:UIColorFromRGB(0xe94a35)];
    
    [self.Category4Button makeButtonWithImageAndGradient:@"Category"
                                            titleText:NSLocalizedString(@"CategoryLabel", @"CategoryLabel")
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
                                     
                                     self.Category1Button,  @"Category1Button",
                                     self.Category2Button,  @"Category2Button",
                                     self.Category3Button,  @"Category3Button",
                                     self.Category4Button,  @"Category4Button",
                                     
                                     nil];
    
    // See http://stackoverflow.com/questions/17772922/can-i-use-autolayout-to-provide-different-constraints-for-landscape-and-portrait
    // See https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/Bars.html
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.Category1Button.translatesAutoresizingMaskIntoConstraints = NO;
    self.Category2Button.translatesAutoresizingMaskIntoConstraints = NO;
    self.Category3Button.translatesAutoresizingMaskIntoConstraints = NO;
    self.Category4Button.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-[Category1Button(==%f)]-[Category2Button(==%f)]-|", bw, bw]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-[Category3Button(==%f)]-[Category4Button(==%f)]-|", bw, bw]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    // Make Buttons Square.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.Category1Button
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.Category1Button
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.Category2Button
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.Category2Button
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];
    
    // Fix Top Images Position Vertically.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.Category1Button
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:10.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.Category2Button
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:10.0]];
    
    // Fix other Buttons.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[Category1Button]-[Category3Button(==Category1Button)]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[Category2Button]-[Category4Button(==Category2Button)]"
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
