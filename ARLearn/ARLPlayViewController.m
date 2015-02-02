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
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;

@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSMutableArray *visibility;

@property (strong, nonatomic) AVAudioSession *audioSession;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) GeneralItem *activeItem;

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
    
    //#warning Debug Code ahead
    //    {
    //        Action *action = [Action MR_createEntity];
    //        action.action = @"read";
    //        action.generalItem = [GeneralItem MR_findFirstByAttribute:@"generalItemId" withValue:@(5232076227870720)];
    //        action.run = [Run MR_findFirstByAttribute:@"runId" withValue:self.runId];
    //    }
    //
    //    // Saves any modification made after ManagedObjectFromDictionary.
    //    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
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
    
    [self applyConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSBlockOperation *backBO0 =[NSBlockOperation blockOperationWithBlock:^{
        [self DownloadgeneralItemVisibilities];
    }];

    [[ARLAppDelegate theOQ] addOperation:backBO0];
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
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: self.cellIdentifier  forIndexPath:indexPath];
            
            GeneralItem *item = [self getGeneralItemForRow:indexPath.row];
            
            NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:item.json];
            
            NSPredicate *predicate2 = [NSPredicate predicateWithFormat:
                                       @"run.runId=%@ AND generalItem.generalItemId=%@ AND action=%@",
                                       self.runId,
                                       item.generalItemId,
                                       @"read"];
            
            NSString *text = [NSString stringWithFormat:@"%@ %@", ([Action MR_countOfEntitiesWithPredicate:predicate2] != 0)? checkBoxEnabledChecked:emptySpace, item.name];
            
            cell.textLabel.text = text;
            
            // DLog(@"%@=%@",[item.generalItemId stringValue], [self.visibility valueForKey:[item.generalItemId stringValue]]);
            
            // if ([[self.visibility valueForKey:[item.generalItemId stringValue]] integerValue] == 1) {
            // cell.detailTextLabel.text = @"Visible";
            // } else {
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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    // Probably not called as we use UITableViewCellAccesssoryDisclosureIndicator instead of UITableViewCellAccessoryDetailDisclosureButton
 
    // See https://github.com/bitmapdata/MSCellAccessory/blob/master/MSCellAccessory/MSCellAccessory.m
    
    Log("Disclosure Tapped %@", indexPath);
    
    GeneralItem *item = [self getGeneralItemForRow:indexPath.row];
    
    BeanIds bid = [ARLBeanNames beanTypeToBeanId:item.type];
    
    switch (bid) {
        case SingleChoiceTest:
        case MultipleChoiceTest: {
            ARLGeneralItemViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GeneralItemView"];
            
            if (newViewController) {
                newViewController.activeItem  = item;
                
                // Move to another UINavigationController or UITabBarController etc.
                // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
                [self.navigationController pushViewController:newViewController animated:YES];
                
                newViewController = nil;
            }
        }
            
        case ScanTag:
            // Nothing yet
            break;
            
        case OpenQuestion:
            // Nothing yet
            break;
            
        default:
            //Should not happen
            Log("Unhandled GeneralItem type %@", [ARLBeanNames beanIdToBeanName:bid]);
            break;
    }
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

            if (self.activeItem) {
                self.descriptionText.attributedText = [ARLUtils htmlToAttributedString:self.activeItem.richText];
            } else {
                self.descriptionText.text = @"No Description.";
            }
            
            BeanIds bid = [ARLBeanNames beanTypeToBeanId:self.activeItem.type];
            
#warning this code should move to the view handling a single GeneralItem!
            
            switch (bid) {
                case AudioObject:
                {
                    NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:self.activeItem.json];
                    
                    NSString *audioFeed = [json valueForKey:@"audioFeed"];
                    
                    NSRange index = [audioFeed rangeOfString:[self.activeItem.gameId stringValue]];
                    
                    NSString *path = [audioFeed substringFromIndex:index.location + index.length];
                    
                    NSString *audioFile = [ARLUtils GenerateResourceFileName:self.activeItem.gameId
                                                                        path:path];
                    
                    NSURL *audioUrl = [[NSURL alloc] initFileURLWithPath:audioFile];
                    
                    // See http://stackoverflow.com/questions/1973902/play-mp3-files-with-iphone-sdk
                    // See http://www.raywenderlich.com/69369/audio-tutorial-ios-playing-audio-programatically-2014-edition
                    // See http://stackoverflow.com/questions/9683547/avaudioplayer-throws-breakpoint-in-debug-mode
                    NSError *error;
                    self.audioPlayer = [[AVAudioPlayer alloc]
                                        initWithContentsOfURL:audioUrl
                                        error:&error];
                    [self.audioPlayer setDelegate:self];
                    [self.audioPlayer prepareToPlay];
                    [self.audioPlayer play];
                    
                    [self.itemsTable setUserInteractionEnabled:NO];
                }
                    break;
                    
                default:
                    break;
            }

            break;
        }
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    DLog(@"audioPlayerDidFinishPlaying");

    [self MarkActiveItemAsRead];
    
    [self UpdateItemVisibility];
    
    [self.itemsTable setUserInteractionEnabled:YES];
    
    self.activeItem = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    DLog(@"audioPlayerDecodeErrorDidOccur");
    
    [self MarkActiveItemAsRead];
    
    [self UpdateItemVisibility];
    
    [self.itemsTable setUserInteractionEnabled:YES];

    self.activeItem = nil;
}

#warning Interruption calls are all deprecated (should use the AVAUdioSession instead).

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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[descriptionText(==200)]-[itemsTable]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}

/*!
 *  Mark the ActiveItem as Read.
 */
- (void)MarkActiveItemAsRead {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"run.runId=%@ AND generalItem.generalItemId=%@ AND action=%@",
                              self.runId, self.activeItem.generalItemId, @"read"];
    Action *action = [Action MR_findFirstWithPredicate:predicate];
    
    if (!action) {
        action = [Action MR_createEntity];
        {
            action.account = [ARLNetworking CurrentAccount];
            action.action = @"read";
            action.generalItem = [GeneralItem MR_findFirstByAttribute:@"generalItemId" withValue:self.activeItem.generalItemId];
            action.run = [Run MR_findFirstByAttribute:@"runId" withValue:self.runId];
            action.synchronized = [NSNumber numberWithBool:NO];
            action.time = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
        }
        
        // Saves any modification made after ManagedObjectFromDictionary.
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

        
        DLog(@"Marked Generalitem %@ as '%@' for Run %@", self.activeItem.generalItemId, @"read", self.runId);
    } else {
        DLog(@"Generalitem %@ for Run %@ is already marked as %@", self.activeItem.generalItemId, self.runId, @"read");
    }
    
    // TODO Find a better spot to publish actions (and make it a NSOperation)!
    [self PublishActionsToServer];
    
    // TODO Find a better spot to sync visibility (and make it a NSOperation)!
    [self DownloadgeneralItemVisibilities];
}

/*!
 *  Post all unsynced Actions to the server.
 */
-(void)PublishActionsToServer {
    
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
    
    if (error == nil) {
        [ARLUtils LogJsonDictionary:response url:[ARLNetworking MakeRestUrl:service]];
        
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
            
            GeneralItemVisibility *giv = [GeneralItemVisibility MR_findFirstWithPredicate:predicate];
            
            if (giv == nil) {
                
                // Create a new Record.
                //
                giv = (GeneralItemVisibility *)[ARLUtils ManagedObjectFromDictionary:item
                                                                          entityName:@"GeneralItemVisibility"];
                
                [giv MR_inContext:[NSManagedObjectContext MR_defaultContext]].correspondingRun = [Run MR_findFirstByAttribute:@"runId"
                                                                                                                    withValue:giv.runId
                                                                                                                    inContext:[NSManagedObjectContext MR_defaultContext]];
                
                [giv MR_inContext:[NSManagedObjectContext MR_defaultContext]].generalItem = [GeneralItem MR_findFirstByAttribute:@"generalItemId"
                                                                                                                       withValue:giv.generalItemId
                                                                                                                       inContext:[NSManagedObjectContext MR_defaultContext]];
  
                Log(@"Created GeneralItemVisibility for %@ ('%@') with status %@", giv.generalItemId, giv.generalItem.name, giv.status);
            } else {
                
                // Only update when visibility status is still smaller then 2.
                //
                if (! [giv.status isEqualToNumber:[NSNumber numberWithInt:2]]) {
                    giv.status = [item valueForKey:@"status"];
                    giv.timeStamp = [item valueForKey:@"timeStamp"];
                    
                    Log(@"Updated GeneralItemVisibility of %@ ('%@') to status %@", giv.generalItemId, giv.generalItem.name, giv.status);
                }
            }
        }
    }
    
    // Saves any modification made after ManagedObjectFromDictionary.
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [self.itemsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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

- (void)UpdateItemVisibility {
    [self.itemsTable setUserInteractionEnabled:NO];

    self.visibility = [[NSMutableArray alloc] init];
    
    for (GeneralItem *item in self.items) {
        NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:item.json];
        
        long satisfiedAt = 0l;
        
        if ([json valueForKey:@"dependsOn"]) {
            NSDictionary *dependsOn = [json valueForKey:@"dependsOn"];
        
            satisfiedAt = [self satisfiedAt:self.runId dependsOn:dependsOn];
        }
    
        if (satisfiedAt<[ARLUtils Now] && satisfiedAt != -1)
        {
            // Create GeneralItemVisibility if missing;
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                      @"runId=%@ AND generalItemId=%@",
                                      self.runId,
                                      item.generalItemId];
            GeneralItemVisibility *giv = [GeneralItemVisibility MR_findFirstWithPredicate:predicate];
            
            if (!giv)
            {
                // if not exists, create one and save it.
                giv = [GeneralItemVisibility MR_createEntity];
                {
                    giv.generalItemId = item.generalItemId;
                    giv.runId = self.runId;
                    giv.status = VISIBLE;
                    giv.timeStamp = [NSNumber numberWithLong:satisfiedAt];
                    giv.email = [[ARLNetworking CurrentAccount] email];
                    giv.correspondingRun = [Run MR_findFirstByAttribute:@"runId" withValue:self.runId];
                    giv.generalItem = item;
                    
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

                    Log(@"GeneralItem: %@ ('%@') status set to VISIBLE at %@", giv.generalItemId, giv.generalItem.name, giv.timeStamp);
                }
            } else {
                // update timestamp if not INVISIBLE.
                if (![giv.status isEqualToNumber:INVISIBLE] && [giv.timeStamp longValue] > satisfiedAt) {
                    giv.timeStamp = [NSNumber numberWithLong:satisfiedAt];
                    
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

                    Log(@"GeneralItem: %@ ('%@') updated at %@", giv.generalItemId, giv.generalItem.name, giv.timeStamp);
                }
            }
            
            if ([giv.status isEqualToNumber:VISIBLE] && ![self.visibility containsObject:[item.generalItemId stringValue]]) {
                [self.visibility addObject:[item.generalItemId stringValue]];
            }
        }
    }

    [self.itemsTable setUserInteractionEnabled:YES];
    
    [self.itemsTable reloadData];
    
    // See http://stackoverflow.com/questions/724892/uitableview-scroll-to-the-top
    [self.itemsTable setContentOffset:CGPointZero animated:YES];
}

-(long)satisfiedAt:(NSNumber *)forRunId dependsOn:(NSDictionary *)dependsOn {
    if (dependsOn!=nil)
    {
        switch ([ARLBeanNames beanTypeToBeanId:[dependsOn valueForKey:@"type"]]) {
            case ActionDependency: {
                // See Android's DependencyLocalObject:actionSatisfiedAt
                long minSatisfiedAt = LONG_MAX;
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                          @"run.runId=%@ AND generalItem.generalItemId=%@ AND action=%@",
                                          forRunId,
                                          [dependsOn valueForKey:@"generalItemId"],
                                          [dependsOn valueForKey:@"action"]];
                
                for (Action *action in [Action MR_findAllWithPredicate:predicate]) {
                    //TODO Some strange (safety)checks are missing here.
                    long newValue = action.time ? 0l : [action.time longValue];
                    
                    minSatisfiedAt = MIN(minSatisfiedAt, newValue);
                }
                
                return minSatisfiedAt;
            }
                
            case ProximityDependency: {
                // See Android's DependencyLocalObject:proximitySatisfiedAt
                long minSatisfiedAt = LONG_MAX;
                
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
                
                for (Action *action in [Action MR_findAllWithPredicate:predicate]) {
                    if ([geo isEqualToString:action.action]) {
                        long newValue = action.time ? 0l : [action.time longValue];
                        
                        minSatisfiedAt = MIN(minSatisfiedAt, newValue);
                    }
                }
                
                return minSatisfiedAt == LONG_MAX ? -1 : minSatisfiedAt;
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
                
                long satisfiedAt = [self satisfiedAt:forRunId dependsOn:dep];
                
                return satisfiedAt == -1 ? -1 : satisfiedAt + [[dependsOn valueForKey:@"timeDelta"] longValue];
            }
                
            case OrDependency: {
                // See Android's DependencyLocalObject:orSatisfiedAt
                long minSatisfiedAt = LONG_MAX;
                
                NSArray *deps = [dependsOn valueForKey:@"dependencies"];
                for (NSDictionary *dep in deps) {
                    long locmin = [self satisfiedAt:forRunId dependsOn:dep];
                    if (locmin != -1) {
                        minSatisfiedAt = MIN(minSatisfiedAt, locmin);
                    }
                }
                
                return minSatisfiedAt == LONG_MAX ? -1 : minSatisfiedAt;
            }
                
            case AndDependency: {
                // See Android's DependencyLocalObject:andSatisfiedAt
                long maxSatisfiedAt = 0;
                
                NSArray *deps = [dependsOn valueForKey:@"dependencies"];
                for (NSDictionary *dep in deps) {
                    long locmax = [self satisfiedAt:forRunId dependsOn:dep];
                    
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

#pragma mark - Events 

/*!
 *  Notification Messages from AVAudioSession.
 *
 *  @param notification <#notification description#>
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
