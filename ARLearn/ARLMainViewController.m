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

@end

@implementation ARLMainViewController

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

- (void) applyConstraints {
    
}

@end
