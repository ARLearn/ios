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

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (strong, nonatomic) NSArray *gameFiles;

@property (strong, nonatomic) NSDictionary *downloadStatus;

@end

@implementation ARLDownloadViewController

@synthesize gameId;

#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.downloadStatus = [[NSDictionary alloc] init];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // [self DownloadGameFiles];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self DownloadGameFiles];
    
    //[self.navigationController setNavigationBarHidden:YES];
    //[self.navigationController setToolbarHidden:YES];
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
    DLog(@"Cnt: %d", self.gameFiles.count);
 
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
    cell.detailTextLabel.text =[ARLUtils bytestoString:size];

    if ([self.downloadStatus valueForKey:path]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0/2;
}

#pragma mark - Properties

/*!
 *  Getter
 *
 *  @return The Cell Identifier.
 */
-(NSString *) cellIdentifier {
    return  @"DownloadItem";
}

#pragma mark - Methods

-(void) DownloadGameFiles {

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
        
        [self.tableView reloadData];
        
        for (NSDictionary *gameFile in self.gameFiles) {
            NSString *path = [gameFile valueForKey:@"path"];

            [self.downloadStatus setValue:FALSE forKey: path];

            NSString *local = [ARLUtils DownloadResource:self.gameId gameFile:gameFile];
            
            if ([path isEqualToString:@"/gameSplashScreen"]) {
                [self.background setImage:[UIImage imageWithContentsOfFile:local]];
            }

            [self.downloadStatus setValue:[NSNumber numberWithBool:TRUE] forKey: path];
        }
        
        NSString *service = [NSString stringWithFormat:@"generalItems/gameId/%@", self.gameId];
        NSData *data = [ARLNetworking sendHTTPGetWithAuthorization:service];
        
        NSError *error = nil;
        
        NSDictionary *response = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                          error:&error] : nil;
        ELog(error);
        
#pragma warn Debug Code
        // [ARLUtils LogJsonDictionary:response url:service];
        
        //    [GeneralItem MR_truncateAll];
        
#pragma warn Debug Code
        //TODO: Delete either all generalItems beloging to a game or use updates.
        
        //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gameId==%@", self.gameId];
        //    [GeneralItem MR_deleteAllMatchingPredicate: predicate];
        //    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        NSDictionary *generalItems = [response objectForKey:@"generalItems"];
        
        for (NSDictionary *generalItem in generalItems) {
            // [ARLUtils LogJsonDictionary:generalItem url:NULL];
            
            // @property (nonatomic, retain) NSString * descriptionText;                 fixup ( description, cannot rename field as descrition is reserved ).
            // @property (nonatomic, retain) NSNumber * gameId;                      mapped    ( same as ownerGame )?
            // @property (nonatomic, retain) NSNumber * generalItemId;                   fixup ( id).
            // @property (nonatomic, retain) NSData * json;                              fixup ( generalItem as json).
            // @property (nonatomic, retain) NSNumber * lat;                         mapped
            // @property (nonatomic, retain) NSNumber * lng;                         mapped
            // @property (nonatomic, retain) NSString * name;                        mapped
            // @property (nonatomic, retain) NSString * richText;                    mapped
            // @property (nonatomic, retain) NSNumber * sortKey;                         todo  ( ??? ).
            // @property (nonatomic, retain) NSString * type;                        mapped
            
            // @property (nonatomic, retain) NSSet *actions;                             todo  ( relation ).
            // @property (nonatomic, retain) NSSet *currentVisibility;                   todo  ( relation ).
            // @property (nonatomic, retain) NSSet *data;                                todo  ( relation ).
            // @property (nonatomic, retain) Game *ownerGame;                        manual    ( see gameId ).
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
                                        // Data,                                                    CoreData
                                        [NSKeyedArchiver archivedDataWithRootObject:generalItem],   @"json",
                                        nil];
            
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gameId==%@ && generalItemId==%@", self.gameId, [generalItem valueForKey:@"id"]];
            GeneralItem *generalitem = [GeneralItem MR_findFirstWithPredicate: predicate];
            
            //TODO: Handle Deleted Records.
            
            if (generalitem) {
                generalitem = (GeneralItem *)[ARLUtils UpdateManagedObjectFromDictionary:generalItem
                                                                           managedobject:generalitem
                                                                              nameFixups:namefixups
                                                                              dataFixups:datafixups];
                
            } else {
                // Uses MagicalRecord for Creation and Saving!
                generalitem = (GeneralItem *)[ARLUtils ManagedObjectFromDictionary:generalItem
                                                                        entityName:@"GeneralItem"
                                                                        nameFixups:namefixups
                                                                        dataFixups:datafixups];
            }
            
            //TEST: Test record deletion.
            //TODO: Find out what to do with linked records in other tables (like GeneralItemVisibility).
            if ([generalItem valueForKey:@"deleted"]) {
                [generalitem MR_deleteEntity];
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
        
        [NSTimer scheduledTimerWithTimeInterval:5.0
                                         target:self
                                       selector:@selector(splashDone:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

/*!
 *  Update after the splash screen period has elapsed.
 */
-(void)splashDone:(NSTimer *)timer {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
    
    [timer invalidate];
}

@end
