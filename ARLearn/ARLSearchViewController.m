//
//  ARLSearchViewController.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/16/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLSearchViewController.h"

@interface ARLSearchViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *table;

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSArray *searchResults;

@property (readonly, nonatomic) NSString *query;

@property (retain, nonatomic) NSMutableData *accumulatedData;
@property (nonatomic) long long accumulatedSize;

#define livesearch

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, ARLSearchViewControllerGroups) {
    /*!
     *  Search Results.
     */
    RESULTS = 0,
   
    /*!
     *  Number of Groups
     */
    numARLSearchViewControllerGroups
};

@end

@implementation ARLSearchViewController

@synthesize results = _results;
@synthesize searchResults = _searchResults;
@synthesize query = _query;

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
    
    // Setting a footer hides empty cels at the bottom.
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

	// Do any additional setup after loading the view, typically from a nib.
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]];
    
    // IB self.table.dataSource = self;
    
    // _query = @"";
    
    [self.table reloadData];
    
    // To Dismiss keyboard on tap ouside searchField.
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
    //                                   initWithTarget:self
    //                                   action:@selector(dismissKeyboard)];
    
    //[self.tableView addGestureRecognizer:tap];

    [self.refreshControl addTarget:self
                            action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
}

-(void) viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    
#ifndef livesearch
    [self performQuery];

    [self filterContentForSearchText:self.searchBar.text
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    [self.table reloadData];
#endif //livesearch
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //
}

/*!
 *  Just clear the stored data.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
    // Clear Results backing fields to trigger a reload.
    _results = nil;
}

#pragma mark - Properties

/*!
 *  Getter
 *
 *  @return The Cell Identifier.
 */
-(NSString *) cellIdentifier {
    return  @"aSearchResults";
}

/*!
 *  Getter
 *
 *  @return The Header Identifier.
 */
-(NSString *) headerIdentifier {
    return  @"aSearchHeader";
}

#pragma mark - Methods

//-(void)dismissKeyboard {
//    if (self.searchField) {
//        [self.tableView endEditing:YES];
//        [self.tableView reloadData];
//    }
//}

- (void)performQuery {
    NSString *cacheIdentifier = [ARLNetworking generatePostDescription:@"myGames/search" withBody:(self.query ? self.query : @"")];
    
    NSData *response = [[ARLAppDelegate theQueryCache] getResponse:cacheIdentifier];
    
    if (!response) {
        [ARLNetworking sendHTTPPostWithDelegate:self withService:@"myGames/search" withBody:(self.query ? self.query : @"")];
    } else {
        NSLog(@"Using cached query data");
        [self processData:response];
    }
}

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
    
    NSDictionary *json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    self.results = (NSArray *)[json objectForKey:@"games"];
    
    self.searchResults = self.results;
    
    DLog(@"Retrieved %d game(s)", self.results.count);
    
    [self.table reloadData];
}

/*!
 *  Refresh (and Reload) the Table.
 *
 *  @param sender
 */
- (void)refresh:(id)sender
{
    NSLog(@"Refreshing");
    
    // Reload cached data.
    [self performQuery];
    
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
    return numARLSearchViewControllerGroups;
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
        case RESULTS : {
            return [self.searchResults count];
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
        case RESULTS : {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                                    forIndexPath:indexPath];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                              reuseIdentifier:self.cellIdentifier];
            }
            
            NSDictionary *dict =  (NSDictionary *)[self.searchResults objectAtIndex:indexPath.row];
            
            cell.textLabel.text = [dict valueForKey:@"title"];
            
            if ([dict valueForKey:@"lng"] && [dict valueForKey:@"lat"]) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@] - lat:%@, lng:%@", [dict valueForKey:@"language"],[dict valueForKey:@"lat"],[dict valueForKey:@"lng"]];
            } else {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@]", [dict valueForKey:@"language"]];
            }
            cell.detailTextLabel.textColor = [UIColor grayColor];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.imageView.image = [UIImage imageNamed:@"MyGames"];
            
            return cell;
        }
    }

    // Should not happen!!
    return nil;
}

/*!
 *  Tap on table Row
 *
 *  @param tableView r
 *  @param indexPath <#indexPath description#>
 */
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    switch (indexPath.section) {
        case RESULTS : {
            ARLGameViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameView"];
            
            if (newViewController) {
                NSDictionary *dict =  (NSDictionary *)[self.searchResults objectAtIndex:indexPath.row];
                
                newViewController.gameId = (NSNumber *)[dict valueForKey:@"gameId"];
                
                // Move to another UINavigationController or UITabBarController etc.
                // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
                [self.navigationController pushViewController:newViewController animated:YES];
            }
            break;
        }
    }
}

/*!
 *  Tap on row accessory
 *
 *  @param tableView <#tableView description#>
 *  @param indexPath <#indexPath description#>
 */
- (void) tableView: (UITableView *) tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *) indexPath {
    DLog(@"");
    
    //TODO
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case RESULTS : {
            return @"Search results";
        }
    }
    
    return @"";
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    
    self.accumulatedSize = [response expectedContentLength];
    self.accumulatedData = [[NSMutableData alloc]init];
    
    NSLog(@"Got HTTP Response [%d], expect %lld byte(s)", [httpResponse statusCode], self.accumulatedSize);
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    NSLog(@"Got HTTP Data, %d of %lld byte(s)", [data length], self.accumulatedSize);
    
    // [ARLUtils LogJsonData:data url:[[[dataTask response] URL] absoluteString]];
    
    [self.accumulatedData appendData:data];
    
    if ([self.accumulatedData length]==self.accumulatedSize) {
        // [self processData:data];
        //    if ([self.results count] > 0) {
        //        [ARLQueryCache addQuery:dataTask.taskDescription withResponse:data];
        //    } else {
        //        DLog(@"Query %@",dataTask.taskDescription)
        //    }
    }
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSLog(@"Completed HTTP Task");
    
    if (error == nil)
    {
        [self processData:self.accumulatedData];
        
        //        if ([self.results count] > 0) {
        [ARLQueryCache addQuery:task.taskDescription withResponse:self.accumulatedData];
        //        } else {
        //            DLog(@"Query %@",task.taskDescription)
        //        }
        
        // Update UI Here?
        NSLog(@"Download is Succesfull");
    } else {
        NSLog(@"Error %@",[error userInfo]);
    }
    
    // Invalidate Session
    [session finishTasksAndInvalidate];}

#pragma mark - UISearchBar

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    // Do not set self.query here as it will result in another hot to the server and we're looking locally!
    NSString *search = [searchText stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];;
    
    if ([search length] > 0) {
#ifdef livesearch
#else
        NSMutableArray *matches = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in self.results) {
            NSString *title = [dict valueForKey:@"title"];
            
            if ([title rangeOfString:search options:NSCaseInsensitiveSearch].length!=0) {
                [matches addObject:dict];
            }
        }
        
        self.searchResults = [NSArray arrayWithArray:matches];
#endif //livesearch
    } else {
        
#ifdef livesearch
#else
        self.searchResults = [NSArray arrayWithArray:self.results];
#endif //livesearch
    }
    
    DLog(@"Filtered %d game(s)", self.searchResults.count);
    
    //    NSPredicate *resultPredicate = [NSPredicate
    //                                    predicateWithFormat:@"SELF g[cd] %@",
    //                                    searchText];
    //
    //    self.searchResults = [self.results filteredArrayUsingPredicate:resultPredicate];
    
    [self.table reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
#ifndef livesearch
    [self filterContentForSearchText:searchText
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
#endif //livesearch
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    DLog(@"Cancel clicked");
    
    searchBar.text = self.query;
    
#ifdef livesearch
//  _query = searchBar.text;
//  self.searchResults = [[NSArray alloc] init];
#else
    [self filterContentForSearchText:searchBar.text
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
#endif //livesearch
    
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    DLog(@"Search Clicked");

#ifdef livesearch
    _query = searchBar.text;

    [self performQuery];
#else
    [self filterContentForSearchText:searchBar.text
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
#endif //livesearch
    [searchBar resignFirstResponder];
}

#pragma mark - Actions

@end
