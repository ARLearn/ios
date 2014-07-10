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

        //!!!: Using Magicalrecord & Faults also seems to work.
        NSFetchRequest *fr = [TestAccount MR_requestAll];
        [fr setReturnsObjectsAsFaults:TRUE];
        _persons = [NSMutableArray arrayWithArray:[TestAccount MR_executeFetchRequest:fr]];

        // _persons = [NSMutableArray arrayWithArray:[TestAccount MR_findAll]];

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

//TODO:First time only fetch the ID's and store those in the NSMutableArray. They if a NSInteger, load the record if needed to simulate batch size?

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
 *  @param tableView The TableView
 *  @param section   The Section
 *
 *  @return The number of Rows in the Section.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case MAIN : {
            return [self.persons count];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
    }
    
    TestAccount *ta = [self.persons objectAtIndex:indexPath.row];
    
    cell.textLabel.text = ta.name;
    
    return cell;
}

/***************************************************************************************************************/

- (void)TestCode {
    
    //TESTCODE: CLEAR ALL TESTACCOUNT RECORDS.
    {
        Log(@"%@", [MagicalRecord currentStack]);

        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            Log(@"saveWithBlockAndWait");

            [TestAccount MR_truncateAllInContext:localContext];
        }];
    }
    
    //TESTCODE: ADD/SAVE A RECORD IN THE BACKGROUND AND RELOAD DATA.
    {
        Log(@"%@", [MagicalRecord currentStack]);
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            Log(@"saveWithBlockAndWait");
            
            TestAccount *ta = [TestAccount MR_createEntityInContext:localContext];
            ta.name = @"Wim van der Vegt";
            ta.email = @"wim@vander-vegt.nl";
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                [self reloadPersons];
            }
        }];
    }
    
    //TESTCODE: ADD/SAVE A RECORD BY NAME AND FILL WITH A DICTIONARY.
    {
        //!!!: Note the mismatch between TestAccount.name and xname. See fixups below!
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Wim Slot",          @"xname",
                              @"Wim",               @"givenName",
                              @"Slot",              @"familyName",
                              @"wim.slot@ou.nl",    @"email",
                              nil];
        
        //TODO: FIXUPS SHOULD BE static and constant if possible.
        //
        // Key   = CoreData Name.
        // Value = JSON Name.
        NSDictionary *fixups = [NSDictionary dictionaryWithObjectsAndKeys:
                                // Json , CoreData
                                @"xname", @"name",
                                nil];
        
        TestAccount *acc = (TestAccount *)[ARLUtils ManagedObjectFromDictionary:data entityName:@"TestAccount" nameFixups:fixups];
        Log(@"%@ %@", acc.name, acc.email);
        
        [self reloadPersons];
        
        Log(@"\n%@", [ARLUtils DictionaryFromManagedObject:acc nameFixups:fixups]);
    }
    
    //TESTCODE: ADD/SAVE A RECORD IN THE BACKGROUND QUEUE AND WAIT.
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
    
    //TESTCODE: ADD/SAVE/WAIT (ON) A RECORD. USE DEPENDEND TASKS TO UPDATE THE UI ON THE MAIN THREAD QUEUE.
    {
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
    }
    
    Log(@"MainThread %@", [NSThread currentThread]);
}

/***************************************************************************************************************/

@end
