//
//  ARLMainViewController.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/14/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLMainViewController.h"

@interface ARLMainViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (weak, nonatomic) IBOutlet ARLButton *MyGamesButton;
@property (weak, nonatomic) IBOutlet ARLButton *StoreButton;
@property (weak, nonatomic) IBOutlet ARLButton *QrScanButton;
@property (weak, nonatomic) IBOutlet ARLButton *NearByButton;

- (IBAction)MyGamesButtonAction:(ARLButton *)sender;
- (IBAction)StoreButtonAction:(ARLButton *)sender;
- (IBAction)QrScanButtonAction:(ARLButton *)sender;
- (IBAction)NearByButtonAction:(ARLButton *)sender;

@end

@implementation ARLMainViewController

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.MyGamesButton makeButtonWithImageAndGradient:@"MyGames"
                                             titleText:NSLocalizedString(@"MyGames", @"MyGames")
                                            titleColor:[UIColor whiteColor]
                                            startColor:UIColorFromRGB(0x419cd7)
                                              endColor:UIColorFromRGB(0x217eba)];
    
    [self.StoreButton makeButtonWithImageAndGradient:@"Store"
                                           titleText:NSLocalizedString(@"Store", @"Store")
                                          titleColor:[UIColor whiteColor]
                                          startColor:UIColorFromRGB(0xff664c)
                                            endColor:UIColorFromRGB(0xe94a35)];
    
    [self.QrScanButton makeButtonWithImageAndGradient:@"QrScan"
                                            titleText:NSLocalizedString(@"ScanQrCode", @"ScanQrCode")
                                           titleColor:[UIColor whiteColor]
                                           startColor:UIColorFromRGB(0x3fd8b7)
                                             endColor:UIColorFromRGB(0x00bc9c)];
    
    [self.NearByButton makeButtonWithImageAndGradient:@"NearBy"
                                            titleText:NSLocalizedString(@"NearBy", @"NearBy")
                                           titleColor:[UIColor whiteColor]
                                           startColor:UIColorFromRGB(0x4c6078)
                                             endColor:UIColorFromRGB(0x33485f)];
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
                                     
                                     self.MyGamesButton,     @"MyGamesButton",
                                     self.StoreButton,       @"StoreButton",
                                     self.QrScanButton,      @"QrScanButton",
                                     self.NearByButton,      @"NearByButton",
                       
                                     nil];
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;

    self.MyGamesButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.StoreButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.QrScanButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.NearByButton.translatesAutoresizingMaskIntoConstraints = NO;

#warning Handle landscape too.
    
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
    
    // Fix Images Horizontal.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-[MyGamesButton(==%f)]-[StoreButton(==%f)]-|", bw, bw]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-[QrScanButton(==%f)]-[NearByButton(==%f)]-|", bw, bw]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    // Make Images Square.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.MyGamesButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.MyGamesButton
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.StoreButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.StoreButton
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];
    
    // Fix Top Images Position Vertically.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.MyGamesButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:10.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.StoreButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:10.0]];
    
    // Fix other images.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[MyGamesButton]-[QrScanButton(==MyGamesButton)]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[StoreButton]-[NearByButton(==StoreButton)]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}

- (IBAction)MyGamesButtonAction:(ARLButton *)sender {
    DLog(@"");
    
    UIViewController *mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
    
    [self.navigationController presentViewController:mvc animated:YES completion:nil];
}

- (IBAction)StoreButtonAction:(ARLButton *)sender {
    DLog(@"");
//    
//    UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StoreView"];
//    
//    if (newViewController) {
//        // Move to another UINavigationController or UITabBarController etc.
//        // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
//        [self.navigationController pushViewController:newViewController animated:YES];
//    }
}

- (IBAction)QrScanButtonAction:(ARLButton *)sender {
    DLog(@"");
}

- (IBAction)NearByButtonAction:(ARLButton *)sender {
    DLog(@"");
}

@end
