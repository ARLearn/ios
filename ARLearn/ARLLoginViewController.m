//
//  ARLLoginViewController.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 11/11/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLLoginViewController.h"

@interface ARLLoginViewController ()

- (IBAction)ecoButtonAction:(UIButton *)sender;
- (IBAction)facebookButtonAction:(UIButton *)sender;
- (IBAction)googleButtonAction:(UIButton *)sender;
- (IBAction)linkinButtonAction:(UIButton *)sender;
- (IBAction)twitterButtonAction:(UIButton *)sender;

- (IBAction)backButtonAction:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIButton *ecoButton;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *googleButton;
@property (weak, nonatomic) IBOutlet UIButton *linkedinButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

@end

@implementation ARLLoginViewController

#pragma mark - ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    // Hide buttons until we're sure we need to use them.
    [self.ecoButton setHidden:YES];
    [self.orLabel setHidden:YES];
    [self.googleButton setHidden:YES];
    [self.facebookButton setHidden:YES];
    [self.linkedinButton setHidden:YES];
    [self.twitterButton setHidden:YES];
    
//    if (ARLNetworking.isLoggedIn) {
//        UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthenticatedNavigation"];
//        
//        if (newViewController) {
//            // Move to another UINavigationController or UITabBarController etc.
//            // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
//            
//#warning loggged in part via another navigationcontroller.
//            // Beware we cnnot have a chain of two animated view transitions.
//            
//            [self.navigationController presentViewController:newViewController animated:YES completion:nil];
//            
//            DLog(@"LOGGED IN, JUMPING TO MYGAMES");
//            
//            newViewController = nil;
//        }
//        
//        return;
//    }
    
#warning TODO Reset Tables when not logged in.
    
    //! Clear Account bound data in tables, if any left.
    // ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    // [ARLAccountDelegator resetAccount:appDelegate.managedObjectContext];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
    
    [self addConstraints];
    
    if (ARLNetworking.isLoggedIn) {
        UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthenticatedNavigation"];
        
        if (newViewController) {
            // Move to another UINavigationController or UITabBarController etc.
            // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
            
#warning logged in part via another navigationcontroller.
            // Beware we cnnot have a chain of two animated view transitions.
            
            [self.navigationController presentViewController:newViewController animated:YES completion:nil];
            
            DLog(@"LOGGED IN, JUMPING TO MYGAMES");
            
            newViewController = nil;
        }
        
        return;
    }
    
    // Show buttons now we're sure we need to use them.
    [self.ecoButton setHidden:NO];
    [self.orLabel setHidden:NO];
    [self.googleButton setHidden:NO];
    [self.facebookButton setHidden:NO];
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

#pragma mark NSURLConnectionDataDelegate

///*!
// *  If data is successfully received, this method will be called by connection.
// *
// *  @param connection <#connection description#>
// */
//-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    if ([self.token length]!=0) {
//        //Copied from ARLOauthWebViewController.m
//        [[NSUserDefaults standardUserDefaults] setObject:self.token forKey:@"auth"];
//        
//        ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
//        NSDictionary *accountDetails = [ARLNetworking accountDetails];
//        
//        [Account accountWithDictionary:accountDetails inManagedObjectContext:appDelegate.managedObjectContext];
//        [[NSUserDefaults standardUserDefaults] setObject:[accountDetails objectForKey:@"localId"] forKey:@"accountLocalId"];
//        [[NSUserDefaults standardUserDefaults] setObject:[accountDetails objectForKey:@"accountType"] forKey:@"accountType"];
//        
//        // veg 26-06-2014 disabled because notification api is disabled.
//        //        NSString *fullId = [NSString stringWithFormat:@"%@:%@",  [accountDetails objectForKey:@"accountType"], [accountDetails objectForKey:@"localId"]];
//        //        [[ARLNotificationSubscriber sharedSingleton] registerAccount:fullId];
//        
//        [self navigateBack];
//    }
//}

#pragma mark Methods

- (void) addConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.backgroundImage,  @"background",
                                     self.ecoButton,        @"ecoButton",
                                     self.orLabel,          @"orLabel",
                                     self.facebookButton,   @"facebookButton",
                                     self.googleButton,     @"googleButton",
                                     self.linkedinButton,   @"linkedinButton",
                                     self.twitterButton,    @"twitterButton",
                                     nil];
    
    // Fails
    // for (UIView *view in [viewsDictionary keyEnumerator]) {
    //   view.translatesAutoresizingMaskIntoConstraints = NO;
    // }
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.ecoButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.orLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.facebookButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.googleButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.linkedinButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.twitterButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Order vertically
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: @"V:[ecoButton]-[orLabel]-[facebookButton]-[googleButton]-[linkedinButton]-[twitterButton]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    // Align around vertical center.
    // see http://stackoverflow.com/questions/20020592/centering-view-with-visual-format-nslayoutconstraints?rq=1
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.ecoButton
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.orLabel
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.facebookButton
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.googleButton
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.linkedinButton
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.twitterButton
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    
    // Fix Widths
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[ecoButton(==300)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[facebookButton(==300)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[googleButton(==300)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[linkedinButton(==300)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[twitterButton(==300)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    // Background
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: @"V:|[background]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: @"H:|[background]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
}

/*!
 *  Handle the Back Button.
 */
- (void)navigateBack {
    if (ARLNetworking.isLoggedIn) {
        UIViewController *mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"RootNavigationController"];
        
        if (ARLNetworking.isLoggedIn) {
            //            UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
            //            if ([appDelegate respondsToSelector:@selector(syncData)]) {
            //                [appDelegate performSelector:@selector(syncData)];
            //            }
        }
        
        [self.navigationController presentViewController:mvc animated:YES completion:nil];
        
    } else {
        [self.navigationController presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"] animated:YES  completion:nil];
    }
}

/*!
 *  Perform the actual Login.
 *
 *  @param serviceId <#serviceId description#>
 */
- (void)performLogin:(NSInteger)serviceId {
    [ARLNetworking setupOauthInfo];
    
    ARLOauthWebViewController* oauthService = [self.storyboard instantiateViewControllerWithIdentifier:@"oauthWebView"];
    
    oauthService.NavigationAfterClose = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
    
    [self.navigationController pushViewController:oauthService animated:YES];
    
    switch (serviceId) {
        case FACEBOOK:
            [oauthService loadAuthenticateUrl:ARLNetworking.facebookLoginString name:@"Facebook" delegate:oauthService];
            break;
        case GOOGLE:
            [oauthService loadAuthenticateUrl:ARLNetworking.googleLoginString name:@"Google" delegate:oauthService];
            break;
        case LINKEDIN:
            [oauthService loadAuthenticateUrl:ARLNetworking.linkedInLoginString name:@"Linked-in" delegate:oauthService];
            break;
        case TWITTER:
            [oauthService loadAuthenticateUrl:ARLNetworking.twitterLoginString name:@"Twitter" delegate:oauthService];
            break;
        case ECO:
            [oauthService loadAuthenticateUrl:ARLNetworking.ecoLoginString name:@"Eco" delegate:oauthService];
            break;
    }
}

#pragma mark Actions

/*!
 *  ECO Login.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)ecoButtonAction:(UIButton *)sender {
   [self performLogin:ECO];
}

/*!
 *  FaceBook Login.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)facebookButtonAction:(UIButton *)sender {
    [self performLogin:FACEBOOK];
}

/*!
 *  Google Login.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)googleButtonAction:(UIButton *)sender {
    [self performLogin:GOOGLE];
}

- (IBAction)linkinButtonAction:(UIButton *)sender {
    [self performLogin:LINKEDIN];
}

- (IBAction)twitterButtonAction:(UIButton *)sender {
    [self performLogin:TWITTER];
}

- (IBAction)backButtonAction:(UIBarButtonItem *)sender {
    // Note: this is the countepart of presentViewController!
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

@end
