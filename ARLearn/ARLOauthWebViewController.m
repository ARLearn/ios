//
//  ARLOauthWebViewController.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 11/11/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLOauthWebViewController.h"

@interface ARLOauthWebViewController ()

- (IBAction)backButtonAction:(UIBarButtonItem *)sender;

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (retain, nonatomic) NSURLConnection *connection;
@property (retain, nonatomic) NSMutableData *receivedData;
@property (retain, nonatomic) NSMutableURLRequest *originalRequest;
@property (retain, nonatomic) NSString *token;

@end

@implementation ARLOauthWebViewController

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
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonAction:)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //! Memory Leaks..
    [self.webView loadHTMLString: @"" baseURL: nil];

    [super viewDidDisappear:NO];
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

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *urlAsString =request.URL.description;
    
    Log(@"%@", urlAsString);
    
    if (!urlAsString)
    {
        return YES;
    }
    
    if ([urlAsString rangeOfString:@"twitter?denied="].location != NSNotFound) {
        [self close];
    } else if ([urlAsString rangeOfString:@"error=access_denied"].location != NSNotFound) {
        [self close];
    } else if ([urlAsString rangeOfString:@"oauth.html?accessToken="].location != NSNotFound) {
        @autoreleasepool {
            NSArray *listItems = [urlAsString componentsSeparatedByString:@"accessToken="];
            NSString *lastObject =[listItems lastObject];
            
            listItems = [lastObject componentsSeparatedByString:@"&"];
            
            // Log("Creating new Account");
            
            //! Store acessToken !
            [[NSUserDefaults standardUserDefaults] setObject:[listItems objectAtIndex:0] forKey:@"auth"];
            
            //ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSDictionary *accountDetails = ARLNetworking.accountDetails;
            
            DLog(@"%@", accountDetails);
            
            // http://stackoverflow.com/questions/19251246/how-do-i-use-magical-record-to-create-update-objects-and-save-them-without-usi

            // Skipped Entries:
            // {
            // allowTrackLocation = 0;
            // type = "org.celstec.arlearn2.beans.account.Account";
            // }
            
            Account *account=  [Account MR_createEntity];
            account.accountLevel = [accountDetails objectForKey:@"accountLevel"];
            account.accountType = [accountDetails objectForKey:@"accountType"];
            account.email = [accountDetails objectForKey:@"email"];
            account.familyName = [accountDetails objectForKey:@"familyName"];
            account.givenName = [accountDetails objectForKey:@"givenName"];
            account.localId = [accountDetails objectForKey:@"localId"];
            account.name = [accountDetails objectForKey:@"name"];
            // account.picture = [accountDetails objectForKey:@"picture"];
            
            [[NSManagedObjectContext MR_context] MR_saveToPersistentStoreAndWait];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            //[Account accountWithDictionary:accountDetails inManagedObjectContext:appDelegate.managedObjectContext];
            
            [[NSUserDefaults standardUserDefaults] setObject:[accountDetails objectForKey:@"localId"] forKey:@"accountLocalId"];
            [[NSUserDefaults standardUserDefaults] setObject:[accountDetails objectForKey:@"accountType"] forKey:@"accountType"];
            
            DLog(@"accountLocalId: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"]);
            DLog(@"accountType: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"]);
        }
        
        [self close];
    }
    
    return YES;
}

#pragma mark Methods

-(void) close {
    if (self.NavigationAfterClose) {
        [self.navigationController presentViewController:self.NavigationAfterClose animated:NO completion:nil];
        
        self.NavigationAfterClose = nil;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)loadAuthenticateUrl:(NSString *)authenticateUrl name:(NSString *) name delegate:(id) aDelegate {
    [self deleteARLearnCookie];
    
    self.domain = [[NSURL URLWithString:authenticateUrl] host];
    
    @autoreleasepool {
        // [self.webView loadHTMLString:[NSString stringWithFormat:@"<h1>Connecting to %@.</h1>", name] baseURL:nil];
        //
        [CATransaction flush];
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:authenticateUrl]]];
        // cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0]];
    }
}

- (void) deleteARLearnCookie {
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieJar cookies]) {
        if ([[cookie name] isEqualToString:@"arlearn.AccessToken"]) {
            [cookieJar deleteCookie:cookie];
        }
    }
}

#pragma mark Actions

- (IBAction)backButtonAction:(UIBarButtonItem *)sender {
    if (self.NavigationAfterClose) {
        [self.navigationController presentViewController:self.NavigationAfterClose animated:NO completion:nil];
        
        self.NavigationAfterClose = nil;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
