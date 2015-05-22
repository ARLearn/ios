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
@property (weak, nonatomic) IBOutlet UITableView *answersTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

- (IBAction)saveButtonAction:(UIBarButtonItem *)sender;

@property (strong, nonatomic) NSArray *answers;

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, ARLGeneralItemViewControllerGroups) {
    /*!
     *  Question/Description.
     */
    QUESTION = 0,
    
    /*!
     *  Answers.
     */
    ANSWER = 1,
    
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

CGFloat wbheight = 0.1f;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    wbheight = 0.1f;
    
    // Setting a footer hides empty cels at the bottom.
    self.answersTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    
    // if (self.descriptionText.isHidden) {
    [self applyConstraints];
    //}
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

/*!
 *  The number of sections in a Table.
 *
 *  @param tableView The Table to be served.
 *
 *  @return The number of sections.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    return numARLGeneralItemViewControllerGroups;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case QUESTION:
            return 1;
            
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
        case QUESTION: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier1
                                                                    forIndexPath:indexPath];
       
            UIWebView *descriptionText = (UIWebView *)[cell.contentView viewWithTag:1];
            
            // The ContentSize of the UIWebView will only grow so start small.
            //    CGRect newBounds =  self.descriptionText.bounds;
            //    newBounds.size.height = 10;
            //    self.descriptionText.bounds = newBounds;
            
            // wbheight = 0.1f;
            
            if (self.activeItem) {
                // no nice but te initial 0.1f becomes 0.1000000001 !
                if (wbheight<0.2f) {
                    descriptionText.delegate = self;
                    
                    if (TrimmedStringLength(self.activeItem.richText) != 0) {
                        descriptionText.hidden = NO;
                        [descriptionText loadHTMLString:self.activeItem.richText baseURL:nil];
                    } else if (TrimmedStringLength(self.activeItem.descriptionText) != 0) {
                        descriptionText.hidden = NO;
                        [descriptionText loadHTMLString:self.activeItem.descriptionText baseURL:nil];
                    }
                }
            } else {
                descriptionText.hidden = YES;
            }
            
            return cell;
        }
            
        case ANSWER: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: self.cellIdentifier2 forIndexPath:indexPath];
          
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Log(@"heightForRowAtIndexPath %@",indexPath);
    
    CGFloat rh = tableView.rowHeight==-1 ? 44.0f : tableView.rowHeight;
    
    switch (indexPath.section) {
        case QUESTION:
            return wbheight;
            
        case ANSWER:
            return rh;
    }
    
    // Error
    return rh;
}

#pragma mark - UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    CGRect newBounds = webView.bounds;
    newBounds.size.height = webView.scrollView.contentSize.height;
    webView.bounds = newBounds;
    
    // NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];

    // Log(@"%@", html);
    
    wbheight = newBounds.size.height;
    
    // [self applyConstraints];
    // [self.answersTable reloadData];
}

// See http://stackoverflow.com/questions/8490038/open-target-blank-links-outside-of-uiwebview-in-safari
//
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:request.URL];
        return false;
    }
    
    return true;
}

#pragma mark - UIAlertViewDelegate

/*!
 *  Click At Button Handler.
 *
 *  @param alertView   <#alertView description#>
 *  @param buttonIndex <#buttonIndex description#>
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#warning TODO is to visualize the tasks to do

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

-(NSString *) cellIdentifier1 {
    return  @"QuestionItem";
}

-(NSString *) cellIdentifier2 {
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
                                     
                                     nil];
    
    // See http://stackoverflow.com/questions/17772922/can-i-use-autolayout-to-provide-different-constraints-for-landscape-and-portrait
    // See https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/Bars.html
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.answersTable.translatesAutoresizingMaskIntoConstraints = NO;
    
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
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[descriptionText]-|"
//                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                      metrics:nil
//                                                                        views:viewsDictionary]];
    
    // Fix itemsTable/descriptionText Vertically.
    //if (self.descriptionText.isHidden) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[answersTable]-|"
                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
//    } else {
//        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-[descriptionText(==%f)]-[answersTable]-|",
//                                                                                   self.descriptionText.bounds.size.height]
//                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                          metrics:nil
//                                                                            views:viewsDictionary]];
//    }
}


#pragma mark - Actions

- (IBAction)saveButtonAction:(UIBarButtonItem *)sender {
    
    BeanIds bid = [ARLBeanNames beanTypeToBeanId:self.activeItem.type];
    
    for (int i=0; i<self.answers.count;i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:ANSWER];
        
        UITableViewCell *cell = [self.answersTable cellForRowAtIndexPath:indexPath];
        
        NSDictionary *answer = [self.answers objectAtIndex:i];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [ARLCoreDataUtils MarkAnswerAsGiven:self.runId
                                  generalItemid:self.activeItem.generalItemId
                                       answerId:[answer valueForKey:@"id"]];
            //{
            //    answer = "twee en veertig";
            //    feedback = prima;
            //    id = aHjTIkkje57loHj;
            //    isCorrect = 1;
            //    type = "org.celstec.arlearn2.beans.generalItem.MultipleChoiceAnswerItem";
            //}
            
            if (bid == SingleChoiceTest && [answer valueForKey:@"isCorrect"]) {
                
                switch ([[answer valueForKey:@"isCorrect"] integerValue]) {
                    case 0: {
                        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                                              message:NSLocalizedString(@"Wrong", @"Wrong")
                                                                             delegate:nil
                                                                    cancelButtonTitle:NSLocalizedString(@"Continue", @"Continue")
                                                                    otherButtonTitles:nil, nil];
                        [myAlertView show];
                    }
                        break;
                    case 1: {
                        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                                              message:NSLocalizedString(@"Correct", @"Correct")
                                                                             delegate:self
                                                                    cancelButtonTitle:NSLocalizedString(@"Continue", @"Continue")
                                                                    otherButtonTitles:nil, nil];
                        [myAlertView show];

                    }
                        break;
                }
            }
            
            DLog(@"Selected Answer(s): %@ [%@]", [answer valueForKey:@"answer"], [answer valueForKey:@"id"]);
        }
    };
}

#pragma mark - Events

@end
