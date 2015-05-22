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

@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSMutableArray *visibility;

//@property (strong, nonatomic) AVAudioSession *audioSession;
//@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (strong, nonatomic) GeneralItem *activeItem;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender;

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, ARLPlayViewControllerGroups) {
    /*!
     *  Icon Item.
     */
    ICONITEM = 0,
    
    /*!
     *  General Item.
     */
    GENERALITEM = 1,

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

Class _class;

#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Setting a footer hides empty cels at the bottom.
    self.itemsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Do any additional setup after loading the view.
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"gameId=%@", self.gameId];
    
    self.items = [GeneralItem MR_findAllSortedBy:@"sortKey"
                                       ascending:YES
                                   withPredicate:predicate1];
    
    // Again Sort....
//        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sortKey" ascending:NO];
//        self.items = [self.items sortedArrayUsingDescriptors:@[sort]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncProgress:)
                                                 name:ARL_SYNCPROGRESS
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncReady:)
                                                 name:ARL_SYNCREADY
                                               object:nil];

    [self UpdateItemVisibility];
    [self.itemsTable reloadData];
    
    [ARLUtils setBackButton:self action:@selector(backButtonTapped:)];
    
    [self applyConstraints];
    
    DLog(@"Synchronizing runtime data");
    
    NSBlockOperation *backBO0 =[NSBlockOperation blockOperationWithBlock:^{
        [ARLSynchronisation PublishActionsToServer];
    }];
    
    NSBlockOperation *backBO1 =[NSBlockOperation blockOperationWithBlock:^{
        [ARLSynchronisation PublishResponsesToServer];
    }];
    
    NSBlockOperation *backBO2 =[NSBlockOperation blockOperationWithBlock:^{
        [ARLSynchronisation DownloadGeneralItemVisibilities:self.runId];
    }];
    
    NSBlockOperation *backBO3 =[NSBlockOperation blockOperationWithBlock:^{
        [ARLSynchronisation DownloadActions:self.runId];
    }];
    
    [backBO1 addDependency:backBO0];
    [backBO2 addDependency:backBO1];
    [backBO3 addDependency:backBO2];

    [[ARLAppDelegate theOQ] addOperation:backBO0];
    [[ARLAppDelegate theOQ] addOperation:backBO1];
    [[ARLAppDelegate theOQ] addOperation:backBO2];
    [[ARLAppDelegate theOQ] addOperation:backBO3];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // See http://stackoverflow.com/questions/16852227/how-to-add-pull-tableview-up-to-refresh-data-inside-the-uitableview
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    [self.itemsTable addSubview:self.refreshControl];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ARL_SYNCPROGRESS object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ARL_SYNCREADY object:nil];
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
    DLog(@"shouldPopItem");
    
    //insert your back button handling logic here
    // let the pop happen
    [ARLUtils popToViewControllerOnNavigationController:[ARLMyGamesViewController class]
                                   navigationController:self.navigationController
                                               animated:YES];
    
    return NO;
}

#pragma mark - UITableViewDelegate


#pragma mark - UITableViewDataSource

/*!
 *  The number of sections in a Table.
 *
 *  @param tableView The Table to be served.
 *
 *  @return The number of sections.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    return numARLPlayViewControllerGroups;
}

/*!
 *  Return the number of rows in a section of the Tavble.
 *
 *  @param tableView <#tableView description#>
 *  @param section   <#section description#>
 *
 *  @return <#return value description#>
 */
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case ICONITEM :
            return 1;
            
        case GENERALITEM :
            return [self getVisibleItems].count;
    }
    
    // Should not happen!!
    return 0;
}

/*!
 *  Return Title of Section. See http://stackoverflow.com/questions/9737616/uitableview-hide-header-from-empty-section
 *
 *  @param tableView <#tableView description#>
 *  @param section   <#section description#>
 *
 *  @return <#return value description#>
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section){
        case ICONITEM:
            return nil;
        case GENERALITEM:
            return nil;
    }
    
    // Error
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case ICONITEM: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier1
                                                                    forIndexPath:indexPath];
#pragma warn Update Game Icon here.
            // UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];

            return cell;
        }
            
        case GENERALITEM : {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier2
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
            cell.detailTextLabel.text = @"";
            
#warning TODO Different Icons for GeneralItem Types (match Android).
            
            cell.imageView.image = [UIImage imageNamed:@"task-explore"];
            
            // DLog(@"%@=%@",[item.generalItemId stringValue], [self.visibility valueForKey:[item.generalItemId stringValue]]);
            
            NSDictionary* dependsOn = [json valueForKey:@"dependsOn"];
            
            BeanIds bid = [ARLBeanNames beanTypeToBeanId:[dependsOn valueForKey:@"type"]];
           
            NSNumber *dependsOnItem = ( NSNumber *)[dependsOn valueForKey:@"generalItemId"];
            
            if (bid!=Invalid) {
                // cell.detailTextLabel.text = [NSString stringWithFormat:@"Depends on type: %d (%lld)", bid, [dependsOnItem longLongValue]];
            } else {
                bid = [ARLBeanNames beanTypeToBeanId:item.type];
                if (bid!=Invalid) {
                    // cell.detailTextLabel.text = [NSString stringWithFormat:@"Type: %@ (%lld)", [ARLBeanNames beanIdToBeanName:bid], [item.generalItemId longLongValue]];
                } else {
                    // cell.detailTextLabel.text = [ARLBeanNames beanIdToBeanName:bid];
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
        case ICONITEM:
            break;
            
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
                    //
                    ARLNarratorItemViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectedDataView"];
                    
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
                    ARLAudioPlayer *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectedDataView"]; //@"AudioPlayer"
                    
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
                    DLog("Unhandled GeneralItem type %@", [ARLBeanNames beanIdToBeanName:bid]);
                    break;
            }
            
            break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Log(@"heightForRowAtIndexPath %@",indexPath);
    
    CGFloat rh = tableView.rowHeight==-1 ? 44.0f : tableView.rowHeight;
    
    switch (indexPath.section) {
        case ICONITEM:
            return 2*rh;
        case GENERALITEM:
            return rh;
    }
    
    // Error
    return rh;
}

/*!
 *  Hide Section Headers (see http://stackoverflow.com/questions/9737616/uitableview-hide-header-from-empty-section)
 *
 *  @param tableView <#tableView description#>
 *  @param section   <#section description#>
 *
 *  @return <#return value description#>
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case ICONITEM:
            return nil;
        case GENERALITEM:
            return nil;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case ICONITEM:
            return 0.0f;
        case GENERALITEM:
            return 0.0f;
    }
    
    return 0.0f;
}

#pragma mark - Properties

-(NSString *) cellIdentifier1 {
    return  @"IconItem";
}

-(NSString *) cellIdentifier2 {
    return  @"GeneralItem";
}

- (void) setBackViewControllerClass:(Class)viewControllerClass{
    _class = viewControllerClass;
}

#pragma mark - Methods

- (void) applyConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,             @"view",
                                     
                                     self.backgroundImage,  @"backgroundImage",
                                     
                                     self.itemsTable,       @"itemsTable",
                                     
                                     nil];
    
    // See http://stackoverflow.com/questions/17772922/can-i-use-autolayout-to-provide-different-constraints-for-landscape-and-portrait
    // See https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/Bars.html
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.itemsTable.translatesAutoresizingMaskIntoConstraints = NO;
    // self.gameIcon.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    // Fix descriptionText Horizontal. FAILS ???
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.gameIcon
//                                                          attribute:NSLayoutAttributeCenterY
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.backgroundImage
//                                                          attribute:NSLayoutAttributeCenterY
//                                                         multiplier:1
//                                                           constant:0]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[itemsTable]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}

/*!
 *  Mark the ActiveItem as Read.
 */
- (void)MarkActiveItemAsRead {
    [ARLCoreDataUtils CreateOrUpdateAction:self.runId
                                activeItem:self.activeItem
                                      verb:read_action];
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
    
    DLog(@"Now: %@", [ARLUtils formatDateTime:[[NSNumber numberWithLongLong:now] stringValue]]);
    
    for (GeneralItem *item in self.items) {
        DLog(@"Examing GeneralItem: %@", item.name);
        
        NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:item.json];
        
        long long int satisfiedAt = 0l;
        
        if ([json valueForKey:@"dependsOn"]) {
            NSDictionary *dependsOn = [json valueForKey:@"dependsOn"];
            
            satisfiedAt = [self satisfiedAt:self.runId
                                  dependsOn:dependsOn
                                        ctx:ctx];

            DLog(@"SatisfiedAt: %@", [ARLUtils formatDateTime:[[NSNumber numberWithLongLong:satisfiedAt] stringValue]]);
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
                    
                    DLog(@"GeneralItem: %@ ('%@') created and status set to VISIBLE at %@", giv.generalItemId, giv.generalItem.name, giv.timeStamp);
                }
            } else {
                // update timestamp if not INVISIBLE.
                if (![giv.status isEqualToNumber:INVISIBLE] && [giv.timeStamp longLongValue] > satisfiedAt) {
                    giv.timeStamp = [NSNumber numberWithLongLong:satisfiedAt];
                    
                    [ctx MR_saveToPersistentStoreAndWait];
                    
                    DLog(@"GeneralItem: %@ ('%@') timestamp updated at %@", giv.generalItemId, giv.generalItem.name, giv.timeStamp);
                }
            }
            
            if ([giv.status isEqualToNumber:VISIBLE] && ![self.visibility containsObject:[item.generalItemId stringValue]]) {
                DLog("Adding %@ to Visibility", item.name);
                [self.visibility insertObject:[item.generalItemId stringValue] atIndex:0];
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

                    DLog(@"newValue: %@", [ARLUtils formatDateTime:[[NSNumber numberWithLongLong:newValue] stringValue]]);
                    DLog(@"minSatisfiedAt: %@", [ARLUtils formatDateTime:[[NSNumber numberWithLongLong:minSatisfiedAt] stringValue]]);
                    
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
                
                //#error this halts on the new test game
                //            {
                //                generalItemId = 5774370509160448;
                //                scope = 0;
                //                type = "org.celstec.arlearn2.beans.dependencies.ActionDependency";
                //            }
                
                NSDictionary *dep;
                
                if([deps isKindOfClass:[NSArray class]]){
                    //Is array
                    if ([deps count]==0) {
                        return -1;
                    }
                    dep =  (NSDictionary *)[deps firstObject];
                } else if([deps isKindOfClass:[NSDictionary class]]){
                    //is dictionary
                    dep = (NSDictionary *)deps;
                } else {
                    //is something else
                    EELog();
                }
                
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
            DLog(@"refresh calls UpdateItemVisibility");
            [ARLSynchronisation DownloadGeneralItemVisibilities:self.runId];
        }];
        
        NSBlockOperation *foreBO =[NSBlockOperation blockOperationWithBlock:^{
            [self UpdateItemVisibility];
        }];
        
        DLog(@"refresh schedules DownloadGeneralItemVisibilities");
        
        [foreBO addDependency:backBO0];
        
        [[NSOperationQueue mainQueue] addOperation:foreBO];
        
        [[ARLAppDelegate theOQ] addOperation:backBO0];
        
        [refreshControl endRefreshing];
    }
}

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender {
    // DLog(@"back button pressed");
    
    [ARLUtils popToViewControllerOnNavigationController:_class
                                   navigationController:self.navigationController
                                               animated:YES];
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
    
    DLog(@"syncProgress: %@", recordType);
    
    if ([NSStringFromClass([GeneralItem class]) isEqualToString:recordType]) {
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
    
    if ([NSStringFromClass([Action class]) isEqualToString:recordType]) {
        [self UpdateItemVisibility];
        
        [self.itemsTable reloadData];
    } else if ([NSStringFromClass([Response class]) isEqualToString:recordType]) {
        //[self UpdateItemVisibility];
        
        //[self.itemsTable reloadData];
    } else if ([NSStringFromClass([GeneralItemVisibility class]) isEqualToString:recordType]) {
        //[self UpdateItemVisibility];
        
        //[self.itemsTable reloadData];
    } else if ([NSStringFromClass([GeneralItem class]) isEqualToString:recordType]) {
//        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"gameId=%@", self.gameId];
//        
//        self.items = [GeneralItem MR_findAllSortedBy:@"sortKey"
//                                           ascending:NO
//                                       withPredicate:predicate1];
//        
//        // Again Sort....
//        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sortKey" ascending:NO];
//        self.items = [self.items sortedArrayUsingDescriptors:@[sort]];
//        
//        [self UpdateItemVisibility];
//        
//        [ARLUtils setBackButton:self action:@selector(backButtonTapped:)];
//        
//        if (self.descriptionText.isHidden) {
//            [self applyConstraints];
//        }
//        
//        [self.itemsTable reloadData];
    } else {
        DLog(@"syncReady, unhandled recordType: %@", recordType);
    }
}

@end
