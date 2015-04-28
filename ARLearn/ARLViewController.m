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

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, ARLViewControllerGroups) {
    /*!
     *  Main Group.
     */
    MAIN = 0,
  
    /*!
     *  Number of Groups
     */
    numARLViewControllerGroups
};

@end

@implementation ARLViewController

@synthesize persons = _persons;

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
    self.table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

	// Do any additional setup after loading the view, typically from a nib.
    
    self.table.dataSource = self;
    
    [self reloadPersons];
    
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self TestCode];
}

/*!
 *  Just clear the stored data.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
    // Clear Persons backing fields to trigger a reload.
    _persons = nil;
}

#pragma mark - Properties

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
    @synchronized(self)
    {
        if (_persons == nil) {
            
            //!!!: Using Magicalrecord & Faults also seems to work.
            NSFetchRequest *fr = [TestAccount MR_requestAll];
            [fr setReturnsObjectsAsFaults:TRUE];
            _persons = [NSMutableArray arrayWithArray:[TestAccount MR_executeFetchRequest:fr]];
            
            // _persons = [NSMutableArray arrayWithArray:[TestAccount MR_findAll]];
            
        }
    }
    return  _persons;
}

#pragma mark - Methods

/***************************************************************************************************************/

/*!
 *  Reload the Persons and Table.
 */
- (void)reloadPersons {
    // Log(@"reloadPersons %@", [NSThread currentThread]);
    
    // Clear Persons backing fields to trigger a reload.
    @synchronized(self)
    {
        _persons = nil;

        // Log(@"Count: %d", [self.persons count]);
    }
    
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
    [self reloadPersons];

    // End Refreshing
    [(UIRefreshControl *)sender endRefreshing];
}

#pragma mark - TabelViewController

/***************************************************************************************************************/

/*!
 *  Number of Sections of the Table.
 *
 *  @param tableView The TableView
 *
 *  @return The number of Groups.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return numARLViewControllerGroups;
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
 *  @param tableView The TableView
 *  @param indexPath The Row Requested.
 *
 *  @return The UITableViewCell for the requested Row.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                            forIndexPath:indexPath];
    
    //    if (cell == nil) {
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
    //                                      reuseIdentifier:self.cellIdentifier];
    //    }
    
    TestAccount *ta = [self.persons objectAtIndex:indexPath.row];
    
    cell.textLabel.text = ta.name;
    
    return cell;
}

#pragma mark - Test Code

/***************************************************************************************************************/

- (void)TestCode {
    
    //TESTCODE: Clear all TestAccount records.
    {
        // Log(@"%@", [MagicalRecord currentStack]);

        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            // Log(@"saveWithBlockAndWait");

            [TestAccount MR_truncateAllInContext:localContext];
        }];
    }
    
    //TESTCODE: Add/Save a record in the backgrounnd and reload data.
    {
        // Log(@"%@", [MagicalRecord currentStack]);
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            // Log(@"saveWithBlockAndWait");
            
            TestAccount *ta = [TestAccount MR_createEntityInContext:localContext];
            ta.name = @"Wim van der Vegt";
            ta.email = @"wim@vander-vegt.nl";
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                [self reloadPersons];
            }
        }];
    }
    
    //TESTCODE: Add/Save a record by name and fill it with a NSDictionary.
    {
        //!!!: Note the mismatch between TestAccount.name and xname. See fixups below!
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Wim Slot",          @"xname",
                              @"Wim",               @"givenName",
                              @"Slot",              @"familyName",
                              @"wim.slot@ou.nl",    @"email",
                              nil];
        
        //TODO: FIXUPS Should be static and constant if possible.
        //
        // Key   = CoreData Name.
        // Value = JSON Name.
        NSDictionary *fixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                // Json , CoreData
                                @"xname", @"name",
                                nil];
        
        NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
        
        // Uses MagicalRecord for Saving!
        TestAccount *acc = (TestAccount *)[ARLUtils ManagedObjectFromDictionary:data entityName:[TestAccount MR_entityName] // @"TestAccount"
                                                                     nameFixups:fixups
                                                                 managedContext:ctx];
        
        // Log(@"%@ %@", acc.name, acc.email);
        
        [self reloadPersons];
        
        Log(@"\n%@", [ARLUtils DictionaryFromManagedObject:acc nameFixups:fixups]);
    }
    
    //TESTCODE: Add/Save/Waitfor a record in the background queue.
    {
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
    }
    
    //TESTCODE: Add/Save/Waitfor a record. Use dependend tasks to update the UI using the main thread queue.
    {
        NSBlockOperation *backBO =[NSBlockOperation blockOperationWithBlock:^{
            // Log(@"backBO %@", [NSThread currentThread]);
            
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                // Log(@"backBO.saveWithBlockAndWait %@", [NSThread currentThread]);
                
                // Note: Operations MUST use localContext or they will not be saved.
                // [TestAccount MR_truncateAllInContext:localContext];
                
                [NSThread sleepForTimeInterval:5.0];
                
                // Log(@"Awake again");
                TestAccount *ta = [TestAccount MR_createEntityInContext:localContext];
                ta.name = @"G.W van der Vegt";
                ta.email = @"wim.vandervegt@ou.nl";
            }];
        }];
        
        NSBlockOperation *foreBO =[NSBlockOperation blockOperationWithBlock:^{
            // Log(@"foreBO %@", [NSThread currentThread]);
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
    }
    
    // Log(@"MainThread %@", [NSThread currentThread]);
}

/***************************************************************************************************************/

@end
