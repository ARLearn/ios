 //
//  ARLCategoryViewController.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/15/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLStoreViewController.h"

@interface ARLStoreViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (weak, nonatomic) IBOutlet ARLButton *SearchButton;
@property (weak, nonatomic) IBOutlet ARLButton *CategoryButton;
@property (weak, nonatomic) IBOutlet ARLButton *TopGamesButton;
@property (weak, nonatomic) IBOutlet ARLButton *NearByButton;

@property (weak, nonatomic) IBOutlet UITableView *featuredTable;

@property (readonly, nonatomic) NSString *cellIdentifier;

- (IBAction)SearchButtonAction:(ARLButton *)sender;
- (IBAction)CategoryButtonAction:(ARLButton *)sender;
- (IBAction)TopGamesButtonAction:(ARLButton *)sender;
- (IBAction)NearByButtonAction:(ARLButton *)sender;

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, ARLStoreViewControllerGroups) {
    /*!
     *  Search Results.
     */
    FEATURED = 0,
    
    /*!
     *  Number of Groups
     */
    numARLStoreViewControllerGroups
};

@end

@implementation ARLStoreViewController

NSArray *ids;

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
    
#warning Hardcoded Value.
    ids = [NSArray arrayWithObjects: [NSNumber numberWithLongLong:13876002], [NSNumber numberWithLongLong:20536006], nil];
    
    [self applyConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.SearchButton makeButtonWithImageAndGradient:@"Search"
                                            titleText:NSLocalizedString(@"SearchLabel", @"SearchLabel")
                                           titleColor:[UIColor whiteColor]
                                           startColor:UIColorFromRGB(0xff664c)
                                             endColor:UIColorFromRGB(0xe94a35)];
    
    [self.CategoryButton makeButtonWithImageAndGradient:@"Category"
                                              titleText:NSLocalizedString(@"CategoryLabel", @"CategoryLabel")
                                             titleColor:[UIColor whiteColor]
                                             startColor:UIColorFromRGB(0xff664c)
                                               endColor:UIColorFromRGB(0xe94a35)];
    
    [self.TopGamesButton makeButtonWithImageAndGradient:@"TopGames"
                                              titleText:NSLocalizedString(@"TopGamesLabel", @"TopGamesLabel")
                                             titleColor:[UIColor whiteColor]
                                             startColor:UIColorFromRGB(0xff664c)
                                               endColor:UIColorFromRGB(0xe94a35)];
    
    [self.NearByButton makeButtonWithImageAndGradient:@"NearBy"
                                            titleText:NSLocalizedString(@"NearByLabel", @"NearByLabel")
                                           titleColor:[UIColor whiteColor]
                                           startColor:UIColorFromRGB(0xff664c)
                                             endColor:UIColorFromRGB(0xe94a35)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return numARLStoreViewControllerGroups;
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
        case FEATURED : {
            return 2;
        }
    }
    
    // Should not happen!!
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case FEATURED : {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
            
            switch (indexPath.item) {
                case 0:
                    cell.textLabel.text = @"Florence";
                    cell.detailTextLabel.text = @"Excursie Curltuurwetenschappen";
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
        case FEATURED : {
            return @"Featured";
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
        case FEATURED: {
            ARLGameViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameView"];
            
            if (newViewController) {
                newViewController.gameId = (NSNumber *)[ids objectAtIndex:indexPath.row];
                
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
    return  @"aFeaturedGames";
}

/*************************************************************************************/

#pragma mark - Methods

- (void) applyConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,             @"view",
                                     
                                     self.backgroundImage,  @"backgroundImage",
                                     
                                     self.SearchButton,     @"SearchButton",
                                     self.CategoryButton,   @"CategoryButton",
                                     self.TopGamesButton,   @"TopGamesButton",
                                     self.NearByButton,     @"NearByButton",
                                     
                                     self.featuredTable,    @"featuredTable",

                                     nil];
    
    // See http://stackoverflow.com/questions/17772922/can-i-use-autolayout-to-provide-different-constraints-for-landscape-and-portrait
    // See https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/Bars.html
    
    //    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.SearchButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.CategoryButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.TopGamesButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.NearByButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.featuredTable.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat sw = self.screenWidth;
    CGFloat bw = sw/2 - 3*8.0;
    
    // Fix Background.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    // Fix Buttons Horizontal.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-[SearchButton(==%f)]-[CategoryButton(==%f)]", bw, bw]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-[TopGamesButton(==%f)]-[NearByButton(==%f)]", bw, bw]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    // Make Buttons Square.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.SearchButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.SearchButton
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.CategoryButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.CategoryButton
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];
    
    // Fix Top Images Position Vertically.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.SearchButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:10.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.CategoryButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:10.0]];
    
    // Fix other Buttons.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[SearchButton]-[TopGamesButton(==SearchButton)]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[CategoryButton]-[NearByButton(==CategoryButton)]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    // Fix featured
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[NearByButton]-[featuredTable(200)]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[featuredTable]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}

#pragma mark - Actions

- (IBAction)SearchButtonAction:(ARLButton *)sender {
    DLog(@"");
}

- (IBAction)CategoryButtonAction:(ARLButton *)sender {
    DLog(@"");
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice"
//                                                    message:@"Message:"
//                                                   delegate:self
//                                          cancelButtonTitle:@"OK1"
//                                          otherButtonTitles:@"OK2",nil];
//    
//    [alert show];
}

- (IBAction)TopGamesButtonAction:(ARLButton *)sender {
    DLog(@"");
}

- (IBAction)NearByButtonAction:(ARLButton *)sender {
    DLog(@"");
}

@end
