//
//  ARLTopGamesTableViewController.m
//  ARLearn
//
//  Created by Wim van der Vegt on 8/11/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLTopGamesTableViewController.h"

@interface ARLTopGamesTableViewController ()

@property (readonly, nonatomic) NSString *cellIdentifier;


/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, ARLTopGamesTableViewControllerGroups) {
    /*!
     *  NearBy Search Results.
     */
    TOPGAMES = 0,
    
    /*!
     *  Number of Groups
     */
    numARLTopGamesTableViewControllerGroups
};

@end

@implementation ARLTopGamesTableViewController

NSArray *ids;

#pragma mark - ViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    
    ids = [NSArray array];
    //    ids = [NSArray arrayWithObjects:
    //           // [NSNumber numberWithLongLong:10206097],
    //           // [NSNumber numberWithLongLong:5248241780129792],
    //           nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
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
    return numARLTopGamesTableViewControllerGroups;
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
        case TOPGAMES : {
            return 2;
        }
    }
    
    // Should not happen!!
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case TOPGAMES : {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                                    forIndexPath:indexPath];
            
            switch (indexPath.item) {
                case 0:
                    cell.textLabel.text = @"Game1";
                    cell.detailTextLabel.text = @"Starting tomorrow";
                    break;
                case 1:
                    cell.textLabel.text = @"Game2";
                    cell.detailTextLabel.text = @"Starting now";
                    break;
            }
            cell.imageView.image = [UIImage imageNamed:@"MyGames"];
            
            return cell;
        }
    }
    
    // Should not happen!!
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;{
    switch (section) {
        case TOPGAMES : {
            return @"Top games";
        }
    }
    
    // Should not happen!!
    return @"";
}

/*!
 *  Tap on table Row
 *
 *  @param tableView <#tableView description#>
 *  @param indexPath <#indexPath description#>
 */
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    switch (indexPath.section) {
        case TOPGAMES: {
            ARLGameViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameView"];
            
            if (newViewController) {
                newViewController.gameId = (NSNumber *)[ids objectAtIndex:indexPath.row];
                [newViewController setBackViewControllerClass:[self class]];
                
                // Move to another UINavigationController or UITabBarController etc.
                // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
                [self.navigationController pushViewController:newViewController animated:YES];
            }
            break;
        }
    }
}

#pragma mark - Properties

/*!
 *  Getter
 *
 *  @return The Cell Identifier.
 */
-(NSString *) cellIdentifier {
    return  @"aTopGames";
}

#pragma mark - Methods


@end
