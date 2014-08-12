//
//  ARLGameViewController.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/28/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLGameViewController.h"

@interface ARLGameViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIView *barOne;
@property (weak, nonatomic) IBOutlet UIPageControl *ratingControl;
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
@property (weak, nonatomic) IBOutlet UITextView *summaryText;
@property (weak, nonatomic) IBOutlet UIView *barTwo;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseLabel;

@end

@implementation ARLGameViewController

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //
}


-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //
}

#pragma mark - Properties

#pragma mark - Methods

- (void) applyConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,             @"view",
                                     
                                     self.backgroundImage,  @"backgroundImage",
                                     
                                     self.iconImage,        @"iconImage",
                                     self.titleLabel,       @"titleLabel",
                                     self.categoryLabel,    @"categoryLabel",
                                     self.downloadButton,   @"downloadButton",
                                     self.barOne,           @"barOne",
                                     self.ratingControl,    @"ratingControl",
                                     self.languageLabel,    @"languageLabel",
                                     self.summaryText,      @"summaryText",
                                     self.barTwo,           @"barTwo",
                                     self.versionLabel,     @"versionLabel",
                                     self.releaseLabel,     @"releaseLabel",
                                     
                                     nil];
    

    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconImage.translatesAutoresizingMaskIntoConstraints =NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.categoryLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.downloadButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.barOne.translatesAutoresizingMaskIntoConstraints = NO;
    self.ratingControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.languageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.summaryText.translatesAutoresizingMaskIntoConstraints = NO;
    self.barTwo.translatesAutoresizingMaskIntoConstraints = NO;
    self.versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.releaseLabel.translatesAutoresizingMaskIntoConstraints = NO;

    // CGFloat sw = self.screenWidth;
    // CGFloat bw = sw/2 - 3*8.0;
    
    // Fix Background.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    // Fix bars + summary Horizontally
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[barOne]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[summaryText]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[barTwo]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    // Fix Image, Labels and Button horizontally
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[iconImage(100)]-[titleLabel]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[iconImage]-[categoryLabel]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[iconImage]-[downloadButton]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    // FFix Image, Labels and Button vertically
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[iconImage(100)]-[barOne(36)]-[summaryText]-[barTwo(58)]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[downloadButton]-[barOne(36)]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[titleLabel]-[categoryLabel]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
}

@end
