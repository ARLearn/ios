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

- (IBAction)playButtonAction:(UIBarButtonItem *)sender;

@property (strong, nonatomic) NSArray *gameFiles;
@property (strong, nonatomic) NSDictionary *downloadStatus;

@end

@implementation ARLDownloadViewController

@synthesize gameId;
@synthesize runId;

NSInteger downloaded = 0;

#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.downloadStatus = [[NSDictionary alloc] init];

    [self applyConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
    
    self.navigationItem.title = @"Download";
    
    [self.playButton setEnabled:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    downloaded = 0;
    
    // Debug code to force re-valuation.
    // [Action MR_truncateAll];
    
    NSBlockOperation *backBO0 =[NSBlockOperation blockOperationWithBlock:^{
        [self DownloadGame];
    }];
    
    NSBlockOperation *backBO1 =[NSBlockOperation blockOperationWithBlock:^{
        [self DownloadGameContent];
    }];
    
    NSBlockOperation *backBO2 =[NSBlockOperation blockOperationWithBlock:^{
        [self DownloadSplashScreen];
    }];
    
    NSBlockOperation *backBO3 =[NSBlockOperation blockOperationWithBlock:^{
        [self DownloadGameFiles];
    }];
    
    NSBlockOperation *backBO4 =[NSBlockOperation blockOperationWithBlock:^{
        [self DownloadGeneralItems];
    }];
    
    NSBlockOperation *backBO5 =[NSBlockOperation blockOperationWithBlock:^{
        [self DownloadRuns];
    }];
    
    NSBlockOperation *backBO6 =[NSBlockOperation blockOperationWithBlock:^{
        [self DownloadActions];
    }];
    
    NSBlockOperation *backBO7 =[NSBlockOperation blockOperationWithBlock:^{
        [self DownloadResponses];
    }];
    

    NSBlockOperation *foreBO =[NSBlockOperation blockOperationWithBlock:^{
        [NSTimer scheduledTimerWithTimeInterval:(downloaded==0 ? 0.1 : 2.5)
                                         target:self
                                       selector:@selector(splashDone:)
                                       userInfo:nil
                                        repeats:NO];
    }];
    
    // Add dependencies: backBO0 -> backBO1 -> backBO2 -> backBO3 -> back04 -> back05 -> back06 -> foreBO.
    [backBO1 addDependency:backBO0];
    [backBO2 addDependency:backBO1];
    [backBO3 addDependency:backBO2];
    [backBO4 addDependency:backBO3];
    [backBO5 addDependency:backBO4];
    [backBO6 addDependency:backBO5];
    [backBO7 addDependency:backBO6];
    
    [foreBO  addDependency:backBO7];
    
    [[NSOperationQueue mainQueue] addOperation:foreBO];
    
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

#pragma mark - Methods

- (void) applyConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,             @"view",
                                     
                                     self.backgroundImage,  @"backgroundImage",
                                     
                                     self.progressBar,      @"progressBar",
                                     
                                     nil];
    
    // See http://stackoverflow.com/questions/17772922/can-i-use-autolayout-to-provide-different-constraints-for-landscape-and-portrait
    // See https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/Bars.html
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Fix Background.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    // Fix ProgressBar Horizontal.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[progressBar]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    // Fix ProgressBar Vertically.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[progressBar]-(8)-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}

/*!
 *  Downloads teh Game we're participating in.
 *
 *  Runs in a background thread.
 */
-(void) DownloadGame {
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
                                @"description",                  @"richTextDescription",
                                nil];
    
    NSDictionary *datafixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                // Data,                                                        CoreData
                                nil];
    
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
}

-(void) DownloadGameContent {
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
            
            [dict setValue:[NSNumber numberWithBool:FALSE] forKey:path];
        }
        
        self.downloadStatus = dict;
    }
}

/*!
 *  Downloads the splashscreen if present (and not already downloaded & unmodified).
 *
 *  Runs in a background thread.
 */
-(void) DownloadSplashScreen {
    for (NSDictionary *gameFile in self.gameFiles) {
        NSString *path = [gameFile valueForKey:@"path"];
        
        if ([path isEqualToString:@"/gameSplashScreen"]) {
            BOOL cached =  [ARLUtils CheckResource:self.gameId
                                          gameFile:gameFile];
            
            if (!cached) {
                NSString *local = [ARLUtils DownloadResource:self.gameId
                                                    gameFile:gameFile];
                
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
}

/*!
 *  Downloads the remaining game files if present (and not already downloaded & unmodified).
 *
 *  Runs in a background thread.
 */
-(void) DownloadGameFiles {
    for (NSDictionary *gameFile in self.gameFiles) {
        NSString *path = [gameFile valueForKey:@"path"];
        
        BOOL cached =  [ARLUtils CheckResource:self.gameId
                                      gameFile:gameFile];
        
        if (!cached) {
        [ARLUtils DownloadResource:self.gameId
                          gameFile:gameFile];
        }
        
        [self.downloadStatus setValue:[NSNumber numberWithBool:TRUE]
                               forKey: path];
        
        [self performSelectorOnMainThread:@selector(updateProgress:)
                               withObject:[NSNumber numberWithBool:cached]
                            waitUntilDone:YES];
    }
}

/*!
 *  Downloads Runs we're participating in.
 *
 *  Runs in a background thread.
 */
-(void) DownloadRuns {
    NSString *service = @"myRuns/participate";
    NSData *data = [ARLNetworking sendHTTPGetWithAuthorization:service];
    
    NSError *error = nil;
    
    NSDictionary *response = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                      error:&error] : nil;
    ELog(error);
    
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
    
    //#pragma warn Debug Code
    // [ARLUtils LogJsonDictionary:response url:service];
    
    NSDictionary *runs = [response objectForKey:@"runs"];
    
    for (NSDictionary *run in runs) {
        //        @property (nonatomic, retain) NSNumber * deleted;         handled
        //        @property (nonatomic, retain) NSNumber * gameId;          mapped
        //        @property (nonatomic, retain) NSString * owner;
        //        @property (nonatomic, retain) NSNumber * runId;           mapped
        //        @property (nonatomic, retain) NSString * title;           mapped
        //        @property (nonatomic, retain) NSSet *actions;
        //        @property (nonatomic, retain) NSSet *currentVisibility;
        //        @property (nonatomic, retain) Game *game;                     relation      ( relation).
        //        @property (nonatomic, retain) Inquiry *inquiry;
        //        @property (nonatomic, retain) NSSet *itemVisibilityRules;
        //        @property (nonatomic, retain) NSSet *messages;
        //        @property (nonatomic, retain) NSSet *responses;
        
        if ([(NSNumber *)[run valueForKey:@"gameId"] longLongValue] == [self.gameId longLongValue])
        {
            NSDictionary *namefixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                        // Json,                         CoreData
                                        nil];
            
            NSDictionary *datafixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                        // Data,                                                        CoreData
                                        // Relations cannot be done here easily due to context changes.
                                        // [Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId], @"game",
                                        nil];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gameId==%@ && runId==%@", self.gameId, [run valueForKey:@"runId"]];
            
            Run *item = [Run MR_findFirstWithPredicate: predicate inContext:ctx];
            
            if (item) {
                if (([run valueForKey:@"deleted"] && [[run valueForKey:@"deleted"] integerValue] != 0) ||
                    ([run valueForKey:@"revoked"] && [[run valueForKey:@"revoked"] integerValue] != 0)) {
                    DLog(@"Deleting Run: %@", [run valueForKey:@"title"])
                    [item MR_deleteEntity];
                } else {
                    DLog(@"Updating Run: %@", [run valueForKey:@"title"])
                    item = (Run *)[ARLUtils UpdateManagedObjectFromDictionary:run
                                                                managedobject:item
                                                                   nameFixups:namefixups
                                                                   dataFixups:datafixups
                                                               managedContext:ctx];

                    // We can only update if both objects share the same context.
                    Game *game =[Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId inContext:ctx];
                    item.game = game;
                    
                    self.runId = item.runId;
                }
            } else {
                if (([run valueForKey:@"deleted"] && [[run valueForKey:@"deleted"] integerValue] != 0) ||
                    ([run valueForKey:@"revoked"] && [[run valueForKey:@"revoked"] integerValue] != 0)) {
                    // Skip creating deleted records.
                    DLog(@"Skipping deleted Run: %@", [run valueForKey:@"title"])
                } else {
                    // Uses MagicalRecord for Creation and Saving!
                    DLog(@"Creating Run: %@", [run valueForKey:@"title"])
                    item = (Run *)[ARLUtils ManagedObjectFromDictionary:run
                                                             entityName:[Run MR_entityName] //@"Run"
                                                             nameFixups:namefixups
                                                             dataFixups:datafixups
                                                         managedContext:ctx];
                    
                    // We can only update if both objects share the same context.
                    Game *game =[Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId inContext:ctx];
                    item.game = game;
                    
                    self.runId = item.runId;
                }
            }
        }
    }
    
    // Saves any modification made after ManagedObjectFromDictionary.
    [ctx MR_saveToPersistentStoreAndWait];

    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

/*!
 *  Downloads Actions of the Run we're participating in.
 *
 *  Runs in a background thread.
 */
-(void) DownloadActions {
    if (self.runId) {
        NSString *service = [NSString stringWithFormat:@"actions/runId/%@", self.runId];
        NSData *data = [ARLNetworking sendHTTPGetWithAuthorization:service];
        
        NSError *error = nil;
        
        NSDictionary *response = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                          error:&error] : nil;
        ELog(error);
        
        //#pragma warn Debug Code
        // [ARLUtils LogJsonDictionary:response url:service];
        
        NSDictionary *actions = [response objectForKey:@"actions"];

        NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
        
        //{
        //    "type": "org.celstec.arlearn2.beans.run.ActionList",
        //    "runId": 4977978815545344,
        //    "deleted": false,
        //    "actions": [
        //                {
        //                    "type": "org.celstec.arlearn2.beans.run.Action",
        //                    "timestamp": 1421241029935,
        //                    "runId": 4977978815545344,
        //                    "deleted": false,
        //                    "identifier": 5807073128349696,
        //                    "generalItemId": 6180497885495296,
        //                    "generalItemType": "org.celstec.arlearn2.beans.generalItem.AudioObject",
        //                    "userEmail": "2:103021572104496509774",
        //                    "time": 1421241029935,
        //                    "action": "read"
        //                },
        //                {
        //                    "type": "org.celstec.arlearn2.beans.run.Action",
        //                    "timestamp": 1421237414637,
        //                    "runId": 4977978815545344,
        //                    "deleted": false,
        //                    "identifier": 5861948851748864,
        //                    "generalItemId": 6180497885495296,
        //                    "generalItemType": "org.celstec.arlearn2.beans.generalItem.AudioObject",
        //                    "userEmail": "2:103021572104496509774",
        //                    "time": 1421237414637,
        //                    "action": "read"
        //                },
        //                {
        //                    "type": "org.celstec.arlearn2.beans.run.Action",
        //                    "timestamp": 1421242040473,
        //                    "runId": 4977978815545344,
        //                    "deleted": false,
        //                    "identifier": 5865743723790336,
        //                    "generalItemId": 6180497885495296,
        //                    "generalItemType": "org.celstec.arlearn2.beans.generalItem.AudioObject",
        //                    "userEmail": "2:103021572104496509774",
        //                    "time": 1421242040473,
        //                    "action": "read"
        //                }
        //                ]
        //}
        
        for (NSDictionary *item in actions) {
          
            // @property (nonatomic, retain) NSString * action;          mapped
            // @property (nonatomic, retain) NSNumber * synchronized;    yes (hardcoded value as it comes from the server)
            // @property (nonatomic, retain) NSNumber * time;            mapped
            
            // @property (nonatomic, retain) Account *account;           manual
            // @property (nonatomic, retain) GeneralItem *generalItem;   manual
            // @property (nonatomic, retain) Run *run;                   manual

            NSString *userEmail = (NSString *)[item valueForKey:@"userEmail"];
            
            NSArray *userComponents = [userEmail componentsSeparatedByString:@":"];
            
            NSString *accountType = [userComponents objectAtIndex:0];
            NSString *accountId =[userComponents objectAtIndex:1];
            
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"run.runId==%lld && generalItem.generalItemId==%lld && account.accountType==%@ && account.localId==%@",
                                       [[item valueForKey:@"runId"] longLongValue],
                                       [[item valueForKey:@"generalItemId"] longLongValue],
                                       accountType,
                                       accountId
                                       ];
            
            Action *action = [Action MR_findFirstWithPredicate:predicate1 inContext:ctx];
           
            Run *r;
            GeneralItem *gi;
            Account *a;
            
            if (action==nil) {
                Log(@"Creating Action");
                action = (Action *)[ARLUtils ManagedObjectFromDictionary:item
                                                              entityName:[Action MR_entityName] // @"Action"
                                                          managedContext:ctx];
                
                // Manual Fixups;
                {
#warning BAD-ACCESS can occur.
                    action.synchronized = [NSNumber numberWithBool:YES];
                }

                if ([item valueForKey:@"runId"] && [[item valueForKey:@"runId"] longLongValue] != 0)
                {
                    r = [Run MR_findFirstByAttribute:@"runId"
                                                withValue:[item valueForKey:@"runId"]
                                                inContext:ctx];
                    if (r) {
                        action.run = r;
                    } else {
                        Log("Run %@ for Action not found", [item valueForKey:@"runId"]);
                    }
                }
                
                if ([item valueForKey:@"generalItemId"] && [[item valueForKey:@"generalItemId"] longLongValue] != 0)
                {
                    gi = [GeneralItem MR_findFirstByAttribute:@"generalItemId"
                                                                 withValue:[item valueForKey:@"generalItemId"]
                                                                 inContext:ctx];
                    if (gi) {
                        action.generalItem = gi;
                    } else {
                        Log("GeneralItem %@ for Action not found", [item valueForKey:@"generalItemId"]);
                    }
                }
                
                {
                    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"accountType==%@ && localId==%@",
                                               accountType,
                                               accountId];
                    
                    a = [Account MR_findFirstWithPredicate:predicate2
                                                          inContext:ctx];
                    
                    if (a) {
                        action.account = a;
                    }
                }
                
               [ctx MR_saveToPersistentStoreAndWait];
            }
        }
        
        // Saves any modification made after ManagedObjectFromDictionary.
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
}

/*!
 *  Downloads the general items and stores/update or deletes them in/from the database.
 *
 *  Runs in a background thread.
 */
-(void) DownloadGeneralItems {
    NSString *service = [NSString stringWithFormat:@"generalItems/gameId/%@", self.gameId];
    NSData *data = [ARLNetworking sendHTTPGetWithAuthorization:service];
    
    NSError *error = nil;
    
    NSDictionary *response = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                      error:&error] : nil;
    ELog(error);
    
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
    
    //#pragma warn Debug Code
    // [ARLUtils LogJsonDictionary:response url:service];
    
    NSDictionary *generalItems = [response objectForKey:@"generalItems"];
    
    for (NSDictionary *generalItem in generalItems) {
        // [ARLUtils LogJsonDictionary:generalItem url:NULL];
        
        // @property (nonatomic, retain) NSNumber * deleted;                     handled
        
        // @property (nonatomic, retain) NSString * descriptionText;                fixup ( description, cannot rename field as descrition is reserved ).
        // @property (nonatomic, retain) NSNumber * gameId;                      mapped    ( same as ownerGame )?
        // @property (nonatomic, retain) NSNumber * generalItemId;                  fixup ( id).
        // @property (nonatomic, retain) NSData * json;                             fixup ( generalItem as json).
        // @property (nonatomic, retain) NSNumber * lat;                         mapped
        // @property (nonatomic, retain) NSNumber * lng;                         mapped
        // @property (nonatomic, retain) NSString * name;                        mapped
        // @property (nonatomic, retain) NSString * richText;                    mapped
        // @property (nonatomic, retain) NSNumber * sortKey;                        todo  ( ??? ).
        // @property (nonatomic, retain) NSString * type;                        mapped
        
        // @property (nonatomic, retain) NSSet *actions;                             todo  ( relation ).
        // @property (nonatomic, retain) NSSet *currentVisibility;                   todo  ( relation ).
        // @property (nonatomic, retain) NSSet *data;                                todo  ( relation ).
        // @property (nonatomic, retain) Game *ownerGame;                           manual ( relation ).
        // @property (nonatomic, retain) NSSet *responses;                           todo  ( relation ).
        // @property (nonatomic, retain) NSSet *visibility;                          todo  ( relation ).
        
        // Sample JSON:
        //{
        //    autoLaunch = 0;
        //    deleted = 0;
        //    dependsOn =             {
        //        lat = "51.22182818142593";
        //        lng = "6.805556677490245";
        //        radius = 1000;
        //        type = "org.celstec.arlearn2.beans.dependencies.ProximityDependency";
        //    };
        //    description = "";
        //    fileReferences =             (
        //    );
        //    gameId = 13876002;
        //    id = 13876003;
        //    lastModificationDate = 1385113739048;
        //    lat = "51.21817260455731";
        //    lng = "6.804355047851573";
        //    name = "Welcome at MDH Stefaan";
        //    richText = "";
        //    roles =             (
        //    );
        //    scope = user;
        //    showCountDown = 0;
        //    sortKey = 0;
        //    type = "org.celstec.arlearn2.beans.generalItem.NarratorItem";
        //},
        
        NSDictionary *namefixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                    // Json,                         CoreData
                                    @"description",                  @"descriptionText",
                                    @"id",                           @"generalItemId",
                                    nil];
        
        NSDictionary *datafixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                    // Data,                                                        CoreData
                                    [NSKeyedArchiver archivedDataWithRootObject:generalItem],       @"json",
                                    // Relations cannot be done here easily due to context changes.
                                    // [Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId], @"ownerGame",
                                    nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gameId==%@ && generalItemId==%@", self.gameId, [generalItem valueForKey:@"id"]];
        GeneralItem *item = [GeneralItem MR_findFirstWithPredicate: predicate inContext:ctx];
        
        //DONE: Test record deletion.
        //TODO: Find out what to do with linked records in other tables (like GeneralItemVisibility).
        if (item) {
            if (([generalItem valueForKey:@"deleted"] && [[generalItem valueForKey:@"deleted"] integerValue] != 0) ||
                ([generalItem valueForKey:@"revoked"] && [[generalItem valueForKey:@"revoked"] integerValue] != 0)) {
                DLog(@"Deleting GeneralItem: %@", [generalItem valueForKey:@"name"])
                [item MR_deleteEntity];
            } else {
                DLog(@"Updating GeneralItem: %@", [generalItem valueForKey:@"name"])
                item = (GeneralItem *)[ARLUtils UpdateManagedObjectFromDictionary:generalItem
                                                                    managedobject:item
                                                                       nameFixups:namefixups
                                                                       dataFixups:datafixups
                                                                   managedContext:ctx];
                
                // We can only update if both objects share the same context.
                Game *game =[Game MR_findFirstByAttribute:@"gameId"
                                                withValue:self.gameId
                                                inContext:ctx];
                item.ownerGame = game;
            }
        } else {
            if (([generalItem valueForKey:@"deleted"] && [[generalItem valueForKey:@"deleted"] integerValue] != 0) ||
                ([generalItem valueForKey:@"revoked"] && [[generalItem valueForKey:@"revoked"] integerValue] != 0)) {
                // Skip creating deleted records.
                DLog(@"Skipping deleted GeneralItem: %@", [generalItem valueForKey:@"name"])
            }else {
                // Uses MagicalRecord for Creation and Saving!
                DLog(@"Creating GeneralItem: %@", [generalItem valueForKey:@"name"])
                item = (GeneralItem *)[ARLUtils ManagedObjectFromDictionary:generalItem
                                                                 entityName:[GeneralItem MR_entityName] // @"GeneralItem"
                                                                 nameFixups:namefixups
                                                                 dataFixups:datafixups
                                                             managedContext:ctx];

                // We can only update if both objects share the same context.
                Game *game =[Game MR_findFirstByAttribute:@"gameId"
                                                withValue:self.gameId
                                                inContext:ctx];
                item.ownerGame = game;
            }
        }
        
        [ctx MR_saveToPersistentStoreAndWait];
        
        //TODO: Handle and resolved rest of the fields later.
        
        // DLog(@"GeneralItem ID: %@", generalitem.generalItemId);
        // DLog(@"GeneralItem Type: %@", generalitem.type);
        // DLog(@"GeneralItem Description: %@", generalitem.descriptionText);
    }
    
    // Saves any modification made after ManagedObjectFromDictionary.
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

/*!
 *  Downloads the general items and stores/update or deletes them in/from the database.
 *
 *  Runs in a background thread.
 */
-(void) DownloadResponses {
    NSString *service = [NSString stringWithFormat:@"response/runId/%@", self.runId];
    NSData *data = [ARLNetworking sendHTTPGetWithAuthorization:service];
    
    NSError *error = nil;
    
    NSDictionary *response = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                      error:&error] : nil;
    ELog(error);
    
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
    
    //#pragma warn Debug Code
    // [ARLUtils LogJsonDictionary:response url:service];
    
    NSDictionary *responses = [response objectForKey:@"responses"];
    
    for (NSDictionary *response in responses) {
        
        // Sample JSON:
        //{
        //    "type": "org.celstec.arlearn2.beans.run.ResponseList",
        //    "deleted": false,
        //    "responses": [
        //                  {
        //                      "type": "org.celstec.arlearn2.beans.run.Response",
        //                      "timestamp": 1429778810783,
        //                      "runId": 5777243095695360,
        //                      "deleted": false,
        //                      "responseId": 5313819882553344,
        //                      "generalItemId": 5800061720068096,
        //                      "userEmail": "2:103021572104496509774",
        //                      "responseValue": "{\"imageUrl\":\"http:\\/\\/streetlearn.appspot.com\\/uploadService\\/5777243095695360\\/2:103021572104496509774\\/image1816922733.jpg\",\"width\":1024,\"height\":720,\"contentType\":\"image\\/jpeg\"}",
        //                      "lastModificationDate": 1429778806816,
        //                      "revoked": false
        //                  },
        //                  {
        //                      "type": "org.celstec.arlearn2.beans.run.Response",
        //                      "timestamp": 1429778585233,
        //                      "runId": 5777243095695360,
        //                      "deleted": false,
        //                      "responseId": 5796436767670272,
        //                      "generalItemId": 5800061720068096,
        //                      "userEmail": "2:103021572104496509774",
        //                      "responseValue": "{\"value\":258}",
        //                      "lastModificationDate": 1429778582920,
        //                      "revoked": false
        //                  }
        //                  ]
        //}
        
//        @property (nonatomic, retain) NSString * contentType;
//        @property (nonatomic, retain) NSData * data;
//        @property (nonatomic, retain) NSString * fileName;
//        @property (nonatomic, retain) NSNumber * height;
//        @property (nonatomic, retain) NSNumber * lat;
//        @property (nonatomic, retain) NSNumber * lng;
//        @property (nonatomic, retain) NSNumber * responseId;
//        @property (nonatomic, retain) NSNumber * responseType;
//        @property (nonatomic, retain) NSNumber * synchronized;
//        @property (nonatomic, retain) NSData * thumb;
//        @property (nonatomic, retain) NSNumber * timeStamp;
//        @property (nonatomic, retain) NSString * value;
//        @property (nonatomic, retain) NSNumber * width;
//        @property (nonatomic, retain) NSNumber * revoked;
//        @property (nonatomic, retain) Account *account;
//        @property (nonatomic, retain) GeneralItem *generalItem;
//        @property (nonatomic, retain) Run *run;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"responseId==%@", [response valueForKey:@"responseId"]];
        
        Response *item = [Response MR_findFirstWithPredicate: predicate inContext:ctx];

        NSDictionary *namefixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                    // Json,                         CoreData
                                    @"timestamp",                    @"timeStamp",
                                    @"responseValue",                @"value",
                                    nil];
        
        NSDictionary *datafixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                    // Data,                                                        CoreData
                                    // [NSKeyedArchiver archivedDataWithRootObject:generalItem],       @"json",
                                    // Relations cannot be done here easily due to context changes.
                                    // [Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId], @"ownerGame",
                                    nil];
        
        //DONE: Test record deletion.
        //TODO: Find out what to do with linked records in other tables (like GeneralItemVisibility).
        
        BOOL deleted = NO;
        
        if (item) {
            if (([response valueForKey:@"deleted"] && [[response valueForKey:@"deleted"] integerValue] != 0) ||
                ([response valueForKey:@"revoked"] && [[response valueForKey:@"revoked"] integerValue] != 0)) {
                DLog(@"Deleting Response: %@", [response valueForKey:@"responseId"])
                [item MR_deleteEntity];
                
                deleted = YES;
            } else {
                DLog(@"Updating Response: %@", [response valueForKey:@"responseId"])
                item = (Response *)[ARLUtils UpdateManagedObjectFromDictionary:response
                                                                 managedobject:item
                                                                    nameFixups:namefixups
                                                                    dataFixups:datafixups
                                                                managedContext:ctx];
                

            }
        } else {
            if (([response valueForKey:@"deleted"] && [[response valueForKey:@"deleted"] integerValue] != 0) ||
                ([response valueForKey:@"revoked"] && [[response valueForKey:@"revoked"] integerValue] != 0)) {
                // Skip creating deleted records.
                DLog(@"Skipping deleted Response: %@", [response valueForKey:@"responseId"])
            } else {
                // Uses MagicalRecord for Creation and Saving!
                DLog(@"Creating Response: %@", [response valueForKey:@"responseId"])
                item = (Response *)[ARLUtils ManagedObjectFromDictionary:response
                                                                 entityName:[Response MR_entityName] // @"Response"
                                                                 nameFixups:namefixups
                                                                 dataFixups:datafixups
                                                          managedContext:ctx];
            }
        }
    
        // We can only update if both objects share the same context.
        
        if (!deleted) {
            // 1) Update Run
            if (!(item.run && [item.run.runId isEqualToNumber:self.runId])) {
                Run *run =[Run MR_findFirstByAttribute:@"runId"
                                             withValue:self.runId
                                             inContext:ctx];
                item.run = run;
            }
            
            // 2) Update Account
            NSArray *userComponents = [[response valueForKey:@"userEmail"] componentsSeparatedByString:@":"];
            
            NSString *accountType = [userComponents objectAtIndex:0];
            NSString *accountId =[userComponents objectAtIndex:1];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(localId = %@) AND (accountType = %@)", accountId, accountType];
            
            Account *account = [Account MR_findFirstWithPredicate:predicate inContext:ctx];
            if (!account) {
                NSData *data = [ARLNetworking getUserInfo:self.runId
                                                   userId:accountId
                                               providerId:accountType];
                
                NSDictionary *dict = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                            options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                              error:&error] : nil;
                if (dict) {
                    
                    NSURL *url = [NSURL URLWithString:[dict objectForKey:[dict objectForKey:@"picture"] ? @"picture": @"icon"]];
                    NSData *urlData = [NSData dataWithContentsOfURL:url];
                    
                    NSDictionary *datafixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                                // Data,                                                        CoreData
                                                urlData,                                                        @"picture",
                                                // Relations cannot be done here easily due to context changes.
                                                // [Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId], @"ownerGame",
                                                nil];
                    
                    account = (Account *)[ARLUtils ManagedObjectFromDictionary:dict
                                                                    entityName:[Account MR_entityName]
                                                                    nameFixups:nil
                                                                    dataFixups:datafixups
                                                                managedContext:ctx];
                }
            }
            item.account = account;
            
            // 3) Update GeneratItem
            if (!(item.generalItem && [item.generalItem.generalItemId isEqualToNumber:[response valueForKey:@"generalItemId"]])) {
                GeneralItem *generalitem =[GeneralItem MR_findFirstByAttribute:@"generalItemId"
                                                                     withValue:[response valueForKey:@"generalItemId"]
                                                                     inContext:ctx];
                item.generalItem = generalitem;
            }
            
            // 4) Update responseType
            NSError *error = nil;
            NSData *data = [[response objectForKey:@"responseValue"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *value = [NSJSONSerialization JSONObjectWithData:data
                                                                  options: NSJSONReadingMutableContainers
                                                                    error: &error];
            ELog(error);
            
            if (value) {
                if ([value objectForKey:@"imageUrl"]) {
                    item.height = [NSNumber numberWithInt:[[value objectForKey:@"height"] integerValue]];
                    item.width = [NSNumber numberWithInt:[[value objectForKey:@"width"] integerValue]];
                    item.fileName = [value objectForKey:@"imageUrl"];
                    item.contentType = @"application/jpg";
                    item.responseType = [NSNumber numberWithInt:PHOTO];
                } else if ([value objectForKey:@"videoUrl"]) {
                    item.fileName = [value objectForKey:@"videoUrl"];
                    item.contentType = @"video/quicktime";
                    item.responseType = [NSNumber numberWithInt:VIDEO];
                } else if ([value objectForKey:@"audioUrl"]) {
                    item.fileName = [value objectForKey:@"audioUrl"];
                    if ([item.fileName hasSuffix:@".m4a"]) {
                        item.contentType = @"audio/aac";
                    } else  if ([item.fileName hasSuffix:@".mp3"]) {
                        item.contentType = @"audio/mp3";
                    } else  if ([item.fileName hasSuffix:@".amr"]) {
                        item.contentType = @"audio/amr";
                    } else {
                        // Fallback.
                        item.contentType = @"audio/aac";
                    }
                    item.responseType = [NSNumber numberWithInt:AUDIO];
                } else if ([value objectForKey:@"text"]) {
                    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    item.value = jsonString;//[valueDict objectForKey:@"text"];
                    item.responseType = [NSNumber numberWithInt:TEXT];
                } else if ([value objectForKey:@"value"]) {
                    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    item.value = jsonString;//[valueDict objectForKey:@"value"];
                    item.responseType = [NSNumber numberWithInt:NUMBER];
                }
            }
        }

        [ctx MR_saveToPersistentStoreAndWait];
    }
    
    // Saves any modification made after ManagedObjectFromDictionary.
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}


/*!
 *  Update after the splash screen period has elapsed.
 */
-(void)splashDone:(NSTimer *)timer {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
    
    [self.playButton setEnabled:YES];
    
    self.progressBar.progress = 1.0f;
    
    [timer invalidate];
    
    [self playButtonAction:self.playButton];
}

/*!
 *  Update the progressbar and keep track of downloaded files.
 *
 *  @param cached <#cached description#>
 */
- (void)updateProgress:(NSNumber *) cached {
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
        self.progressBar.progress =0.0f;
    }
    
    if (![cached boolValue]) {
        downloaded++;
    }
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

#warning There is no selection of runs nor creation when missing yet. Code expects one run to be present!
        newViewController.gameId = self.gameId;
        newViewController.runId = self.runId;
        
        // Move to another UINavigationController or UITabBarController etc.
        // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
        [self.navigationController pushViewController:newViewController animated:YES];
        
        newViewController = nil;
    }
}

@end
