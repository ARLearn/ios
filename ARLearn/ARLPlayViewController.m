//
//  ARLPlayViewController.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 05/01/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#import "ARLPlayViewController.h"

@interface ARLPlayViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UITableView *generalItems;

@property NSArray* items;

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, ARLPlayViewControllerGroups) {
    /*!
     *  General Item.
     */
    GENERALITEM = 0,
    
    /*!
     *  Number of Groups
     */
    numARLPlayViewControllerGroups
};

@end

@implementation ARLPlayViewController

@synthesize gameId;
@synthesize generalItems;

#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gameId=%@", self.gameId];
    
    self.items = [GeneralItem MR_findAllWithPredicate:predicate];
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

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case GENERALITEM : {
            return self.items.count;
        }
    }
    
    // Should not happen!!
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case GENERALITEM : {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: self.cellIdentifier];
  
            GeneralItem *item = (GeneralItem *)[self.items objectAtIndex:indexPath.item];
            
            cell.textLabel.text = item.name;
            
#error either data is stored incorrectly or this code just fails to retrieve JSON.
            
            NSData *data = [NSKeyedUnarchiver unarchiveObjectWithData:item.json];
            
            NSError *error = nil;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&error];
            if ([json valueForKey:@"dependsOn"]) {
                NSDictionary* dependsOn = [json valueForKey:@"dependsOn"];
                
                
                BeanIds bid = [ARLBeanNames beanTypeToBeanId:[dependsOn valueForKey:@"type"]];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Depends on type: %d", bid];
            } else {
                cell.detailTextLabel.text = @"Visible";
            }
            return cell;
        }
    }
    
    // Should not happen!!
    return nil;
}

#pragma mark - Properties

-(NSString *) cellIdentifier {
    return  @"GeneralItem";
}

#pragma mark - Methods

#pragma mark - Actions

@end
