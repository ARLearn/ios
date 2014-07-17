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

@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (readonly, nonatomic) NSString *cellIdentifier;
@property (readonly, nonatomic) NSString *headerIdentifier;

@property (nonatomic, strong) NSArray *results;

@property (readonly, nonatomic) NSString *query;

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, ARLSearchViewControllerGroups) {
    /*!
     *  Search Form.
     */
    SEARCH = 0,
   
    /*!
     *  Search Results.
     */
    RESULTS = 1,
    
    /*!
     *  Number of Groups
     */
    numARLSearchViewControllerGroups
};


@end

@implementation ARLSearchViewController

@synthesize results = _results;
@synthesize query = _query;

#pragma mark - ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]];
    
    self.table.dataSource = self;
    
    // _query = @"";
    
    [self.table reloadData];
    
    // To Dismiss keyboard on tap ouside searchField.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.tableView addGestureRecognizer:tap];
    
    // [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

/*!
 *  Just clear the stored data.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
    // Clear Persons backing fields to trigger a reload.
    _results = nil;
}

#pragma mark - Properties

/*!
 *  Getter
 *
 *  @return The Cell Identifier.
 */
-(NSString *) cellIdentifier {
    return  @"aSearchResult";
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

-(void)dismissKeyboard {
    if (self.searchField) {
        [self.tableView endEditing:YES];
        [self.tableView reloadData];
    }
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
        case SEARCH : {
            return 1;
        }
        
        case RESULTS : {
            return [self.results count];
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
        case SEARCH: {
            UITableViewCell* headerCell = [tableView dequeueReusableCellWithIdentifier:@"aSearchHeader" forIndexPath:indexPath];
            
            [headerCell layoutIfNeeded];
            
            self.searchField = (UITextField *)[headerCell.contentView viewWithTag:100];
            self.searchButton = (UIButton *)[headerCell.contentView viewWithTag:200];
            // self.searchLabel = (UILabel *)[headerCell.contentView viewWithTag:300];
            
            //        ((UIButton *)[headerCell.contentView viewWithTag:200]).titleLabel.text = @"Search";
            //        ((UIButton *)[headerCell.contentView viewWithTag:200]).titleLabel.textColor = [UIColor redColor];
            //        [((UIButton *)[headerCell.contentView viewWithTag:200]) setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            //        [((UIButton *)[headerCell.contentView viewWithTag:200]) setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            
            //!!! Fix UITextField
            {
                self.searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
                self.searchField.clearsOnBeginEditing = NO;
                
                [self.searchField setDelegate:self];
                
                [self.searchField addTarget:self
                                     action:@selector(textFieldDidChange:)
                           forControlEvents:UIControlEventEditingChanged];
            }
            
            //!!! Fix UIButton
            {
                self.searchButton.titleLabel.text= NSLocalizedString(@"SearchButton", @"SearchButton");
                
                //Fixup - Somehow the frame is wrong (width not set).
                self.searchButton.titleLabel.frame = CGRectMake(8.0, 0.0, self.searchButton.frame.size.width - 2*8.0, self.searchButton.frame.size.height);
                self.searchButton.titleLabel.textColor = [UIColor whiteColor];
                //        [self.searchButton setTitleColor:[UIColor whiteColor]
                //                                forState:UIControlStateNormal];
                
                [self.searchButton addTarget:self
                                      action:@selector(searchButtonAction:)
                            forControlEvents:UIControlEventTouchUpInside];
            }
            
            return headerCell;
        }
            
        case RESULTS : {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                                    forIndexPath:indexPath];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
            }
            
            NSDictionary *dict =  (NSDictionary *)[self.results objectAtIndex:indexPath.row];
            cell.textLabel.text = [dict valueForKey:@"title"];
            
            if ([dict valueForKey:@"lng"] && [dict valueForKey:@"lat"]) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@] - lat:%@, lng:%@", [dict valueForKey:@"language"],[dict valueForKey:@"lat"],[dict valueForKey:@"lng"]];
            } else {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@]", [dict valueForKey:@"language"]];
            }
            cell.detailTextLabel.textColor = [UIColor grayColor];
            
            //!!! Save the GameId inside the UITableCell.
            //            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            //            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            //            [[nf numberFromString:[dict valueForKey:@"gameId"]] integerValue];
            
            cell.tag = [(NSNumber *)[dict valueForKey:@"gameId"] integerValue];

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
    //TODO
}

/*!
 *  Tap on row accessory
 *
 *  @param tableView <#tableView description#>
 *  @param indexPath <#indexPath description#>
 */
- (void) tableView: (UITableView *) tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *) indexPath {
    //TODO
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SEARCH : {
            return @"Search";
        }
        case RESULTS : {
            break;
        }
    }
    
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
            
        case SEARCH : {
            return self.tableView.rowHeight + 4.0;
        }
            
        case RESULTS: {
            return self.tableView.rowHeight;
        }
    }
    
    // Shoudl not happen!!
    return self.tableView.rowHeight;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    switch (section) {
//            
//        case RESULTS : {
//            return 64.0;
//        }
//    }
//    
//    // Default value.
//    return self.tableView.rowHeight;
//}

//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    // 1. Dequeue the custom header cell
//    UITableViewCell* headerCell = [tableView dequeueReusableCellWithIdentifier:@"aSearchHeader"];
//    
//    [headerCell layoutIfNeeded];
//    
//    self.searchField = (UITextField *)[headerCell.contentView viewWithTag:100];
//    self.searchButton = (UIButton *)[headerCell.contentView viewWithTag:200];
//    // self.searchLabel = (UILabel *)[headerCell.contentView viewWithTag:300];
//    
//    //        ((UIButton *)[headerCell.contentView viewWithTag:200]).titleLabel.text = @"Search";
//    //        ((UIButton *)[headerCell.contentView viewWithTag:200]).titleLabel.textColor = [UIColor redColor];
//    //        [((UIButton *)[headerCell.contentView viewWithTag:200]) setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
//    //        [((UIButton *)[headerCell.contentView viewWithTag:200]) setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    
//    //!!! Fix UITextField
//    {
//        self.searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        self.searchField.clearsOnBeginEditing = NO;
//        
//        [self.searchField setDelegate:self];
//        
//        [self.searchField addTarget:self
//                             action:@selector(textFieldDidChange:)
//                   forControlEvents:UIControlEventEditingChanged];
//    }
//    
//    //!!! Fix UIButton
//    {
//        DLog(@"Title %@", self.searchButton.titleLabel.text);
//        self.searchButton.titleLabel.text= NSLocalizedString(@"SearchButton", @"SearchButton");
//
//        //Fixup - Somehow the frame is wrong (width not set).
//        self.searchButton.titleLabel.frame = CGRectMake(8.0, 0.0, self.searchButton.frame.size.width - 2*8.0, self.searchButton.frame.size.height);
//        self.searchButton.titleLabel.textColor = [UIColor whiteColor];
////        [self.searchButton setTitleColor:[UIColor whiteColor]
////                                forState:UIControlStateNormal];
//        
//        [self.searchButton addTarget:self
//                              action:@selector(searchButtonAction:)
//                    forControlEvents:UIControlEventTouchUpInside];
//    }
//    
//    return headerCell;
//}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DLog(@"Query: %@", self.query);

    if ([_query length] != 0 && self.searchField) {
        [self.tableView endEditing:YES];
        [self.tableView reloadData];
        
        // Search on Return.
        if (self.searchButton) {
            [self searchButtonAction:self.searchButton];
        }
    }
    
    return [_query length] != 0;
}

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
    
    //NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // NSLog(@"Received String %@",str);
    
    NSDictionary *json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    // NSLog(@"%@", json);
    
    self.results = (NSArray *)[json objectForKey:@"games"];
    
    [self.table reloadData];

    //Game *game = (Game *)[ARLUtils ManagedObjectFromDictionary:data entityName:@"Game"]; // nameFixups:fixups
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
    }
    else
        NSLog(@"Error %@",[error userInfo]);
}

#pragma mark - Actions

- (IBAction)searchButtonAction:(id)sender {
    DLog(@"Query: %@", self.query);
    
    [ARLNetworking sendHTTPPostWithDelegate:self withBody:(self.query ? self.query : @"")];
}

@end
