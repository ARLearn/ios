//
//  ARLViewController.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/9/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLViewController.h"

@interface ARLViewController ()

@property (strong, nonatomic) IBOutlet UITableView *table;

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (nonatomic, strong) NSMutableArray *persons;

@end

@implementation ARLViewController

@synthesize persons = _persons;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    self.table.dataSource = self;
    
    [self reloadPersons];
    
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
#warning TEST CODE AHEAD.
    {
        Log(@"%@", [MagicalRecord currentStack]);

        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            Log(@"saveWithBlockAndWait");

            [TestAccount MR_truncateAllInContext:localContext];
            
            // TestAccount *ta = [TestAccount MR_createEntityInContext:localContext];
            // ta.name = @"Wim van der Vegt";
            // ta.email = @"wim@vander-vegt.nl";
        }];
    }
    
#warning TEST CODE AHEAD.
    //[[ARLAppDelegate theOQ] addOperationWithBlock:^ {
    //    Log(@"justAdding %@", [NSThread currentThread]);
    //    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
    //        Log(@"saveWithBlockAndWait %@", [NSThread currentThread]);
    //
    //        TestAccount *ta = [TestAccount MR_createEntityInContext:localContext];
    //        ta.name = @"wim van der Vegt";
    //        ta.email = @"wim@vander-vegt.nl";
    //    }];
    //}];
    
#warning TEST CODE AHEAD.
    NSBlockOperation *backBO =[NSBlockOperation blockOperationWithBlock:^{
        Log(@"backBO %@", [NSThread currentThread]);
        
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            Log(@"backBO.saveWithBlockAndWait %@", [NSThread currentThread]);
            
            // Note: Operations MUST use localContext or they will not be saved.
            // [TestAccount MR_truncateAllInContext:localContext];
            
           [NSThread  sleepForTimeInterval:5.0];
            
            Log(@"Awake again");
            TestAccount *ta = [TestAccount MR_createEntityInContext:localContext];
            ta.name = @"G.W van der Vegt";
            ta.email = @"wim.vandervegt@ou.nl";
        }];
    }];
    
    NSBlockOperation *foreBO =[NSBlockOperation blockOperationWithBlock:^{
        Log(@"foreBO %@", [NSThread currentThread]);
        Log(@"Records:%d", [TestAccount MR_countOfEntities]);
    }];
    
    NSInvocationOperation *foreIV = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(reloadPersons) object:nil];
    
    // Add dependencies: backBO -> foreBO -> foreIV.
    [foreBO addDependency:backBO];
    [foreIV addDependency:foreBO];
    
    // Add Operations to the appropriate queues.
    //
    // 1) Main Thread Queue
    [[NSOperationQueue mainQueue] addOperation:foreIV];
    [[NSOperationQueue mainQueue] addOperation:foreBO];
    //
    // 2) Background Thread Queue
    [[ARLAppDelegate theOQ] addOperation:backBO];
    
    Log(@"MainThread %@", [NSThread currentThread]);
    
    [self reloadPersons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
    // Clear Persons backing fields to trigger a reload.
    _persons = nil;
}

/*************************************************************************************/

/*!
 *  Getter
 *
 *  @return The Cell Identifier.
 */
-(NSString *) cellIdentifier {
    return  @"aPerson";
}

/*!
 *  Getter
 *
 *  @return The list of Persons.
 */
-(NSMutableArray *) persons {
    if (_persons == nil) {
        _persons = [NSMutableArray arrayWithArray:[TestAccount MR_findAll]];
    }
    return  _persons;
}

/***************************************************************************************************************/

/*!
 *  Reload the Persons and Table.
 */
- (void)reloadPersons {
    Log(@"reloadPersons %@", [NSThread currentThread]);
    
    // Clear Persons backing fields to trigger a reload.
    _persons = nil;
    
    [self.table reloadData];
}

/*!
 *  Refresh (and Reload) the Table.
 *
 *  @param sender <#sender description#>
 */
- (void)refresh:(id)sender
{
    NSLog(@"Refreshing");
    
    // Reload cached data.
    [self reloadPersons];

    // End Refreshing
    [(UIRefreshControl *)sender endRefreshing];
}

/***************************************************************************************************************/

#warning TODO First time onluy fetch the ID's and store those in the NSMutableArray. They if a NSInteger, load the record if needed to simulate batch size?

/*!
 *  Number of Sections of the Table.
 *
 *  @param tableView <#tableView description#>
 *
 *  @return <#return value description#>
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*!
 *  Number of Tabel Rows in a Section.
 *
 *  @param tableView <#tableView description#>
 *  @param section   <#section description#>
 *
 *  @return <#return value description#>
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [self.persons count];
}

/*!
 *  Get the Cell for a particular Section and Row.
 *
 *  @param tableView <#tableView description#>
 *  @param indexPath <#indexPath description#>
 *
 *  @return <#return value description#>
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
    }
    
    TestAccount *ta = [self.persons objectAtIndex:indexPath.row];
    
    cell.textLabel.text = ta.name;
    
    return cell;
}

/***************************************************************************************************************/


@end
