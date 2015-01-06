//
//  ARLDownloadViewController.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 05/12/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLDownloadViewController.h"

@interface ARLDownloadViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;

- (IBAction)playButtonAction:(UIBarButtonItem *)sender;

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (strong, nonatomic) NSArray *gameFiles;

@property (strong, nonatomic) NSDictionary *downloadStatus;

@end

@implementation ARLDownloadViewController

@synthesize gameId;
@synthesize runId;

#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.downloadStatus = [[NSDictionary alloc] init];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];
    
    [self.tableView setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self DownloadGameContent];
    
    // å[self DownloadSplashScreen];
    
    //TODO: The Operation below does not update the table every change!
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
    
    NSBlockOperation *foreBO =[NSBlockOperation blockOperationWithBlock:^{
        [NSTimer scheduledTimerWithTimeInterval:(self.gameFiles.count==0 ? 0.1 : 2.5)
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
    
    [foreBO  addDependency:backBO6];
    
    [[NSOperationQueue mainQueue] addOperation:foreBO];
    
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

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // DLog(@"Cnt: %d", self.gameFiles.count);
    
    return self.gameFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: self.cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: self.cellIdentifier];
    }
    
    NSString *path = [[self.gameFiles objectAtIndex:indexPath.row] valueForKey:@"path"];
    NSArray *parts = [path componentsSeparatedByString:@"/"];
    NSNumber *size = [[self.gameFiles objectAtIndex:indexPath.row]
                      valueForKey:@"size"];
    
    cell.textLabel.text = [parts lastObject];
    
    if ([[self.downloadStatus valueForKey:path] boolValue]) {
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.detailTextLabel.text =[ARLUtils bytestoString:size];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0/2.0;
}

#pragma mark - Properties

-(NSString *) cellIdentifier {
    return  @"DownloadItem";
}

#pragma mark - Methods

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
    
#pragma warn Debug Code
    [ARLUtils LogJsonDictionary:game url:service];
    
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
                                @"dscription",                  @"richTextDescription",
                                nil];
    
    NSDictionary *datafixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                // Data,                                                        CoreData
                                nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gameId==%@", self.gameId];
    Game *item = [Game MR_findFirstWithPredicate: predicate];
    
    if (item) {
        if ([game valueForKey:@"deleted"] && [[game valueForKey:@"deleted"] integerValue] != 0) {
            DLog(@"Deleting Game: %@", [game valueForKey:@"title"])
            [item MR_deleteEntity];
        } else {
            DLog(@"Updating Game: %@", [game valueForKey:@"title"])
            item = (Game *)[ARLUtils UpdateManagedObjectFromDictionary:game
                                                         managedobject:item
                                                            nameFixups:namefixups
                                                            dataFixups:datafixups];
        }
    } else {
        if ([game valueForKey:@"deleted"] && [[game valueForKey:@"deleted"] integerValue] != 0) {
            // Skip creating deleted records.
            DLog(@"Skipping deleted Game: %@", [game valueForKey:@"title"])
        } else {
            // Uses MagicalRecord for Creation and Saving!
            DLog(@"Creating Game: %@", [game valueForKey:@"title"])
            item = (Game *)[ARLUtils ManagedObjectFromDictionary:game
                                                      entityName:@"Game"
                                                      nameFixups:namefixups
                                                      dataFixups:datafixups];
        }
    }
    
    // Saves any modification made after ManagedObjectFromDictionary.
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
        [ARLUtils LogJsonData:response url:query];
        
        NSDictionary *gameContent = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        
        self.gameFiles = (NSArray *)[gameContent objectForKey:@"gameFiles"];
        
        // Init Status Dictionary.
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:self.downloadStatus];
        for (NSDictionary *gameFile in self.gameFiles) {
            NSString *path = [gameFile valueForKey:@"path"];
            
            [dict setValue:[NSNumber numberWithBool:FALSE] forKey:path];
        }
        
        self.downloadStatus = dict;
        
        if (self.gameFiles.count>0) {
            [self.tableView performSelectorOnMainThread:@selector(setHidden:) withObject:NO waitUntilDone:NO];
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
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
            NSString *local = [ARLUtils DownloadResource:self.gameId gameFile:gameFile];

            [self.background performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithContentsOfFile:local] waitUntilDone:NO];
            
            [self.downloadStatus setValue:[NSNumber numberWithBool:TRUE] forKey: path];
            
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            
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
        
        [ARLUtils DownloadResource:self.gameId gameFile:gameFile];
        
        [self.downloadStatus setValue:[NSNumber numberWithBool:TRUE] forKey: path];
        
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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
    
#pragma warn Debug Code
    [ARLUtils LogJsonDictionary:response url:service];
    
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
            Run *item = [Run MR_findFirstWithPredicate: predicate];
            
            if (item) {
                if ([run valueForKey:@"deleted"] && [[run valueForKey:@"deleted"] integerValue] != 0) {
                    DLog(@"Deleting Run: %@", [run valueForKey:@"title"])
                    [item MR_deleteEntity];
                } else {
                    DLog(@"Updating Run: %@", [run valueForKey:@"title"])
                    item = (Run *)[ARLUtils UpdateManagedObjectFromDictionary:run
                                                                managedobject:item
                                                                   nameFixups:namefixups
                                                                   dataFixups:datafixups];

                    // We can only update if both objects share the same context.
                    Game *game =[Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId inContext:[NSManagedObjectContext MR_defaultContext]];
                    [item MR_inContext:[NSManagedObjectContext MR_defaultContext]].game = game;
                    
                    self.runId = item.runId;
                }
            } else {
                if ([run valueForKey:@"deleted"] && [[run valueForKey:@"deleted"] integerValue] != 0) {
                    // Skip creating deleted records.
                    DLog(@"Skipping deleted Run: %@", [run valueForKey:@"title"])
                } else {
                    // Uses MagicalRecord for Creation and Saving!
                    DLog(@"Creating Run: %@", [run valueForKey:@"title"])
                    item = (Run *)[ARLUtils ManagedObjectFromDictionary:run
                                                             entityName:@"Run"
                                                             nameFixups:namefixups
                                                             dataFixups:datafixups];

                    // We can only update if both objects share the same context.
                    Game *game =[Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId inContext:[NSManagedObjectContext MR_defaultContext]];
                    [item MR_inContext:[NSManagedObjectContext MR_defaultContext]].game = game;

                    self.runId = item.runId;
                }
            }
        }
    }
    
    // Saves any modification made after ManagedObjectFromDictionary.
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
        
#pragma warn Debug Code
        [ARLUtils LogJsonDictionary:response url:service];
        
        NSDictionary *actions = [response objectForKey:@"actions"];
        
        for (NSDictionary *action in actions) {
            //            @property (nonatomic, retain) NSString * action;
            //            @property (nonatomic, retain) NSNumber * synchronized;
            //            @property (nonatomic, retain) NSNumber * time;
            
            //            @property (nonatomic, retain) Account *account;
            //            @property (nonatomic, retain) GeneralItem *generalItem;
            //            @property (nonatomic, retain) Run *run;
            
            // if ([(NSNumber *)[action  valueForKey:@"gameId"] longLongValue] == [self.gameId longLongValue])
            {
                //                NSDictionary *namefixups = [NSDictionary dictionaryWithObjectsAndKeys:
                //                                            // Json,                         CoreData
                //                                            nil];
                //
                //                NSDictionary *datafixups = [NSDictionary dictionaryWithObjectsAndKeys:
                //                                            // Data,                                                        CoreData
                //                                            // Relations cannot be done here easily due to context changes.
                //                                            // [Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId], @"game",
                //                                            nil];

                //                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gameId==%@ && runId==%@", self.gameId, [run valueForKey:@"runId"]];
                //                Run *item = [Run MR_findFirstWithPredicate: predicate];
                //
                //                if (item) {
                //                    if ([run valueForKey:@"deleted"] && [[run valueForKey:@"deleted"] integerValue] != 0) {
                //                        DLog(@"Deleting Run: %@", [run valueForKey:@"title"])
                //                        [item MR_deleteEntity];
                //                    } else {
                //                        DLog(@"Updating Run: %@", [run valueForKey:@"title"])
                //                        item = (Run *)[ARLUtils UpdateManagedObjectFromDictionary:run
                //                                                                    managedobject:item
                //                                                                       nameFixups:namefixups
                //                                                                       dataFixups:datafixups];
                //
                //                        // We can only update if both objects share the same context.
                //                        Game *game =[Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId inContext:[NSManagedObjectContext MR_defaultContext]];
                //                        [item MR_inContext:[NSManagedObjectContext MR_defaultContext]].game = game;
                //
                //                        self.runId = item.runId;
                //                    }
                //                } else {
                //                    if ([run valueForKey:@"deleted"] && [[run valueForKey:@"deleted"] integerValue] != 0) {
                //                        // Skip creating deleted records.
                //                        DLog(@"Skipping deleted Run: %@", [run valueForKey:@"title"])
                //                    } else {
                //                        // Uses MagicalRecord for Creation and Saving!
                //                        DLog(@"Creating Run: %@", [run valueForKey:@"title"])
                //                        item = (Run *)[ARLUtils ManagedObjectFromDictionary:run
                //                                                                 entityName:@"Run"
                //                                                                 nameFixups:namefixups
                //                                                                 dataFixups:datafixups];
                //                        
                //                        // We can only update if both objects share the same context.
                //                        Game *game =[Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId inContext:[NSManagedObjectContext MR_defaultContext]];
                //                        [item MR_inContext:[NSManagedObjectContext MR_defaultContext]].game = game;
                //                        
                //                        self.runId = item.runId;
                //                    }
                //                }
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
    
#pragma warn Debug Code
    [ARLUtils LogJsonDictionary:response url:service];
    
    // [GeneralItem MR_truncateAll];
    
#pragma warn Debug Code
    //TODO: Delete either all generalItems beloging to a game or use updates.
    
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gameId==%@", self.gameId];
    // [GeneralItem MR_deleteAllMatchingPredicate: predicate];
    // [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
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
        GeneralItem *item = [GeneralItem MR_findFirstWithPredicate: predicate];
        
        //DONE: Test record deletion.
        //TODO: Find out what to do with linked records in other tables (like GeneralItemVisibility).
        if (item) {
            if ([generalItem valueForKey:@"deleted"] && [[generalItem valueForKey:@"deleted"] integerValue] != 0) {
                DLog(@"Deleting GeneralItem: %@", [generalItem valueForKey:@"name"])
                [item MR_deleteEntity];
            } else {
                DLog(@"Updating GeneralItem: %@", [generalItem valueForKey:@"name"])
                item = (GeneralItem *)[ARLUtils UpdateManagedObjectFromDictionary:generalItem
                                                                    managedobject:item
                                                                       nameFixups:namefixups
                                                                       dataFixups:datafixups];

                // We can only update if both objects share the same context.
                Game *game =[Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId inContext:[NSManagedObjectContext MR_defaultContext]];
                [item MR_inContext:[NSManagedObjectContext MR_defaultContext]].ownerGame = game;
            }
        } else {
            if ([generalItem valueForKey:@"deleted"] && [[generalItem valueForKey:@"deleted"] integerValue] != 0) {
                // Skip creating deleted records.
                DLog(@"Skipping deleted GeneralItem: %@", [generalItem valueForKey:@"name"])
            }else {
                // Uses MagicalRecord for Creation and Saving!
                DLog(@"Creating GeneralItem: %@", [generalItem valueForKey:@"name"])
                item = (GeneralItem *)[ARLUtils ManagedObjectFromDictionary:generalItem
                                                                 entityName:@"GeneralItem"
                                                                 nameFixups:namefixups
                                                                 dataFixups:datafixups];

                // We can only update if both objects share the same context.
                Game *game =[Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId inContext:[NSManagedObjectContext MR_defaultContext]];
                [item MR_inContext:[NSManagedObjectContext MR_defaultContext]].ownerGame = game;
            }
        }
        
        //TODO: Handle and resolved rest of the fields later.
        
        // DLog(@"GeneralItem ID: %@", generalitem.generalItemId);
        // DLog(@"GeneralItem Type: %@", generalitem.type);
        // DLog(@"GeneralItem Description: %@", generalitem.descriptionText);
    }
    
    // Saves any modification made after ManagedObjectFromDictionary.
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    //WESPOT CODE
    //    + (NSManagedObject *) ManagedObjectFromDictionary:(NSDictionary *)dict
    //entityName:(NSString *)entity
    //nameFixups:(NSDictionary *)fixups {
    
    //
    //    GeneralItem *gi = [self retrieveFromDb:giDict withManagedContext:context];
    //    if ([[giDict objectForKey:@"deleted"] boolValue]) {
    //        if (gi) {
    //            //item is deleted
    //            [context deleteObject:gi];
    //            gi=nil;
    //        }
    //        return nil;
    //    }
    //    if (!gi) {
    //        gi = [NSEntityDescription insertNewObjectForEntityForName:@"GeneralItem"
    //                                           inManagedObjectContext:context];
    //    }
    //
    //#pragma warn VEG CREATE GI here with a local id of 0 if missing in dictionary.
    //
    //    if ([giDict objectForKey:@"id"]) {
    //        gi.generalItemId = [giDict objectForKey:@"id"];
    //    } else {
    //        gi.generalItemId = 0;
    //    }
    //    gi.ownerGame = game;
    //    gi.gameId = [giDict objectForKey:@"gameId"];
    //    gi.lat = [giDict objectForKey:@"lat"];
    //    gi.lng = [giDict objectForKey:@"lng"];
    //    gi.name = [giDict objectForKey:@"name"];
    //    gi.richText = [giDict objectForKey:@"richText"];
    //    gi.sortKey = [giDict objectForKey:@"sortKey"] ;
    //    gi.type = [giDict objectForKey:@"type"];
    //    gi.json = [NSKeyedArchiver archivedDataWithRootObject:giDict];
    //
    //    if ( gi.generalItemId != 0) {
    //        [self setCorrespondingVisibilityItems:gi];
    //
    //        [self downloadCorrespondingData:giDict withGeneralItem:gi inManagedObjectContext:context];
    //    }
    //
    //    [INQLog SaveNLog:context];
}

/*!
 *  Update after the splash screen period has elapsed.
 */
-(void)splashDone:(NSTimer *)timer {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
    
    // [self.tableView reloadData];
    
    [self.tableView setHidden:YES];
    
    [timer invalidate];
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
        // if ([newViewController respondsToSelector:@selector(setGameId:)]) {
        //      [newViewController performSelector:@selector(setGameId:) withObject:self.gameId];
        // }
        
        newViewController.gameId = self.gameId;
        
        // Move to another UINavigationController or UITabBarController etc.
        // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
        [self.navigationController pushViewController:newViewController animated:YES];
        
        newViewController = nil;
    }
}

@end
