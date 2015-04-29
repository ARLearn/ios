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
@property (weak, nonatomic) IBOutlet UIWebView *summaryText;
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
@property (weak, nonatomic) IBOutlet UIView *barTwo;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseLabel;

- (IBAction)downloadButtonAction:(UIButton *)sender;

@property (retain, nonatomic) NSDictionary *game;
@property (strong, nonatomic) NSNumber *runId;

@property (retain, nonatomic) NSMutableData *accumulatedData;
@property (nonatomic) long long accumulatedSize;

@end

@implementation ARLGameViewController

@synthesize game;
@synthesize runId = _runId;

Class _class;

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
    
    DLog(@"GameID = %@", self.gameId);
 
    [self.downloadButton setEnabled:NO];

    [self applyConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem.title = @"BACK";

    self.navigationController.navigationBarHidden=NO;
    self.navigationController.toolbarHidden=NO;
    
    [self performQuery1];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    // NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    
    self.accumulatedSize = [response expectedContentLength];
    self.accumulatedData = [[NSMutableData alloc]init];
    
    // NSLog(@"Got HTTP Response [%d], expect %lld byte(s)", [httpResponse statusCode], self.accumulatedSize);
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    // NSLog(@"Got HTTP Data, %d of %lld byte(s)", [data length], self.accumulatedSize);
    
    // [ARLUtils LogJsonData:data url:[[[dataTask response] URL] absoluteString]];
    
    [self.accumulatedData appendData:data];
    
    if ([self.accumulatedData length]==self.accumulatedSize) {
        //    [ARLQueryCache addQuery:dataTask.taskDescription withResponse:data];
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    // NSLog(@"Completed HTTP Task");
    
    if (error == nil)
    {
        [self processData:self.accumulatedData];
        
        [ARLQueryCache addQuery:task.taskDescription withResponse:self.accumulatedData];
        
        // Update UI Here?
        // NSLog(@"Download is Succesfull");
    } else {
        NSLog(@"Error %@",[error userInfo]);
    }
    
    // Invalidate Session
    [session finishTasksAndInvalidate];
}

#pragma mark - Properties

- (void)setRunId:(NSNumber *)runId {
    _runId = runId;
    
    [self.downloadButton setEnabled:YES];
}

- (NSNumber *)runId {
    return _runId;
}

- (void) setBackViewControllerClass:(Class)viewControllerClass{
    _class = viewControllerClass;
}

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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[iconImage(100)]-[barOne(36)]-[summaryText]-[barTwo(36)]-(8)-|"
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
    
    // Position control on barOne.
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        [self.barOne addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[ratingControl]-|"
                                                                            options:NSLayoutFormatDirectionLeadingToTrailing
                                                                            metrics:nil
                                                                              views:viewsDictionary]];
        
        [self.barOne addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[languageLabel]-|"
                                                                            options:NSLayoutFormatDirectionLeadingToTrailing
                                                                            metrics:nil
                                                                              views:viewsDictionary]];
        
        [self.barOne addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(16)-[ratingControl]"
                                                                            options:NSLayoutFormatDirectionLeadingToTrailing
                                                                            metrics:nil
                                                                              views:viewsDictionary]];
    }
    
    [self.barOne addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[languageLabel]-(16)-|"
                                                                        options:NSLayoutFormatDirectionLeadingToTrailing
                                                                        metrics:nil
                                                                          views:viewsDictionary]];
    
    // Position control on barTwo.
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        [self.barTwo addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[versionLabel]-|"
                                                                            options:NSLayoutFormatDirectionLeadingToTrailing
                                                                            metrics:nil
                                                                              views:viewsDictionary]];
        
        [self.barTwo addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[releaseLabel]-|"
                                                                            options:NSLayoutFormatDirectionLeadingToTrailing
                                                                            metrics:nil
                                                                              views:viewsDictionary]];
        
        [self.barTwo addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(16)-[versionLabel]"
                                                                            options:NSLayoutFormatDirectionLeadingToTrailing
                                                                            metrics:nil
                                                                              views:viewsDictionary]];
    }
    
    [self.barTwo addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[releaseLabel]-(16)-|"
                                                                        options:NSLayoutFormatDirectionLeadingToTrailing
                                                                        metrics:nil
                                                                          views:viewsDictionary]];
    
   //UIConstraintBasedLayoutDebugging
}

- (void)processData:(NSData *)data
{
    //Example Data:
    
    //{
    //    "type": "org.celstec.arlearn2.beans.game.Game",
    //    "gameId": 10206097,
    //    "deleted": false,
    //    "lastModificationDate": 1383575222233,
    //    "title": "Connect college inquiry",
    //    "sharing": 1,
    //    "config": {
    //        "type": "org.celstec.arlearn2.beans.game.Config",
    //        "mapAvailable": false,
    //        "manualItems": [],
    //        "locationUpdates": []
    //    },
    //    "language": "en"
    //}
    
    //1422489600    (unix)
    //1422536899756 (arlearn)
    
    NSError *error = nil;
    NSDictionary *json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    ELog(error);
    
    BeanIds bid = [ARLBeanNames beanTypeToBeanId:[json valueForKey:@"type"]];
    
    switch (bid) {
        case RunList: {
            for (NSDictionary *run in [json valueForKey:@"runs"]) {
                if ([[run valueForKey:@"gameId"] longLongValue] == [self.gameId longLongValue]) {
                    self.runId = [run valueForKey:@"runId"];
                    DLog(@"runID = %@", self.runId);
                    break;
                }
            }
            
            if (!self.runId) {
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                                      message:NSLocalizedString(@"No Run found", @"No Run found")
                                                                     delegate:nil
                                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                            otherButtonTitles:nil, nil];
                [myAlertView show];

            }
        }
            break;
            
        case GameBean: {
            //     "type": ,
            //
            //    "type": "org.celstec.arlearn2.beans.game.Game",
            
            self.game = json;
            
            self.titleLabel.text = [self.game objectForKey:@"title"];
            self.languageLabel.text = [self.game objectForKey:@"language"];
            [self.summaryText loadHTMLString:[self.game objectForKey:@"description"] baseURL:nil];
            self.releaseLabel.text = [NSString stringWithFormat:@"Release datum %@", [ARLUtils formatDate:[self.game objectForKey:@"lastModificationDate"]]];
            
            Log(@"Title of the Game shown is : '%@'",[self.game objectForKey:@"title"]);
            
            Run *run = [Run MR_findFirstByAttribute:@"gameId"
                                          withValue:[json valueForKey:@"gameId"]];
            
            if (run) {
                self.runId = run.runId;
            }else {
                [self performQuery2];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)performQuery1 {
    NSString *query = [NSString stringWithFormat:@"myGames/gameId/%@", [NSNumber numberWithLongLong:[self.gameId longLongValue]]];
    
    NSString *cacheIdentifier = [ARLNetworking generateGetDescription:query];
    
    NSData *response = [[ARLAppDelegate theQueryCache] getResponse:cacheIdentifier];
    
    if (!response) {
        [ARLNetworking sendHTTPGetWithDelegate:self withService:query];
    } else {
        NSLog(@"Using cached query data");
        [self processData:response];
    }
}

- (void)performQuery2 {
    NSString *query = @"myRuns/participate";
    
    NSString *cacheIdentifier = [ARLNetworking generateGetDescription:query];
    
    NSData *response = [[ARLAppDelegate theQueryCache] getResponse:cacheIdentifier];
    
    if (!response) {
        [ARLNetworking sendHTTPGetWithDelegate:self withService:query];
    } else {
        NSLog(@"Using cached query data");
        [self processData:response];
    }
}

#pragma mark - Actions

- (IBAction)downloadButtonAction:(UIButton *)sender {
    
    if (self.runId) {
        ARLDownloadViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DownloadView"];
        
        if (newViewController) {
            // if ([newViewController respondsToSelector:@selector(setGameId:)]) {
            //      [newViewController performSelector:@selector(setGameId:) withObject:self.gameId];
            // }
            
            newViewController.gameId = self.gameId;
            newViewController.runId = self.runId;
            [newViewController setBackViewControllerClass:_class];
            
            // Move to another UINavigationController or UITabBarController etc.
            // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
            [self.navigationController pushViewController:newViewController animated:YES];
            
            newViewController = nil;
        }
    }
}

@end
