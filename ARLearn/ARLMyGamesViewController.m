//
//  ARLMyGamesViewController.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/29/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLMyGamesViewController.h"

@interface ARLMyGamesViewController ()

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSArray *games;
@property (nonatomic, strong) NSPredicate *predicate;

@property (retain, nonatomic) NSMutableData *accumulatedData;
@property (nonatomic) long long accumulatedSize;

- (IBAction)backButtonAction:(UIBarButtonItem *)sender;

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, ARLMyGamesViewControllerGroups) {
    /*!
     *  My Games Results.
     */
    MYGAMES = 0,
    
    /*!
     *  Number of Groups
     */
    numARLMyGamesViewControllerGroups
};

@end

@implementation ARLMyGamesViewController

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
    
    DLog(@"MYGAMES");
    
    // Setting a footer hides empty cels at the bottom.
    self.table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]];
    
    self.table.dataSource = self;
    
    // _query = @"";
    self.predicate = [NSPredicate predicateWithFormat:@"correspondingRuns.@count!=%d",0];
    self.games = [Game MR_findAllWithPredicate:self.predicate];

    [self.table reloadData];
    
    //[self.refreshControl addTarget:self
    //                        action:@selector(refresh:)
      //            forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
    
    if ([ARLNetworking networkAvailable]) {
        [self performQuery1];
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
    // Clear Results backing fields to trigger a reload.
    _results = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Properties

/*!
 *  Getter
 *
 *  @return The Cell Identifier.
 */
-(NSString *) cellIdentifier {
    return  @"aMyGamesResults";
}

#pragma mark - Methods

- (void)processData:(NSData *)data
{
    //Example Data:
    
    //{
    // "type": "org.celstec.arlearn2.beans.game.GamesList",
    // "games": [
    //           {
    //               "type": "org.celstec.arlearn2.beans.game.Game",
    //               "gameId": 27766001,
    //               "title": "Heerlen game met Mark",
    //               "config": {
    //                   "type": "org.celstec.arlearn2.beans.game.Config",
    //                   "mapAvailable": false,
    //                   "manualItems": [],
    //                   "locationUpdates": []
    //               },
    //               "lng": 5.958768,
    //               "lat": 50.878495,
    //               "language": "en"
    //           },
    //           ]
    //}
    
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
    
    NSDictionary *json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    BeanIds bid = [ARLBeanNames beanTypeToBeanId:[json valueForKey:@"type"]];
    
    switch (bid) {
        case GameList: {
            self.results = (NSArray *)[json objectForKey:@"games"];
            
            for (NSDictionary *dict in self.results) {
                [ARLCoreDataUtils processGameDictionaryItem:dict ctx:ctx];
            }
            
            [ctx MR_saveToPersistentStoreAndWait];
            
            // Chain myRuns/participate.
            //
            if ([ARLNetworking networkAvailable]) {
                [self performQuery2];
            }
        }
            break;
            
        case RunList: {
            NSDictionary *runs = [json objectForKey:@"runs"];
            
            for (NSDictionary *dict in runs) {
                [ARLCoreDataUtils processRunDictionaryItem:dict ctx:ctx];
            }
            
            [ctx MR_saveToPersistentStoreAndWait];
            
            [self.table setUserInteractionEnabled:NO];
            {
                self.games = [Game MR_findAll];
                
                [self.table reloadData];
            }
            [self.table setUserInteractionEnabled:YES];
            
            Log(@"Games and Runs Updates");
        }
            break;
            
        default:
            break;
    }
}

/*!
 *  Won't work off-line.
 */
- (void)performQuery1 {
    NSString *cacheIdentifier = [ARLNetworking generateGetDescription:@"myGames/participate"];
    
    NSData *response = [[ARLAppDelegate theQueryCache] getResponse:cacheIdentifier];
    
    if (!response) {
        [ARLNetworking sendHTTPGetWithDelegate:self withService:@"myGames/participate"];
    } else {
        DLog(@"Using cached query data");
        [self processData:response];
    }
}

/*!
 *  Won't work off-line.
 */
- (void)performQuery2 {
    NSString *cacheIdentifier = [ARLNetworking generateGetDescription:@"myRuns/participate"];
    
    NSData *response = [[ARLAppDelegate theQueryCache] getResponse:cacheIdentifier];
    
    if (!response) {
        [ARLNetworking sendHTTPGetWithDelegate:self withService:@"myRuns/participate"];
    } else {
        DLog(@"Using cached query data");
        [self processData:response];
    }
}

/*!
 *  Refresh (and Reload) the Table.
 *
 *  @param sender
 */
- (void)refresh:(id)sender
{
    DLog(@"Refreshing");
    
#warning Won't work off-line.
    
    // Reload cached data.
    if ([ARLNetworking networkAvailable]) {
        [self performQuery1];
    }
    
    // End Refreshing
    [(UIRefreshControl *)sender endRefreshing];
}

#pragma mark - TabelViewController

/*!
 *  Number of Sections of the Table.
 *
 *  @param tableView The TableView
 *
 *  @return The number of Groups.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return numARLMyGamesViewControllerGroups;
}

/*!
 *  Number of Tabel Rows in a Section.
 *
 *  @param tableView The TableView
 *  @param section   The Section
 *
 *  @return The number of Rows in the Section.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case MYGAMES : {
            return [self.games count];
        }
    }
    
    // Should not happen.
    return 0;
}

/*!
 *  Get the Cell for a particular Section and Row.
 *
 *  @param tableView The TableView
 *  @param indexPath The Row Requested.
 *
 *  @return The UITableViewCell for the requested Row.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case MYGAMES: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                                    forIndexPath:indexPath];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:self.cellIdentifier];
            }
            
            Game *game = [self.games objectAtIndex:indexPath.row];
            
            //NSDictionary *dict =  (NSDictionary *)[self.results objectAtIndex:indexPath.row];
            cell.textLabel.text = game.title; //[dict valueForKey:@"title"];
            
//            if (game.:@"lng"] && [dict valueForKey:@"lat"]) {
//                cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@] - lat:%@, lng:%@", [dict valueForKey:@"language"],[dict valueForKey:@"lat"],[dict valueForKey:@"lng"]];
//            } else {
//                cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@]", [dict valueForKey:@"language"]];
//            }
    
            cell.detailTextLabel.textColor = [UIColor grayColor];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.imageView.image = [UIImage imageNamed:@"MyGames"];
            
            return cell;
        }
    }
    
    // Shoudl not happen!!
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
        case MYGAMES: {
            Game *game = (Game *)[self.games objectAtIndex:indexPath.row]; // kNSDictionary *dict =  (NSDictionary *)[self.results objectAtIndex:indexPath.row];
            
            ARLDownloadViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameView"];
            
            if (newViewController) {
                newViewController.gameId = game.gameId;
                
                Run *run = [Run MR_findFirstByAttribute:@"gameId"
                                              withValue:game.gameId];
                
                if (run) {
                    // ARLGameViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameView"];
                    //
                    //            if (newViewController) {
                    //                NSDictionary *dict =  (NSDictionary *)[self.results objectAtIndex:indexPath.row];
                    //
                    //                newViewController.gameId = (NSNumber *)[dict valueForKey:@"gameId"];
                    //
                    //                // Move to another UINavigationController or UITabBarController etc.
                    //                // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
                    //                [self.navigationController pushViewController:newViewController animated:NO];
                    //            }
                    
                    Log(@"Selected Run: %@ for Game: %@", run.runId, game.gameId);
                    newViewController.runId = run.runId;
                }
                
                [newViewController setBackViewControllerClass:[self class]];
                
                // Move to another UINavigationController or UITabBarController etc.
                // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
                [self.navigationController pushViewController:newViewController animated:YES];
                
                newViewController = nil;
            }
            break;
        }
    }
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
    
    // DLog(@"Got HTTP Response [%d], expect %lld byte(s)", [httpResponse statusCode], self.accumulatedSize);
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    // DLog(@"Got HTTP Data, %d of %lld byte(s)", [data length], self.accumulatedSize);
    
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
    // DLog(@"Completed HTTP Task");
    
    if (error == nil)
    {
        [self processData:self.accumulatedData];
        
        [ARLQueryCache addQuery:task.taskDescription withResponse:self.accumulatedData];
        
        // Update UI Here?
        // DLog(@"Download is Succesfull");
    } else {
        ELog(error);
    }
    
    // Invalidate Session
    [session finishTasksAndInvalidate];
}

#pragma mark Actions

- (IBAction)backButtonAction:(UIBarButtonItem *)sender {
    UIViewController *newViewController;
    
#warning this seems wrong as there is no counterpart of presentViewController (i.e. dismissViewControllerAnimated) used here.
    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RootNavigationController"];
    
    if (newViewController) {
        // Move to another UINavigationController or UITabBarController etc.
        // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
        [self.navigationController presentViewController:newViewController animated:NO completion:nil];
        
        newViewController = nil;
        }
}

@end
