//
//  ARLPlayViewController.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 05/01/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#import "ARLPlayViewController.h"

@interface ARLPlayViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UITableView *itemsTable;
@property (weak, nonatomic) IBOutlet UIWebView *descriptionText;

@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSMutableArray *visibility;

@property (strong, nonatomic) AVAudioSession *audioSession;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (strong, nonatomic) GeneralItem *activeItem;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender;

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, ARLPlayViewControllerGroups) {
    /*!
     *  General Item.
     */
    GENERALITEM = 0,
    
    /*!
     *  Number of Groups
     */
    numARLPlayViewControllerGroups
};

@end

@implementation ARLPlayViewController

@synthesize gameId;
@synthesize runId;
@synthesize items;

#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Setting a footer hides empty cels at the bottom.
    self.itemsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // The ContentSize of the UIWebView will only grow so start small.
    CGRect newBounds =  self.descriptionText.bounds;
    newBounds.size.height = 10;
    self.descriptionText.bounds = newBounds;
    
    self.descriptionText.delegate = self;
    
    Game *game= [Game MR_findFirstByAttribute:@"gameId" withValue:self.gameId];
    
    if (game && TrimmedStringLength(game.richTextDescription) != 0) {
        self.descriptionText.hidden = NO;
        [self.descriptionText loadHTMLString:game.richTextDescription baseURL:nil];
    } else {
        self.descriptionText.hidden = YES;
    }
    
    // Do any additional setup after loading the view.
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"gameId=%@", self.gameId];
    
    self.items = [GeneralItem MR_findAllSortedBy:@"sortKey"
                                       ascending:NO
                                   withPredicate:predicate1];
    
    // Again Sort....
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sortKey" ascending:NO];
    self.items = [self.items sortedArrayUsingDescriptors:@[sort]];
    
    [self UpdateItemVisibility];
    
    // See http://www.raywenderlich.com/69369/audio-tutorial-ios-playing-audio-programatically-2014-edition
    self.audioSession = [AVAudioSession sharedInstance];
    
    // See handy chart on pg. 46 of the Audio Session Programming Guide for what the categories mean
    // Not absolutely required in this example, but good to get into the habit of doing
    // See pg. 10 of Audio Session Programming Guide for "Why a Default Session Usually Isn't What You Want"
    
    NSError *error = nil;
    
    //    if ([self.audioSession isOtherAudioPlaying]) {
    //        // mix sound effects with music already playing
    //        [self.audioSession setCategory:AVAudioSessionCategorySoloAmbient error:&error];
    //    } else {
    //        [self.audioSession setCategory:AVAudioSessionCategoryAmbient error:&error];
    //    }
    
    [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAudioSessionEvent:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:[AVAudioSession sharedInstance]];
    
    ELog(error);
    
    [ARLUtils setBackButton:self action:@selector(backButtonTapped:)];
    
    if (self.descriptionText.isHidden) {
        [self applyConstraints];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // See http://stackoverflow.com/questions/16852227/how-to-add-pull-tableview-up-to-refresh-data-inside-the-uitableview
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.itemsTable addSubview:self.refreshControl];
    
    NSBlockOperation *backBO0 =[NSBlockOperation blockOperationWithBlock:^{
        [self DownloadgeneralItemVisibilities];
    }];
    
    [[ARLAppDelegate theOQ] addOperation:backBO0];
}

-(void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
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

#pragma mark - UINavigationControllerDelegate

- (BOOL)navigationBar:(UINavigationBar *)navigationBar
        shouldPopItem:(UINavigationItem *)item
{
    Log(@"shouldPopItem");
    
    //insert your back button handling logic here
    // let the pop happen
    [ARLUtils popToViewControllerOnNavigationController:[ARLGameViewController class]
                                   navigationController:self.navigationController
                                               animated:YES];
    
    return NO;
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case GENERALITEM : {
            return [self getVisibleItems].count;
        }
    }
    
    // Should not happen!!
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case GENERALITEM : {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                                    forIndexPath:indexPath];
            
            GeneralItem *item = [self getGeneralItemForRow:indexPath.row];
            
            NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:item.json];
            
            NSPredicate *predicate2 = [NSPredicate predicateWithFormat:
                                       @"run.runId=%@ AND generalItem.generalItemId=%@ AND action=%@",
                                       self.runId,
                                       item.generalItemId,
                                       read_action];
            
            NSString *text = item.name;
           
            if ([Action MR_countOfEntitiesWithPredicate:predicate2] != 0) {
                 cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                 cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            // [NSString stringWithFormat:@"%@ %@", ([Action MR_countOfEntitiesWithPredicate:predicate2] != 0)? checkBoxEnabledChecked:emptySpace, item.name];
            
            cell.textLabel.text = text;
            
            // DLog(@"%@=%@",[item.generalItemId stringValue], [self.visibility valueForKey:[item.generalItemId stringValue]]);
            
            NSDictionary* dependsOn = [json valueForKey:@"dependsOn"];
            
            BeanIds bid = [ARLBeanNames beanTypeToBeanId:[dependsOn valueForKey:@"type"]];
           
            NSNumber *dependsOnItem = ( NSNumber *)[dependsOn valueForKey:@"generalItemId"];
            
            if (bid!=Invalid) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Depends on type: %d (%lld)", bid, [dependsOnItem longLongValue]];
            } else {
                bid = [ARLBeanNames beanTypeToBeanId:item.type];
                if (bid!=Invalid) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Type: %@ (%lld)", [ARLBeanNames beanIdToBeanName:bid], [item.generalItemId longLongValue]];
                } else {
                    cell.detailTextLabel.text = [ARLBeanNames beanIdToBeanName:bid];
                }
            }
            
            // See http://stackoverflow.com/questions/12296904/accessorybuttontappedforrowwithindexpath-not-getting-called
            // workaround for accessoryButtonTappedForRowWithIndexPath
            // UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            // set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
            // [button addTarget:self
            //            action:@selector(checkButtonTapped:event:)
            //  forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
    }
    
    // Should not happen!!
    return nil;
}

/*!
 *  Tap on table Row
 *
 *  @param tableView <#tableView description#>
 *  @param indexPath <#indexPath description#>
 */
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    switch (indexPath.section) {
        case GENERALITEM: {
            self.activeItem = [self getGeneralItemForRow:indexPath.row];

            [ARLCoreDataUtils CreateOrUpdateAction:self.runId
                                        activeItem:self.activeItem
                                              verb:read_action];

            // NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:self.activeItem.json];
            // [ARLUtils LogJsonDictionary:json url:nil];
            
            BeanIds bid = [ARLBeanNames beanTypeToBeanId:self.activeItem.type];
            
            switch (bid) {
                    // Contains Text + Choice.
                case SingleChoiceTest:
                case MultipleChoiceTest: {
                    ARLGeneralItemViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GeneralItemView"];
                    
                    if (newViewController) {
                        newViewController.runId = self.runId;
                        newViewController.activeItem  = self.activeItem;
                        
                        // Move to another UINavigationController or UITabBarController etc.
                        // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
                        [self.navigationController pushViewController:newViewController animated:YES];
                        
                        newViewController = nil;
                    }
                }
                    break;
                    
                    // Contains Text + openQuestion (or nothing).
                case NarratorItem:
                {
                    // if ([json valueForKey:@"openQuestion"]) {
                    ARLGeneralItemViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectedDataView"];
                    
                    if (newViewController) {
                        newViewController.runId = self.runId;
                        newViewController.activeItem  = self.activeItem;
                        
                        // Move to another UINavigationController or UITabBarController etc.
                        // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
                        [self.navigationController pushViewController:newViewController animated:YES];
                        
                        newViewController = nil;
                    }
                    
                }
                    break;
                    
                    // Contains Audio + openQuestion (or nothing).
                case AudioObject:
                {
                    ARLAudioPlayer *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioPlayer"];
                    
                    if (newViewController) {
                        newViewController.runId = self.runId;
                        newViewController.activeItem  = self.activeItem;
                        
                        // Move to another UINavigationController or UITabBarController etc.
                        // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
                        [self.navigationController pushViewController:newViewController animated:YES];
                        
                        newViewController = nil;
                    }
                }
                    break;
                    
                default:
                    //Should not happen
                    Log("Unhandled GeneralItem type %@", [ARLBeanNames beanIdToBeanName:bid]);
                    break;
            }
            
            break;
        }
    }
    
    [self UpdateItemVisibility];
    
    // TODO Find a better spot to publish actions (and make it a NSOperation)!
    [self PublishActionsToServer];
    
    // TODO Find a better spot to sync visibility (and make it a NSOperation)!
    [self DownloadgeneralItemVisibilities];
}

#pragma mark - UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    CGRect newBounds = webView.bounds;
    newBounds.size.height = webView.scrollView.contentSize.height;
    webView.bounds = newBounds;
    
    [self applyConstraints];
}

#pragma mark - Properties

-(NSString *) cellIdentifier {
    return  @"GeneralItem";
}

#pragma mark - Methods

- (void) applyConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,             @"view",
                                     
                                     self.backgroundImage,  @"backgroundImage",
                                     
                                     self.itemsTable,       @"itemsTable",
                                     self.descriptionText,  @"descriptionText",
                                     
                                     nil];
    
    // See http://stackoverflow.com/questions/17772922/can-i-use-autolayout-to-provide-different-constraints-for-landscape-and-portrait
    // See https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/Bars.html
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.itemsTable.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionText.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Fix Background.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    // Fix itemsTable Horizontal.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[itemsTable]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    // Fix descriptionText Horizontal.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[descriptionText]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    // Fix itemsTable/descriptionText Vertically.
    if (self.descriptionText.isHidden) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[itemsTable]-|"
                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-[descriptionText(==%f)]-[itemsTable]-|",
                                                                                   self.descriptionText.bounds.size.height]
                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
    }
}

/*!
 *  Mark the ActiveItem as Read.
 */
- (void)MarkActiveItemAsRead {
    [ARLCoreDataUtils CreateOrUpdateAction:self.runId
                                activeItem:self.activeItem
                                      verb:read_action];
        
    // TODO Find a better spot to publish actions (and make it a NSOperation)!
    [self PublishActionsToServer];
    
    // TODO Find a better spot to sync visibility (and make it a NSOperation)!
    [self DownloadgeneralItemVisibilities];
}

/*!
 *  Post all unsynced Actions to the server.
 */
- (void)PublishActionsToServer {
    
    // TODO Filter on runId too?
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"synchronized=%@", @NO];
    
    for (Action *action in [Action MR_findAllWithPredicate:predicate]) {
        NSString *userEmail = [NSString stringWithFormat:@"%@:%@", action.account.accountType, action.account.localId];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              action.action,                        @"action",
                              action.run.runId,                     @"runId",
                              action.generalItem.generalItemId,     @"generalItemId",
                              userEmail,                            @"userEmail",
                              action.time,                          @"time",
                              action.generalItem.type,              @"generalItemType",
                              nil];
        
        [ARLNetworking sendHTTPPostWithAuthorization:@"actions" json:dict];
        
        action.synchronized = [NSNumber numberWithBool:YES];
    }
    
    // Saves any modification made after ManagedObjectFromDictionary.
    [[NSManagedObjectContext MR_context] MR_saveToPersistentStoreAndWait];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

/*!
 *  Retrieve GeneralItemVisibility records from the server.
 *
 *  Runs in a background thread.
 */
-(void)DownloadgeneralItemVisibilities {
    
    // TODO Add TimeStamp to url retrieve less records?
    
    NSString *service = [NSString stringWithFormat:@"generalItemsVisibility/runId/%lld", [self.runId longLongValue]];
    
    NSData *data = [ARLNetworking sendHTTPGetWithAuthorization:service];
    
    NSError *error = nil;
    NSDictionary *response = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                      error:&error] : nil;
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
    
    if (error == nil) {
        // [ARLUtils LogJsonDictionary:response url:[ARLNetworking MakeRestUrl:service]];
        
        for (NSDictionary *item in [response valueForKey:@"generalItemsVisibility"])
        {
            // DLog(@"GeneralItem: %lld has Status %@,", [[item valueForKey:@"generalItemId"] longLongValue], [item valueForKey:@"status"]);
            
            //{
            //    "type": "org.celstec.arlearn2.beans.run.GeneralItemVisibilityList",
            //    "serverTime": 1421237978494,
            //    "generalItemsVisibility": [
            //                               {
            //                                   "type": "org.celstec.arlearn2.beans.run.GeneralItemVisibility",
            //                                   "runId": 4977978815545344,
            //                                   "deleted": false,
            //                                   "lastModificationDate": 1417533139703,
            //                                   "timeStamp": 1417533139537,
            //                                   "status": 1,
            //                                   "email": "2:103021572104496509774",
            //                                   "generalItemId": 6180497885495296
            //                               },
            //                               {
            //                                   "type": "org.celstec.arlearn2.beans.run.GeneralItemVisibility",
            //                                   "runId": 4977978815545344,
            //                                   "deleted": false,
            //                                   "lastModificationDate": 1421237415947,
            //                                   "timeStamp": 1421237414637,
            //                                   "status": 1,
            //                                   "email": "2:103021572104496509774",
            //                                   "generalItemId": 5232076227870720
            //                               }
            //                               ]
            //}
            
            //            @dynamic email;                   mapped
            //            @dynamic generalItemId;           mapped
            //            @dynamic runId;                   mapped
            //            @dynamic status;                  mapped
            //            @dynamic timeStamp;               mapped
            
            //            @dynamic correspondingRun;        manual
            //            @dynamic generalItem;             manual
            
            // Check if a record is already present.
            //
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"generalItemId=%lld AND runId=%lld",
                                      [[item valueForKey:@"generalItemId"] longLongValue],
                                      [self.runId longLongValue]];
            
            GeneralItemVisibility *giv = [GeneralItemVisibility MR_findFirstWithPredicate:predicate
                                                                                inContext:ctx];
            
            if (giv == nil) {
                
                // Create a new Record.
                //
                giv = (GeneralItemVisibility *)[ARLUtils ManagedObjectFromDictionary:item
                                                                          entityName:[GeneralItemVisibility MR_entityName] // @"GeneralItemVisibility"
                                                                      managedContext:ctx];
                
                giv.correspondingRun = [Run MR_findFirstByAttribute:@"runId"
                                                          withValue:giv.runId
                                                          inContext:ctx];
                
                giv.generalItem = [GeneralItem MR_findFirstByAttribute:@"generalItemId"
                                                             withValue:giv.generalItemId
                                                             inContext:ctx];
                
                Log(@"Created GeneralItemVisibility for %@ ('%@') with status %@", giv.generalItemId, giv.generalItem.name, giv.status);
            } else {
                if (!giv.correspondingRun) {
                    giv.correspondingRun = [Run MR_findFirstByAttribute:@"runId"
                                                              withValue:giv.runId
                                                              inContext:ctx];
                }
                if (!giv.generalItem) {
                    giv.generalItem = [GeneralItem MR_findFirstByAttribute:@"generalItemId"
                                                                 withValue:giv.generalItemId
                                                                 inContext:ctx];
                }
                // Only update when visibility status is still smaller then 2.
                //
                if (! [giv.status isEqualToNumber:[NSNumber numberWithInt:2]]) {
                    giv.status = [item valueForKey:@"status"];
                    giv.timeStamp = [item valueForKey:@"timeStamp"];
                    
                    Log(@"Updated GeneralItemVisibility of %@ ('%@') to status %@", giv.generalItemId, giv.generalItem.name, giv.status);
                }
                
                [ctx MR_saveToPersistentStoreAndWait];
            }
        }
    }
    
    // Saves any modification made after ManagedObjectFromDictionary.
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [self performSelectorOnMainThread:@selector(UpdateItemVisibility) withObject:nil waitUntilDone:YES];
    
    // ¥[self.itemsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

/*!
 *  See http://stackoverflow.com/questions/16556905/filtering-nsdictionary-with-predicate
 *
 *  Complex code but it works filters the NSDictionary on Value and returns the matching key/value pairs as a new NSDictionary !
 *
 *  @return <#return value description#>
 */
- (NSArray *)getVisibleItems
{
    return self.visibility;
}

/*!
 *  Get the (Visible) GeneralItem belonging to a TableView Row.
 *
 *  @param row <#row description#>
 *
 *  @return <#return value description#>
 */
- (GeneralItem *)getGeneralItemForRow:(NSInteger)row
{
    // Get the GeneralItem matching the key from self.getVisibleItems for this row.
    NSString *key = [self.getVisibleItems objectAtIndex:row];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %lld", @"generalItemId", [key longLongValue]];
    
    GeneralItem *item = (GeneralItem *)[[self.items filteredArrayUsingPredicate:predicate] firstObject];
    
    return item;
}

/*!
 *  Re-calculate the GeneralItem Vsibility for all GeneralIems.
 *
 *  Runs in a background thread.
 */
- (void)UpdateItemVisibility {
    [self.itemsTable setUserInteractionEnabled:NO];
    
    self.visibility = [[NSMutableArray alloc] init];
    
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
    
    long long int now = [ARLUtils Now];
    
    Log(@"Now: %@", [ARLUtils formatDateTime:[[NSNumber numberWithLongLong:now] stringValue]]);
    
    for (GeneralItem *item in self.items) {
        NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:item.json];
        
        long long int satisfiedAt = 0l;
        
        if ([json valueForKey:@"dependsOn"]) {
            NSDictionary *dependsOn = [json valueForKey:@"dependsOn"];
            
            satisfiedAt = [self satisfiedAt:self.runId
                                  dependsOn:dependsOn
                                        ctx:ctx];

            Log(@"SatisfiedAt: %@", [ARLUtils formatDateTime:[[NSNumber numberWithLongLong:satisfiedAt] stringValue]]);
        }
        
        if (satisfiedAt<now && satisfiedAt != -1)
        {
            // Create GeneralItemVisibility if missing;
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                      @"runId=%@ AND generalItemId=%@",
                                      self.runId,
                                      item.generalItemId];
            GeneralItemVisibility *giv = [GeneralItemVisibility MR_findFirstWithPredicate:predicate
                                                                                inContext:ctx];
            
            if (!giv)
            {
                // if not exists, create one and save it.
                giv = [GeneralItemVisibility MR_createEntityInContext:ctx];
                {
                    giv.generalItemId = item.generalItemId;
                    giv.runId = self.runId;
                    giv.status = VISIBLE;
                    giv.timeStamp = [NSNumber numberWithLongLong:satisfiedAt];
                    giv.email = [[ARLNetworking CurrentAccount] email];
                    giv.correspondingRun = [Run MR_findFirstByAttribute:@"runId"
                                                              withValue:self.runId
                                                              inContext:ctx];
                    giv.generalItem = [item MR_inContext:ctx];
                    
                    [ctx MR_saveToPersistentStoreAndWait];
                    
                    Log(@"GeneralItem: %@ ('%@') created and status set to VISIBLE at %@", giv.generalItemId, giv.generalItem.name, giv.timeStamp);
                }
            } else {
                // update timestamp if not INVISIBLE.
                if (![giv.status isEqualToNumber:INVISIBLE] && [giv.timeStamp longLongValue] > satisfiedAt) {
                    giv.timeStamp = [NSNumber numberWithLongLong:satisfiedAt];
                    
                    [ctx MR_saveToPersistentStoreAndWait];
                    
                    Log(@"GeneralItem: %@ ('%@') timestamp updated at %@", giv.generalItemId, giv.generalItem.name, giv.timeStamp);
                }
            }
            
            if ([giv.status isEqualToNumber:VISIBLE] && ![self.visibility containsObject:[item.generalItemId stringValue]]) {
                [self.visibility addObject:[item.generalItemId stringValue]];
            }
        }
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [self.itemsTable setUserInteractionEnabled:YES];
    
    [self.itemsTable reloadData];
    
    // See http://stackoverflow.com/questions/724892/uitableview-scroll-to-the-top
    [self.itemsTable setContentOffset:CGPointZero animated:YES];
}

/*!
 *  Calulates the time a dependsOn is satisfied (ie becomes visible).
 *
 *  @param forRunId  The id of the current Run.
 *  @param dependsOn A NSDictionary containing the dependsOn data.
 *
 *  @return <#return value description#>
 */
-(unsigned long long int)satisfiedAt:(NSNumber *)forRunId
                           dependsOn:(NSDictionary *)dependsOn
                                 ctx:(NSManagedObjectContext *)ctx{
    if (dependsOn!=nil)
    {
        // DLog(@"Checking satisfiedAt for %@ = %@",
        //     [dependsOn valueForKey:@"generalItemId"],
        //,     [dependsOn valueForKey:@"action"])
        switch ([ARLBeanNames beanTypeToBeanId:[dependsOn valueForKey:@"type"]]) {
            case ActionDependency: {
                // See Android's DependencyLocalObject:actionSatisfiedAt
                long long int minSatisfiedAt = LLONG_MAX;
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                          @"run.runId=%@ AND generalItem.generalItemId=%@ AND action=%@",
                                          forRunId,
                                          [dependsOn valueForKey:@"generalItemId"],
                                          [dependsOn valueForKey:@"action"]];
                
                for (Action *action in [Action MR_findAllWithPredicate:predicate
                                                             inContext:ctx]) {
                    //TODO Some strange (safety)checks are missing here.
                    long long int newValue = action.time ? [action.time longLongValue]: 0l;
                    
                    minSatisfiedAt = MIN(minSatisfiedAt, newValue);

                    Log(@"newValue: %@", [ARLUtils formatDateTime:[[NSNumber numberWithLongLong:newValue] stringValue]]);
                    Log(@"minSatisfiedAt: %@", [ARLUtils formatDateTime:[[NSNumber numberWithLongLong:minSatisfiedAt] stringValue]]);
                    
                }
                
                return minSatisfiedAt;
            }
                
            case ProximityDependency: {
                // See Android's DependencyLocalObject:proximitySatisfiedAt
                long long int minSatisfiedAt = LLONG_MIN;
                
                NSString *lat = [NSString stringWithFormat:@"%f",
                                 (double)((long)([[dependsOn valueForKey:@"lat"] doubleValue]*1e6)/1e6)];
                NSString *lng = [NSString stringWithFormat:@"%f",
                                 (double)((long)([[dependsOn valueForKey:@"lng"] doubleValue]*1e6)/1e6)];
                
                NSString *rad = [[dependsOn valueForKey:@"radius"] stringValue];
                
                NSString *geo = [NSString stringWithFormat:@"geo:%@:%@:%@", lat,lng,rad];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                          @"run.runId=%@ AND action=%@",
                                          forRunId,
                                          geo];
                
                for (Action *action in [Action MR_findAllWithPredicate:predicate
                                                             inContext:ctx]) {
                    if ([geo isEqualToString:action.action]) {
                        long long int newValue = action.time ? 0l : [action.time longLongValue];
                        
                        minSatisfiedAt = MIN(minSatisfiedAt, newValue);
                    }
                }

#pragma warning is LLONG_MAX here correct?
                
                return minSatisfiedAt == LLONG_MAX ? -1 : minSatisfiedAt;
            }
                
            case TimeDependency: {
                // See Android's DependencyLocalObject:timeSatisfiedAt
                NSArray *deps = [dependsOn valueForKey:@"offset"];
                
                if ([deps count]==0) {
                    return -1;
                }
                
                //#error this halts on the new test game
                //            {
                //                generalItemId = 5774370509160448;
                //                scope = 0;
                //                type = "org.celstec.arlearn2.beans.dependencies.ActionDependency";
                //            }
                
                NSDictionary *dep = (NSDictionary *)[deps firstObject];
                
                long long int satisfiedAt = [self satisfiedAt:forRunId
                                                    dependsOn:dep
                                                          ctx:ctx];
                
                return satisfiedAt == -1 ? -1 : satisfiedAt + [[dependsOn valueForKey:@"timeDelta"] longLongValue];
            }
                
            case OrDependency: {
                // See Android's DependencyLocalObject:orSatisfiedAt
                long long int minSatisfiedAt = LLONG_MAX;
                
                NSArray *deps = [dependsOn valueForKey:@"dependencies"];
                for (NSDictionary *dep in deps) {
                    long long int locmin = [self satisfiedAt:forRunId
                                                   dependsOn:dep
                                                         ctx:ctx];
                    if (locmin != -1) {
                        minSatisfiedAt = MIN(minSatisfiedAt, locmin);
                    }
                }
                
                return minSatisfiedAt == LLONG_MAX ? -1 : minSatisfiedAt;
            }
                
            case AndDependency: {
                // See Android's DependencyLocalObject:andSatisfiedAt
                long long int maxSatisfiedAt = 0;
                
                NSArray *deps = [dependsOn valueForKey:@"dependencies"];
                for (NSDictionary *dep in deps) {
                    long long int locmax = [self satisfiedAt:forRunId
                                                   dependsOn:dep
                                                         ctx:ctx];
                    
                    if (locmax == -1) {
                        return locmax;
                    } else {
                        maxSatisfiedAt = MAX(maxSatisfiedAt, locmax);
                    }
                }
                
                return maxSatisfiedAt;
            }
                
            default: {
                //Should not happen.
            }
                break;
        }
    }
    
    return -1;
}

#pragma mark - Actions

- (void)refresh:(UIRefreshControl *)refreshControl
{
    if (self.refreshControl && !self.refreshControl.isRefreshing) {
        NSBlockOperation *backBO0 =[NSBlockOperation blockOperationWithBlock:^{
            Log(@"refresh calls UpdateItemVisibility");
            [self DownloadgeneralItemVisibilities];
        }];
        
        NSBlockOperation *foreBO =[NSBlockOperation blockOperationWithBlock:^{
            [self UpdateItemVisibility];
        }];
        
        Log(@"refresh schedules DownloadgeneralItemVisibilities");
        
        [foreBO addDependency:backBO0];
        
        [[NSOperationQueue mainQueue] addOperation:foreBO];
        
        [[ARLAppDelegate theOQ] addOperation:backBO0];
        
        [refreshControl endRefreshing];
    }
}

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender {
    // Log(@"back button pressed");
    
    [ARLUtils popToViewControllerOnNavigationController:[ARLGameViewController class]
                                   navigationController:self.navigationController
                                               animated:YES];
}

#pragma mark - Events

/*!
 *  Notification Messages from AVAudioSession.
 *
 *  @param notification
 */
- (void) onAudioSessionEvent: (NSNotification *) notification {
    
    // See http://stackoverflow.com/questions/22400345/playing-music-at-back-ground-avaudiosessioninterruptionnotification-not-fired
    
    DLog(@"onAudioSessionEvent:%@", notification.description);
}

//- (void)checkButtonTapped:(id)sender event:(id)event{
//    NSSet *touches = [event allTouches];
//    UITouch *touch = [touches anyObject];
//
//    CGPoint currentTouchPosition = [touch locationInView:self.itemsTable];
//
//    NSIndexPath *indexPath = [self.itemsTable indexPathForRowAtPoint: currentTouchPosition];
//    if (indexPath != nil) {
//       Log("Disclosure Tapped %@", indexPath);
//    }
//}

@end
