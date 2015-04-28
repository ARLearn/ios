//
//  ARLGeneralItemViewController.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 01/02/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#import "ARLGeneralItemViewController.h"

@interface ARLGeneralItemViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIWebView *descriptionText;
@property (weak, nonatomic) IBOutlet UITableView *answersTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

- (IBAction)saveButtonAction:(UIBarButtonItem *)sender;

@property (strong, nonatomic) NSArray *answers;

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, ARLGeneralItemViewControllerGroups) {
    /*!
     *  General Item.
     */
    ANSWER = 0,
    
    /*!
     *  Number of Groups
     */
    numARLGeneralItemViewControllerGroups
};

@end

@implementation ARLGeneralItemViewController

@synthesize activeItem = _activeItem;
@synthesize runId;

#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setting a footer hides empty cels at the bottom.
    self.answersTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    // The ContentSize of the UIWebView will only grow so start small.
    CGRect newBounds =  self.descriptionText.bounds;
    newBounds.size.height = 10;
    self.descriptionText.bounds = newBounds;
    
    self.descriptionText.delegate = self;
    
    if (self.activeItem) {
        if (TrimmedStringLength(self.activeItem.richText) != 0) {
            self.descriptionText.hidden = NO;
            [self.descriptionText loadHTMLString:self.activeItem.richText baseURL:nil];
        } else if (TrimmedStringLength(self.activeItem.descriptionText) != 0) {
            self.descriptionText.hidden = NO;
            [self.descriptionText loadHTMLString:self.activeItem.descriptionText baseURL:nil];
        }
    } else {
        self.descriptionText.hidden = YES;
    }
    
    if (self.descriptionText.isHidden) {
        [self applyConstraints];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case ANSWER : {
            return [self.answers count];
        }
    }
    
    // Should not happen!!
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case ANSWER : {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: self.cellIdentifier forIndexPath:indexPath];
          
            BeanIds bid = [ARLBeanNames beanTypeToBeanId:self.activeItem.type];
            
            switch (bid) {
                case SingleChoiceTest:
                    break;
                case MultipleChoiceTest:
                    break;
                default:
                    break;
            }
            
            NSDictionary *answer = [self.answers objectAtIndex:indexPath.row];
//            {
//                answer = boring;
//                id = Xd07MTYNbBwQioy;
//                isCorrect = 0;
//                type = "org.celstec.arlearn2.beans.generalItem.MultipleChoiceAnswerItem";
//            }
            cell.textLabel.text = [answer valueForKey:@"answer"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            return cell;
        }
    }
    
    // Should not happen!!
    return nil;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *oldIndex = [self.answersTable indexPathForSelectedRow];
    
    BeanIds bid = [ARLBeanNames beanTypeToBeanId:self.activeItem.type];
    
    switch (bid) {
        case SingleChoiceTest:
            if (oldIndex) {
                [self.answersTable cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case MultipleChoiceTest:
            //Do nothing.
            break;
        default:
            //Should not happen
            break;
    }
    
    return indexPath;
}

/*!
 *  Tap on table Row
 *
 *  @param tableView  {
 *  @param indexPath <#indexPath description#>
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    switch (indexPath.section) {
        case ANSWER: {
            UITableViewCell *cell = [self.answersTable cellForRowAtIndexPath:indexPath];
            
            switch (cell.accessoryType) {
                case UITableViewCellAccessoryNone:
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    break;
                case UITableViewCellAccessoryCheckmark:
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                default:
                    //Should not happen.
                    break;
            }
        }
    }
}

#pragma mark - UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    CGRect newBounds = webView.bounds;
    newBounds.size.height = webView.scrollView.contentSize.height;
    webView.bounds = newBounds;
    
    [self applyConstraints];
}

#warning TODO is to visablize the tasks to do

// See weSPOT PIM
//
//openQuestion =             {
//    textDescription = "";
//    type = "org.celstec.arlearn2.beans.generalItem.OpenQuestion";
//    valueDescription = "";
//    withAudio = 1;
//    withPicture = 1;
//    withText = 0;
//    withValue = 0;
//    withVideo = 0;
//}

//{
//    answers =             (
//                           {
//                               answer = boring;
//                               id = Xd07MTYNbBwQioy;
//                               isCorrect = 0;
//                               type = "org.celstec.arlearn2.beans.generalItem.MultipleChoiceAnswerItem";
//                           },
//                           {
//                               answer = "not so boring...";
//                               id = 3xrHNMQECVa81yh;
//                               isCorrect = 0;
//                               type = "org.celstec.arlearn2.beans.generalItem.MultipleChoiceAnswerItem";
//                           },
//                           {
//                               answer = interesting;
//                               id = 3nPYWc2gzqQvWlJ;
//                               isCorrect = 0;
//                               type = "org.celstec.arlearn2.beans.generalItem.MultipleChoiceAnswerItem";
//                           }
//                           );
//    autoLaunch = 0;
//    deleted = 0;
//    description = "Tell me what you think of this lecture so far";
//    fileReferences =             (
//                                  {
//                                      fileReference = "http://streetlearn.appspot.com/game/13876002/generalItems/13946007/audio";
//                                      key = audio;
//                                      type = "org.celstec.arlearn2.beans.generalItem.FileReference";
//                                  }
//                                  );
//    gameId = 13876002;
//    id = 13946007;
//    lastModificationDate = 1417180691530;
//    name = "This lecture is...";
//    richText = "Tell me what you think of this lecture so far";
//    roles =             (
//    );
//    scope = user;
//    showCountDown = 0;
//    sortKey = 0;
//    type = "org.celstec.arlearn2.beans.generalItem.SingleChoiceTest";
//}

//{
//    answers =             (
//                           {
//                               answer = "Read from your medical notes as you have written them?";
//                               id = tNP9MpMeCe7QR5Y;
//                               isCorrect = 0;
//                               type = "org.celstec.arlearn2.beans.generalItem.MultipleChoiceAnswerItem";
//                           },
//                           {
//                               answer = "Ask your receptionist to make the phone call?";
//                               id = 5ogsXvHvJ8kfJmi;
//                               isCorrect = 0;
//                               type = "org.celstec.arlearn2.beans.generalItem.MultipleChoiceAnswerItem";
//                           },
//                           {
//                               answer = "Ask your patient to make the phone call?";
//                               id = lQKCWClD3pnx2D7;
//                               isCorrect = 0;
//                               type = "org.celstec.arlearn2.beans.generalItem.MultipleChoiceAnswerItem";
//                           },
//                           {
//                               answer = "Use ISBAR for structured communication?";
//                               id = cFTT2ABGaRQsAt7;
//                               isCorrect = 0;
//                               type = "org.celstec.arlearn2.beans.generalItem.MultipleChoiceAnswerItem";
//                           }
//                           );
//    autoLaunch = 0;
//    deleted = 0;
//    description = "Which is the optimal way to ...";
//    fileReferences =             (
//    );
//    gameId = 13876002;
//    id = 5322433481408512;
//    lastModificationDate = 1418120145353;
//    name = "Multi-Select";
//    richText = "Which is the optimal way to ...";
//    roles =             (
//    );
//    scope = user;
//    showCountDown = 0;
//    sortKey = 0;
//    type = "org.celstec.arlearn2.beans.generalItem.MultipleChoiceTest";
//}

#pragma mark - Properties

-(NSString *) cellIdentifier {
    return  @"AnswerItem";
}

- (void)setActiveItem:(GeneralItem *)activeItem {
    _activeItem = activeItem;
    
    NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:self.activeItem.json];
    
    //#pragma warn Debug Code
    // [ARLUtils LogJsonDictionary:json url:@""];
    
    self.answers = [json valueForKey:@"answers"];
}

- (GeneralItem *)activeItem {
    return _activeItem;
}

#pragma mark - Methods

- (void) applyConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,             @"view",
                                     
                                     self.backgroundImage,  @"backgroundImage",
                                     
                                     self.answersTable,     @"answersTable",
                                     self.descriptionText,  @"descriptionText",
                                     
                                     nil];
    
    // See http://stackoverflow.com/questions/17772922/can-i-use-autolayout-to-provide-different-constraints-for-landscape-and-portrait
    // See https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/Bars.html
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.answersTable.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionText.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Fix Background.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    // Fix itemsTable Horizontal.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[answersTable]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    // Fix descriptionText Horizontal.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[descriptionText]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    // Fix itemsTable/descriptionText Vertically.
    if (self.descriptionText.isHidden) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[answersTable]-|"
                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-[descriptionText(==%f)]-[answersTable]-|",
                                                                                   self.descriptionText.bounds.size.height]
                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
    }
}


#pragma mark - Actions

- (IBAction)saveButtonAction:(UIBarButtonItem *)sender {
    
    for (int i=0; i<self.answers.count;i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:ANSWER];
        
        UITableViewCell *cell = [self.answersTable cellForRowAtIndexPath:indexPath];
        
        NSDictionary *answer = [self.answers objectAtIndex:i];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [ARLCoreDataUtils MarkAnswerAsGiven:self.runId
                                  generalItemid:self.activeItem.generalItemId
                                       answerId:[answer valueForKey:@"id"]];
            
            Log(@"Selected Answer(s): %@ [%@]", [answer valueForKey:@"answer"], [answer valueForKey:@"id"]);
        }
    };
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Events

@end
