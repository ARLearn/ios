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
@synthesize query = _query;

#pragma mark - ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    self.table.dataSource = self;
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                            forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
    }
    
    switch (indexPath.section) {
            
        case RESULTS : {
            NSDictionary *dict =  (NSDictionary *)[self.results objectAtIndex:indexPath.row];
            cell.textLabel.text = [dict valueForKey:@"title"];
        }
    }

    return cell;
}

/*!
 *  Tap on table Row
 *
 *  @param tableView <#tableView description#>
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
            
        case RESULTS : {
            return 64.0;
        }
    }
    
    // Default value.
    return 22.0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 1. Dequeue the custom header cell
    UITableViewCell* headerCell = [tableView dequeueReusableCellWithIdentifier:@"aSearchHeader"];
    
    self.searchField = (UITextField *)[headerCell.contentView viewWithTag:100];
    self.searchButton = (UIButton *)[headerCell.contentView viewWithTag:200];
    
    // UILabel *label = (UILabel *)[headerCell.contentView viewWithTag:300];
    
    [self.searchButton setBackgroundColor:[UIColor blueColor]];
    
    //[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    //[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[button setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    [self.searchButton setTitle:@"Search" forState:UIControlStateNormal];
    
    [self.searchButton addTarget:self
               action:@selector(searchButtonAction:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.searchField  setDelegate:self];
    
    [self.searchField  addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
     
    // [self.searchForm becomeFirstResponder];
    //    [self.searchForm setAutoresizingMask:UIViewAutoresizingNone];
    //
    //    [self.searchField setDelegate:self];
    //    [self.searchField becomeFirstResponder];
    //
    //    [self.searchField setEnabled:YES];
    //    [self.searchButton setTitleColor:[UIColor whiteColor]
    //                            forState:UIControlStateNormal];
    //
    //    // [self reloadPersons];
    //    self.searchButton.frame = CGRectMake(self.searchField.frame.origin.x+self.searchField.frame.size.width+8.0,
    //                                         self.searchField.frame.origin.y,
    //                                         60.0,
    //                                         self.searchField.frame.size.height);
    //    [self.searchButton addTarget:self
    //                          action:@selector(searchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return headerCell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DLog(@"");

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
    DLog(@"%@", self.query);
    
    if (!self.query || [self.query length]>0) {
        [ARLNetworking sendHTTPPostWithDelegate:self withBody:self.query];
    }
}

@end
