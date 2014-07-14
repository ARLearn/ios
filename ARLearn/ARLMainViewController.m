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
@property (weak, nonatomic) IBOutlet UIImageView *MyGamesImage;
@property (weak, nonatomic) IBOutlet UIImageView *StoreImage;
@property (weak, nonatomic) IBOutlet UIImageView *NearByImage;
@property (weak, nonatomic) IBOutlet UIImageView *QrScanImage;
@property (weak, nonatomic) IBOutlet UILabel *MyGamesLabel;
@property (weak, nonatomic) IBOutlet UILabel *StoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *QrScanLabel;
@property (weak, nonatomic) IBOutlet UILabel *NearByLabel;

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
    
    self.MyGamesLabel.text = NSLocalizedString(@"MyGames", @"MyGames");
    self.StoreLabel.text = NSLocalizedString(@"Store", @"Store");
    self.QrScanLabel.text = NSLocalizedString(@"ScanQrCode", @"ScanQrCode");
    self.NearByLabel.text = NSLocalizedString(@"NearBy", @"NearBy");
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
                                     
                                     self.MyGamesImage,     @"MyGamesImage",
                                     self.StoreImage,       @"StoreImage",
                                     self.QrScanImage,      @"QrScanImage",
                                     self.NearByImage,      @"NearByImage",
                                     
                                     self.MyGamesLabel,     @"MyGamesLabel",
                                     self.StoreLabel,       @"StoreLabel",
                                     self.QrScanLabel,      @"QrScanLabel",
                                     self.NearByLabel,      @"NearByLabel",
                                     
                                     nil];
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;

    self.MyGamesImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.StoreImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.QrScanImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.NearByImage.translatesAutoresizingMaskIntoConstraints = NO;

    self.MyGamesLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.StoreLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.QrScanLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.NearByLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Fix Background.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"V:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"H:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    // Fix Images Horizontal.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[MyGamesImage]-[StoreImage(==MyGamesImage)]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[QrScanImage]-[NearByImage(==QrScanImage)]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    // Make Images Square.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.MyGamesImage
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.MyGamesImage
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.StoreImage
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.StoreImage
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                           constant:0]];
    
    // Fix Top Images Position Vertically.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.MyGamesImage
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:10.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.StoreImage
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:10.0]];
    
    // Fix other images.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[MyGamesImage]-[QrScanImage(==MyGamesImage)]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[StoreImage]-[NearByImage(==StoreImage)]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    // Fix Labels Widths
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[MyGamesLabel(==MyGamesImage)]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[StoreLabel(==StoreImage)]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[QrScanLabel(==QrScanImage)]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[NearByLabel(==NearByImage)]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];

    // Fix Left Position of Labels
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.MyGamesLabel
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.MyGamesImage
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.StoreLabel
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.StoreImage
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.QrScanLabel
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.QrScanImage
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.NearByLabel
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.NearByImage
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // Fix Labels Position Vertically
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.MyGamesLabel
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.MyGamesImage
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-2.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.StoreLabel
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.StoreImage
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-2.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.QrScanLabel
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.QrScanImage
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-2.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.NearByLabel
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.NearByImage
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-2.0]];
}

@end
