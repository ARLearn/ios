//
//  ARLDownloadViewController.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 05/12/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLDownloadViewController.h"

@interface ARLDownloadViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIProgressView *phaseBar;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *phaseLabel;

- (IBAction)playButtonAction:(UIBarButtonItem *)sender;

@property (strong, nonatomic) NSArray *gameFiles;
@property (strong, nonatomic) NSDictionary *downloadStatus;

@end

@implementation ARLDownloadViewController

@synthesize gameId;
@synthesize runId;

NSInteger downloaded = 0;
NSInteger phases = 9;

Class _class;

#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.downloadStatus = [[NSDictionary alloc] init];

    [self applyConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];
    
    self.navigationItem.title = @"Download";
    
    self.progressView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncProgress:)
                                                 name:ARL_SYNCPROGRESS
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncReady:)
                                                 name:ARL_SYNCREADY
                                               object:nil];
    
    [self.playButton setEnabled:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    downloaded = 0;
    
    // Debug code to force re-valuation.
    // [Action MR_truncateAll];
    
    NSBlockOperation *backBO0 =[NSBlockOperation blockOperationWithBlock:^{
        [self DownloadGame];
        
        [self performSelectorOnMainThread:@selector(updatePhase:)
                               withObject:[NSNumber numberWithInt:1]
                            waitUntilDone:YES];
    }];
    
    NSBlockOperation *backBO1 =[NSBlockOperation blockOperationWithBlock:^{
        [self DownloadGameContent];
        
        [self performSelectorOnMainThread:@selector(updatePhase:)
                               withObject:[NSNumber numberWithInt:2]
                            waitUntilDone:YES];
    }];
    
    NSBlockOperation *backBO2 =[NSBlockOperation blockOperationWithBlock:^{
        [self DownloadSplashScreen];
        
        [self performSelectorOnMainThread:@selector(updatePhase:)
                               withObject:[NSNumber numberWithInt:3]
                            waitUntilDone:YES];
    }];
    
    NSBlockOperation *backBO3 =[NSBlockOperation blockOperationWithBlock:^{
        [self DownloadGameFiles];
        
        [self performSelectorOnMainThread:@selector(updatePhase:)
                               withObject:[NSNumber numberWithInt:4]
                            waitUntilDone:YES];
    }];
    
    NSBlockOperation *backBO4 =[NSBlockOperation blockOperationWithBlock:^{
        [ARLSynchronisation DownloadGeneralItems:self.gameId];
        
        [self performSelectorOnMainThread:@selector(updatePhase:)
                               withObject:[NSNumber numberWithInt:5]
                            waitUntilDone:YES];
   }];
    
    // BEWARE Due to synchronized, first publish then download.
    NSBlockOperation *backBO5 =[NSBlockOperation blockOperationWithBlock:^{
        [ARLSynchronisation PublishActionsToServer];
        
        [self performSelectorOnMainThread:@selector(updatePhase:)
                               withObject:[NSNumber numberWithInt:6]
                            waitUntilDone:YES];
    }];

    NSBlockOperation *backBO6 =[NSBlockOperation blockOperationWithBlock:^{
        [ARLSynchronisation DownloadActions:self.runId];
        
        [self performSelectorOnMainThread:@selector(updatePhase:)
                               withObject:[NSNumber numberWithInt:7]
                            waitUntilDone:YES];
    }];
    
    // BEWARE Due to synchronized, first publish then download.
    NSBlockOperation *backBO7 =[NSBlockOperation blockOperationWithBlock:^{
        [ARLSynchronisation PublishResponsesToServer];
        
        [self performSelectorOnMainThread:@selector(updatePhase:)
                               withObject:[NSNumber numberWithInt:8]
                            waitUntilDone:YES];
    }];

    NSBlockOperation *backBO8 =[NSBlockOperation blockOperationWithBlock:^{
        [ARLSynchronisation DownloadResponses:self.runId];
        
        [self performSelectorOnMainThread:@selector(updatePhase:)
                               withObject:[NSNumber numberWithInt:9]
                            waitUntilDone:YES];
    }];
    
    NSBlockOperation *foreBO =[NSBlockOperation blockOperationWithBlock:^{
        [NSTimer scheduledTimerWithTimeInterval:(downloaded==0 ? 0.1 : 0.5)
                                         target:self
                                       selector:@selector(splashDone:)
                                       userInfo:nil
                                        repeats:NO];
    }];
    
    // Add dependencies: backBO0 -> backBO1 -> backBO2 -> backBO3 -> back04 -> back05 -> back06 -> back07 -> back08 -> foreBO.
    [backBO1 addDependency:backBO0];
    [backBO2 addDependency:backBO1];
    [backBO3 addDependency:backBO2];
    [backBO4 addDependency:backBO3];
    [backBO5 addDependency:backBO4];
    [backBO6 addDependency:backBO5];
    [backBO7 addDependency:backBO6];
    [backBO8 addDependency:backBO7];
   
    [foreBO  addDependency:backBO8];
    
    [[NSOperationQueue mainQueue] addOperation:foreBO];
    
    [[ARLAppDelegate theOQ] addOperation:backBO8];
    [[ARLAppDelegate theOQ] addOperation:backBO7];
    [[ARLAppDelegate theOQ] addOperation:backBO6];
    [[ARLAppDelegate theOQ] addOperation:backBO5];
    [[ARLAppDelegate theOQ] addOperation:backBO4];
    [[ARLAppDelegate theOQ] addOperation:backBO3];
    [[ARLAppDelegate theOQ] addOperation:backBO2];
    [[ARLAppDelegate theOQ] addOperation:backBO1];
    [[ARLAppDelegate theOQ] addOperation:backBO0];
    
    // This Fails to update the UI (seems to hang).
    // [[NSOperationQueue mainQueue] waitUntilAllOperationsAreFinished];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ARL_SYNCPROGRESS object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ARL_SYNCREADY object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    self.title = @"X";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties

-(NSString *) cellIdentifier {
    return  @"DownloadItem";
}

- (void) setBackViewControllerClass:(Class)viewControllerClass{
    _class = viewControllerClass;
}

#pragma mark - Methods

- (void) applyConstraints {
    NSDictionary *viewsDictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,             @"view",
                                     
                                     self.backgroundImage,  @"backgroundImage",
                         
                                     self.progressView,     @"progressView",
                                     
                                     nil];
    
    // See http://stackoverflow.com/questions/17772922/can-i-use-autolayout-to-provide-different-constraints-for-landscape-and-portrait
    // See https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/Bars.html
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;

    self.downloadLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.phaseLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.phaseBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Fix Background.
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|[backgroundImage]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary1]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[backgroundImage]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary1]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[progressView]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary1]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[progressView]-(20)-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary1]];
    
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.progressView,     @"progressView",
                                    
                                     self.downloadLabel,    @"downloadLabel",
                                     self.progressLabel,    @"progressLabel",
                                     self.phaseLabel,       @"phaseLabel",
                                     
                                     self.progressBar,      @"progressBar",
                                     self.phaseBar,         @"phaseBar",
                                     
                                     nil];
    
    [self.progressView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"H:|-[downloadLabel]-|"
                                       options:NSLayoutFormatDirectionLeadingToTrailing
                                       metrics:nil
                                       views:viewsDictionary]];
    
    // Fix ProgressBar Horizontal.
    [self.progressView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"H:|-[progressLabel]-|"
                                       options:NSLayoutFormatDirectionLeadingToTrailing
                                       metrics:nil
                                       views:viewsDictionary]];
    [self.progressView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"H:|-[progressBar]-|"
                                       options:NSLayoutFormatDirectionLeadingToTrailing
                                       metrics:nil
                                       views:viewsDictionary]];
    
    // Fix phaseBar Horizontal.
    [self.progressView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"H:|-[phaseLabel]-|"
                                       options:NSLayoutFormatDirectionLeadingToTrailing
                                       metrics:nil
                                       views:viewsDictionary]];
    
    [self.progressView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"H:|-[phaseBar]-|"
                                       options:NSLayoutFormatDirectionLeadingToTrailing
                                       metrics:nil
                                       views:viewsDictionary]];
    // Fix ProgressBar and phaseBar Vertically.
    [self.progressView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"V:|-(4)-[downloadLabel]-[phaseLabel]-3-[phaseBar(4)]-[progressLabel]-3-[progressBar(4)]-(4)-|"
                                       options:NSLayoutFormatDirectionLeadingToTrailing
                                       metrics:nil
                                       views:viewsDictionary]];
    //self.navigationController.toolbar.frame.size.height + 4.0f
}

/*!
 *  Downloads teh Game we're participating in.
 *
 *  Runs in a background thread.
 */
-(void) DownloadGame {
    DLog(@"%@", @"DownloadGame");
    NSString *service = [NSString stringWithFormat:@"myGames/gameId/%@", self.gameId];
    NSData *data = [ARLNetworking sendHTTPGetWithAuthorization:service];
    
    NSError *error = nil;
    
    NSDictionary *game = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                      error:&error] : nil;
    ELog(error);
    
    //#pragma warn Debug Code
    // [ARLUtils LogJsonDictionary:game url:service];
    
    //    @property (nonatomic, retain) NSString * creator;
    //    @property (nonatomic, retain) NSNumber * gameId;                  mapped
    //    @property (nonatomic, retain) NSNumber * hasMap;
    //    @property (nonatomic, retain) NSString * owner;
    //    @property (nonatomic, retain) NSString * richTextDescription;
    //    @property (nonatomic, retain) NSString * title;                   mapped
    //    @property (nonatomic, retain) NSSet *correspondingRuns;
    //    @property (nonatomic, retain) NSSet *hasItems;
    
    NSDictionary *namefixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                // Json,                        CoreData
                                @"description",                 @"richTextDescription",
                                nil];
    
    NSDictionary *datafixups = [NSDictionary dictionary];
                                //[NSDictionary dictionaryWithObjectsAndKeys:
                                // Data,                        CoreData
                                //nil];
    
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gameId==%@", self.gameId];
    Game *item = [Game MR_findFirstWithPredicate: predicate inContext:ctx];
    
    if (item) {
        if (([game valueForKey:@"deleted"] && [[game valueForKey:@"deleted"] integerValue] != 0) ||
            ([game valueForKey:@"revoked"] && [[game valueForKey:@"revoked"] integerValue] != 0)) {
            DLog(@"Deleting Game: %@", [game valueForKey:@"title"])
            [item MR_deleteEntity];
        } else {
            DLog(@"Updating Game: %@", [game valueForKey:@"title"])
            item = (Game *)[ARLUtils UpdateManagedObjectFromDictionary:game
                                                         managedobject:item
                                                            nameFixups:namefixups
                                                            dataFixups:datafixups
                                                        managedContext:ctx];
        }
    } else {
        if (([game valueForKey:@"deleted"] && [[game valueForKey:@"deleted"] integerValue] != 0) ||
            ([game valueForKey:@"revoked"] && [[game valueForKey:@"revoked"] integerValue] != 0)) {
                // Skip creating deleted records.
                DLog(@"Skipping deleted Game: %@", [game valueForKey:@"title"])
            } else {
                // Uses MagicalRecord for Creation and Saving!
                DLog(@"Creating Game: %@", [game valueForKey:@"title"])
                item = (Game *)[ARLUtils ManagedObjectFromDictionary:game
                                                      entityName:[Game MR_entityName] //@"Game"
                                                      nameFixups:namefixups
                                                      dataFixups:datafixups
                                                  managedContext:ctx];
        }
    }
    
    // Saves any modification made after ManagedObjectFromDictionary.
    [ctx MR_saveToPersistentStoreAndWait];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    DLog(@"%@", @"DownloadGame Ready");
}

-(void) DownloadGameContent {
    DLog(@"%@", @"DownloadGameContent");

    NSString *query = [NSString stringWithFormat:@"myGames/gameContent/gameId/%@", [NSNumber numberWithLongLong:[self.gameId longLongValue]]];
    
    NSString *cacheIdentifier = [ARLNetworking generateGetDescription:query];
    
    NSData *response = [[ARLAppDelegate theQueryCache] getResponse:cacheIdentifier];
    
    if (!response) {
        response = [ARLNetworking sendHTTPGetWithAuthorization:query];
    }
    
    if (response && response.length != 0) {
        // [ARLUtils LogJsonData:response url:query];
        
        NSDictionary *gameContent = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        
        self.gameFiles = (NSArray *)[gameContent objectForKey:@"gameFiles"];
        
        // Init Status Dictionary.
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:self.downloadStatus];
        for (NSDictionary *gameFile in self.gameFiles) {
            NSString *path = [gameFile valueForKey:@"path"];
            
            //            {
            //                "type": "org.celstec.arlearn2.beans.game.GameFileList",
            //                "gameFiles": [
            //                              {
            //                                  "type": "org.celstec.arlearn2.beans.game.GameFile",
            //                                  "path": "/gameThumbnail",
            //                                  "id": 5340892630089728,
            //                                  "size": 25105,
            //                                  "md5Hash": "c73bfa4b390b54d72d0a237c0de104ae"
            //                              }
            //                              ]
            //            }
            
#warning SPECIAL FILE PATHS:
            //  /gameThumbnail
            //  /gameMessagesHeader
            //  /gameSplashScreen
            //  /background
            //  /map.zip
            //  /resultBackground
            Log(@"GameFile: %@", path);
            
            [dict setValue:[NSNumber numberWithBool:FALSE] forKey:path];
        }
        
        self.downloadStatus = dict;
    }

    DLog(@"%@", @"DownloadGameContent Ready");
}

/*!
 *  Downloads the splashscreen if present (and not already downloaded & unmodified).
 *
 *  Runs in a background thread.
 */
-(void) DownloadSplashScreen {
    DLog(@"%@", @"DownloadSplashScreen");

    for (NSDictionary *gameFile in self.gameFiles) {
        NSString *path = [gameFile valueForKey:@"path"];
        
        if ([path isEqualToString:@"/gameSplashScreen"]) {
            BOOL cached =  [ARLUtils CheckResource:self.gameId
                                          gameFile:gameFile];
            
            if (!cached) {
                DLog(@"Downloading: %@",gameFile);
                
                NSString *local = [ARLUtils DownloadResource:self.gameId
                                                    gameFile:gameFile];
                
                [self.backgroundImage performSelectorOnMainThread:@selector(setImage:)
                                                       withObject:[UIImage imageWithContentsOfFile:local] waitUntilDone:NO];
            } else {
                NSString *local = [ARLUtils GenerateResourceFileName:gameId path:path];

                DLog(@"Reusing: %@%@",self.gameId, path);

                [self.backgroundImage performSelectorOnMainThread:@selector(setImage:)
                                                       withObject:[UIImage imageWithContentsOfFile:local] waitUntilDone:NO];
            }
            
            [self.downloadStatus setValue:[NSNumber numberWithBool:TRUE]
                                   forKey:path];
            
            [self performSelectorOnMainThread:@selector(updateProgress:)
                                   withObject:[NSNumber numberWithBool:cached]
                                waitUntilDone:YES];
            
            break;
        }
    }
  
    DLog(@"%@", @"DownloadSplashScreen Ready");
}

/*!
 *  Downloads the remaining game files if present (and not already downloaded & unmodified).
 *
 *  Runs in a background thread.
 */
-(void) DownloadGameFiles {
    DLog(@"%@", @"DownloadGameFiles");

    for (NSDictionary *gameFile in self.gameFiles) {
        NSString *path = [gameFile valueForKey:@"path"];
        
        BOOL cached =  [ARLUtils CheckResource:self.gameId
                                      gameFile:gameFile];
        
        if (!cached) {
            DLog(@"Downloading: %@",gameFile);

            [ARLUtils DownloadResource:self.gameId
                              gameFile:gameFile];
        } else {
            DLog(@"Reusing: %@%@",self.gameId, path);
        }
        
        [self.downloadStatus setValue:[NSNumber numberWithBool:TRUE]
                               forKey:path];
        
        [self performSelectorOnMainThread:@selector(updateProgress:)
                               withObject:[NSNumber numberWithBool:cached]
                            waitUntilDone:YES];
    }
    
    DLog(@"%@", @"DownloadGameFiles Ready");
}

/*!
 *  Update after the splash screen period has elapsed.
 */
-(void)splashDone:(NSTimer *)timer {
    
    [self.phaseBar setHidden:YES];
    [self.progressBar setHidden:YES];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
    
    // self.progressBar.progress = 1.0f;
    
    [timer invalidate];
    
    [self playButtonAction:self.playButton];
}

/*!
 *  Update the progressbar and keep track of phases.
 *
 *  @param cached <#cached description#>
 */
- (void)updatePhase:(NSNumber *) phase {
    DLog(@"%@", @"updatePhase");
    
    self.phaseBar.progress = [phase floatValue] / phases;
}

/*!
 *  Update the progressbar and keep track of downloaded files.
 *
 *  @param cached <#cached description#>
 */
- (void)updateProgress:(NSNumber *) cached {
    DLog(@"%@", @"updateProgress");

    int cnt = 0;
    
    for (NSString *key in [self.downloadStatus keyEnumerator])
    {
        if ([(NSNumber *)[self.downloadStatus valueForKey:key] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            cnt++;
        }
    }
    
    if ([self.downloadStatus count]>0) {
        self.progressBar.progress = (float)cnt/[self.downloadStatus count];
    } else {
        self.progressBar.progress = 0.0f;
    }
    
    //if (![cached boolValue]) {
    downloaded++;
    //}
}

#pragma mark - Actions

/*!
 *  Getter
 *
 *  @return The Cell Identifier.
 */
- (IBAction)playButtonAction:(UIBarButtonItem *)sender {
    ARLPlayViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayView"];
    
    if (newViewController) {

        newViewController.gameId = self.gameId;
        newViewController.runId = self.runId;
        [newViewController setBackViewControllerClass:_class];
        
        // Move to another UINavigationController or UITabBarController etc.
        // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
        [self.navigationController pushViewController:newViewController animated:YES];
        
        newViewController = nil;
    }
}

#pragma mark - Notifications.

- (void)syncProgress:(NSNotification*)notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(syncProgress:)
                               withObject:notification
                            waitUntilDone:YES];
        return;
    }
    
    NSString *recordType = notification.object;
    
    // DLog(@"syncProgress: %@", recordType);
    
    if ([NSStringFromClass([GeneralItemVisibility class]) isEqualToString:recordType]) {
        //
    }
}

- (void)syncReady:(NSNotification*)notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(syncReady:)
                               withObject:notification
                            waitUntilDone:YES];
        return;
    }
    
    NSString *recordType = notification.object;
    
    DLog(@"syncReady: %@", recordType);
    
    if ([NSStringFromClass([GeneralItemVisibility class]) isEqualToString:recordType]) {
        //
    } else if ([NSStringFromClass([Run class]) isEqualToString:recordType]) {
        //
    } else if ([NSStringFromClass([Response class]) isEqualToString:recordType]) {
        //
    } else if ([NSStringFromClass([GeneralItem class]) isEqualToString:recordType]) {
        //
    } else if ([NSStringFromClass([Action class]) isEqualToString:recordType]) {
        //
    } else {
        DLog(@"syncReady, unhandled recordType: %@", recordType);
    }
}

@end
