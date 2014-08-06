//
//  ARLSearchViewController.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/16/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLSearchViewController.h"

@interface ARLSearchViewController ()

@property (strong, nonatomic) IBOutlet UITableView *table;

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSArray *searchResults;

@property (readonly, nonatomic) NSString *query;

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
    [self performQuery];
    [self.table reloadData];
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

/*!
 *  Just clear the stored data.
 */
- (void)didReceiveMemoryWarning
{
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
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                return [self.searchResults count];
            } else {
                return [self.results count];
            }
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
//        case SEARCH: {
//            UITableViewCell* headerCell = [tableView dequeueReusableCellWithIdentifier:self.headerIdentifier forIndexPath:indexPath];
//            
//            [headerCell layoutIfNeeded];
//            
//            self.searchField = (UITextField *)[headerCell.contentView viewWithTag:100];
//            self.searchButton = (UIButton *)[headerCell.contentView viewWithTag:200];
//            
//            //!!! Fix UITextField
//            {
//                self.searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
//                self.searchField.clearsOnBeginEditing = NO;
//                
//                [self.searchField setDelegate:self];
//                
//                [self.searchField addTarget:self
//                                     action:@selector(textFieldDidChange:)
//                           forControlEvents:UIControlEventEditingChanged];
//            }
//            
//            //!!! Fix UIButton
//            {
//                self.searchButton.titleLabel.text= NSLocalizedString(@"SearchButton", @"SearchButton");
//                
//                //Fixup - Somehow the frame is wrong (width not set).
//                self.searchButton.titleLabel.frame = CGRectMake(8.0, 0.0, self.searchButton.frame.size.width - 2*8.0, self.searchButton.frame.size.height);
//                self.searchButton.titleLabel.textColor = [UIColor whiteColor];
//                //        [self.searchButton setTitleColor:[UIColor whiteColor]
//                //                                forState:UIControlStateNormal];
//                
//                [self.searchButton addTarget:self
//                                      action:@selector(searchButtonAction:)
//                            forControlEvents:UIControlEventTouchUpInside];
//            }
//            
//            return headerCell;
//        }
            
        case RESULTS : {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                              reuseIdentifier:self.cellIdentifier];
            }
            
            NSDictionary *dict;
            
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                dict =  (NSDictionary *)[self.searchResults objectAtIndex:indexPath.row];
            } else {
                dict =  (NSDictionary *)[self.results objectAtIndex:indexPath.row];
            }
            
            cell.textLabel.text = [dict valueForKey:@"title"];
            
            if ([dict valueForKey:@"lng"] && [dict valueForKey:@"lat"]) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@] - lat:%@, lng:%@", [dict valueForKey:@"language"],[dict valueForKey:@"lat"],[dict valueForKey:@"lng"]];
            } else {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@]", [dict valueForKey:@"language"]];
            }
            cell.detailTextLabel.textColor = [UIColor grayColor];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.imageView.image = [UIImage imageNamed:@"MyGames"];
            
            cell.tag = [(NSNumber *)[dict valueForKey:@"gameId"] integerValue];
            
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:NO];

            return cell;
        }
    }

    // Shoudl not happen!!
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
//        case SEARCH : {
//            // return @"Search";
//            
//            break;
//        }
        case RESULTS : {
            UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameView"];
            
            if (newViewController) {
                // Move to another UINavigationController or UITabBarController etc.
                // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
                [self.navigationController pushViewController:newViewController animated:YES];
                
                break;
            }
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
//        case SEARCH : {
//            return @"Search";
//        }
        case RESULTS : {
            break;
        }
    }
    
    return @"";
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    switch (indexPath.section) {
//            
//        case SEARCH : {
//            return self.tableView.rowHeight + 4.0;
//        }
//            
//        case RESULTS: {
//            return self.tableView.rowHeight;
//        }
//    }
//    
//    // Shoudl not happen!!
//    return self.tableView.rowHeight;
//}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    switch (indexPath.section) {
//            
//        case SEARCH :
//            break;
//            
//        case RESULTS:
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            break;
//    }
//}

#pragma mark - UITextFieldDelegate

//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    DLog(@"Query: %@", self.query);
//
//    if ([_query length] != 0 && self.searchField) {
//        [self.tableView endEditing:YES];
//        [self.tableView reloadData];
//        
//        // Search on Return.
//        if (self.searchButton) {
//            [self searchButtonAction:self.searchButton];
//        }
//    }
//    
//    return [_query length] != 0;
//}

/*!
 *  Capture text entered as the Search Button Tap seems start before ending the edit session!
 *
 *  @param textField The UITextField
 */
-(void)textFieldDidChange :(UITextField *)textField{
     DLog(@"Query: %@", textField.text);
    
    _query = textField.text;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"Got HTTP Response");
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    NSLog(@"Got HTTP Data");
    
    // [ARLUtils LogJsonData:data url:[[[dataTask response] URL] absoluteString]];
    
    [self processData:data];
    
    [ARLQueryCache addQuery:dataTask.taskDescription withResponse:data];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSLog(@"Completed HTTP Task");
    
    if(error == nil)
    {
        // Update UI Here?
        NSLog(@"Download is Succesfull");
    } else {
        NSLog(@"Error %@",[error userInfo]);
    }
}
#pragma mark - UISearchDisplayController
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    //    (NSDictionary *)[self.searchResults objectAtIndex:indexPath.row];
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.results) {
        NSString *title =  [dict valueForKey:@"title"];
        
        if ([title rangeOfString:searchText options:NSCaseInsensitiveSearch].length!=0) {
            [matches addObject:dict];
        }
    }
    
    self.searchResults = matches;
    
    DLog(@"Filtered %d game(s)", self.searchResults.count);
    
    //    NSPredicate *resultPredicate = [NSPredicate
    //                                    predicateWithFormat:@"SELF g[cd] %@",
    //                                    searchText];
    //
    //    self.searchResults = [self.results filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - Actions

//- (IBAction)searchButtonAction:(id)sender {
//    DLog(@"Query: %@", self.query);
//    
//    [self performQuery];
//}

@end
