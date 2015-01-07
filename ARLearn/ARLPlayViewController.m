//
//  ARLPlayViewController.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 05/01/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#import "ARLPlayViewController.h"

@interface ARLPlayViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UITableView *generalItems;

@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSMutableDictionary *visibility;

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
@synthesize generalItems;

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
    
    self.items = [GeneralItem MR_findAllWithPredicate:predicate1];
    
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
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: self.cellIdentifier];
            
            GeneralItem *item = [self getGeneralItemForRow:indexPath.row];
            
            cell.textLabel.text = item.name;
            
            NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:item.json];
            
            // DLog(@"%@=%@",[item.generalItemId stringValue], [self.visibility valueForKey:[item.generalItemId stringValue]]);
            
            // if ([[self.visibility valueForKey:[item.generalItemId stringValue]] integerValue] == 1) {
            // cell.detailTextLabel.text = @"Visible";
            // } else {
            NSDictionary* dependsOn = [json valueForKey:@"dependsOn"];
            
            BeanIds bid = [ARLBeanNames beanTypeToBeanId:[dependsOn valueForKey:@"type"]];
            NSNumber *dependsOnItem = ( NSNumber *)[dependsOn valueForKey:@"generalItemId"];
            if (bid!=Invalid) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Depends on type: %d (%lld)", bid, [dependsOnItem longLongValue]];
            }
            
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

            BeanIds bid = [ARLBeanNames beanTypeToBeanId:self.activeItem.type];
            
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
                    
                    [self.generalItems setUserInteractionEnabled:NO];
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
    
    [self.generalItems setUserInteractionEnabled:YES];
    
    self.activeItem = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    DLog(@"audioPlayerDecodeErrorDidOccur");
    
    [self MarkActiveItemAsRead];
    
    [self UpdateItemVisibility];
    
    [self.generalItems setUserInteractionEnabled:YES];

    self.activeItem = nil;
}

#warning Interruption calls are all deprecated (should use the AVAUdioSession instead).

#pragma mark - Properties

-(NSString *) cellIdentifier {
    return  @"GeneralItem";
}

#pragma mark - Methods

/*!
 *  Mark the ActiveItem as Read.
 */
- (void)MarkActiveItemAsRead {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"run.runId=%@ AND generalItem.generalItemId=%@ AND action=%@",
                              self.runId, self.activeItem.generalItemId, @"read"];
    Action *action = [Action MR_findFirstWithPredicate:predicate];
    if (!action) {
        action = [Action MR_createEntity];
        action.action = @"read";
        action.generalItem = [GeneralItem MR_findFirstByAttribute:@"generalItemId" withValue:self.activeItem.generalItemId];
        action.run = [Run MR_findFirstByAttribute:@"runId" withValue:self.runId];

        // Saves any modification made after ManagedObjectFromDictionary.
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        DLog(@"Marked Generalitem %@ as '%@' for Run %@", self.activeItem.generalItemId, @"read", self.runId);
    }
}

/*!
 *  See http://stackoverflow.com/questions/16556905/filtering-nsdictionary-with-predicate
 *
 *  Complex code but it works filters the NSDictionary on Value and returns the matching key/value pairs as a new NSDictionary !
 *
 *  @return <#return value description#>
 */
- (NSDictionary *)getVisibleItems
{
    // Original Demo Code:
    //
    // NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
    //                       [NSArray arrayWithObjects:@"a", @"b", @"c", nil], @"a",
    //                       [NSArray arrayWithObjects:@"b", @"c", @"a", nil], @"b",
    //                       [NSArray arrayWithObjects:@"c", @"a", @"b", nil], @"c",
    //                       [NSArray arrayWithObjects:@"a", @"b", @"c", nil], @"d",
    //                       nil];
    //
    // NSPredicate *p = [NSPredicate predicateWithFormat:@"%@[SELF][0] == 'a'", d];
    // NSLog(@"%@", p);
    //
    // NSArray *keys = [d allKeys];
    // NSArray *filteredKeys = [keys filteredArrayUsingPredicate:p];
    // NSLog(@"%@", filteredKeys);
    //
    // NSDictionary *matchingDictionary = [d dictionaryWithValuesForKeys:filteredKeys];
    // NSLog(@"%@", matchingDictionary);
    
    // This line is tricky (at least the first %@):
    NSPredicate *p = [NSPredicate predicateWithFormat:@"%@[SELF] == %@", self.visibility, @(1)];

    NSArray *keys = [self.visibility allKeys];
    NSArray *filteredKeys = [keys filteredArrayUsingPredicate:p];
    
    // Extract the matching key/value pairs from the original NSDictionary.
    NSDictionary *matchingDictionary = [self.visibility dictionaryWithValuesForKeys:filteredKeys];
    
    return matchingDictionary;
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
    NSString *key = [[self.getVisibleItems allKeys] objectAtIndex:row];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %lld", @"generalItemId", [key longLongValue]];
    
    GeneralItem *item = (GeneralItem *)[[self.items filteredArrayUsingPredicate:predicate] firstObject];
    
    return item;
}

/*!
 *  Recalculate GeneralItem Visibility.
 */
- (void)UpdateItemVisibility {
    [self.generalItems setUserInteractionEnabled:NO];
    
    // Calculate the visibility based on DependsOn and Actins stored.
    self.visibility = [[NSMutableDictionary alloc] init];
    for (GeneralItem *item in self.items) {
        NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:item.json];
        
        NSNumber *visible = @(false);
        
        if ([json valueForKey:@"dependsOn"]) {
            NSDictionary *dependsOn = [json valueForKey:@"dependsOn"];
            
            switch ([ARLBeanNames beanTypeToBeanId:[dependsOn valueForKey:@"type"]]) {
                case ActionDependency: {
                    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:
                                               @"run.runId=%@ AND generalItem.generalItemId=%@ AND action=%@",
                                               self.runId, [dependsOn valueForKey:@"generalItemId"], [dependsOn valueForKey:@"action"]];
                    visible = [NSNumber numberWithBool:[Action MR_countOfEntitiesWithPredicate:predicate2] != 0];
                }
                    break;
                    
                default:
                    break;
            };
        } else {
            visible = @(true);
        }
        
        DLog(@"Adding %@=%@", [item.generalItemId stringValue], visible);
        [self.visibility setObject:visible forKey:[item.generalItemId stringValue]];
    }
    
    [self.generalItems setUserInteractionEnabled:YES];

    [self.generalItems reloadData];
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

@end
