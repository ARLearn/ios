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
    // self.answersTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
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

/*!
 *  Return Title of Section. See http://stackoverflow.com/questions/9737616/uitableview-hide-header-from-empty-section
 *
 *  @param tableView <#tableView description#>
 *  @param section   <#section description#>
 *
 *  @return <#return value description#>
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section){
        case QUESTION:
            return nil;
        case ANSWER:
            return nil;
    }
    
    // Error
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case QUESTION: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier1
                                                                    forIndexPath:indexPath];
       
            UIWebView *descriptionText = (UIWebView *)[cell.contentView viewWithTag:1];
            
            //NSString *html = [descriptionText stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
            
            // Log(@"%@", html);
            
            [descriptionText setUserInteractionEnabled:NO];
            
            if (self.activeItem) {
                
                // The ContentSize of the UIWebView will only grow so start small.
                // CGRect newBounds =  descriptionText.bounds;
                // newBounds.size.height = 10;
                descriptionText.bounds = cell.contentView.frame;
                
                cell.backgroundColor = [UIColor redColor];
                
                // see http://stackoverflow.com/questions/2626104/iphone-xcode-programming-make-a-uiwebview-scrollable
                // descriptionText.scalesPageToFit = YES;
                
                // no nice but te initial 0.1f becomes 0.1000000001 !
                if (wbheight<0.2f) {
                    descriptionText.delegate = self;
                    
#pragma warn, can contain urls lile <img src="game/5794474118610944/generalItems/6460249024233472/image" width="100%">
                    
                    if (self.activeItem) {
                        if (TrimmedStringLength(self.activeItem.richText) != 0) {
                            descriptionText.hidden = NO;
                            [descriptionText loadHTMLString:[ARLUtils replaceLocalUrlsinHtml:self.activeItem.richText]
                                                    baseURL:nil];
                        } else if (TrimmedStringLength(self.activeItem.descriptionText) != 0) {
                            descriptionText.hidden = NO;
                            [descriptionText loadHTMLString:[ARLUtils replaceLocalUrlsinHtml:self.activeItem.descriptionText]
                                                    baseURL:nil];
                            
                        } else {
                            descriptionText.hidden = YES;
                        }
                    } else {
                        descriptionText.hidden = YES;
                    }
                    
//                    NSString *html;
//                    if (TrimmedStringLength(self.activeItem.richText) != 0) {
//                        descriptionText.hidden = NO;
//                        html = [ARLUtils replaceLocalUrlsinHtml:self.activeItem.richText];
//                    } else if (TrimmedStringLength(self.activeItem.descriptionText) != 0) {
//                        descriptionText.hidden = NO;
//                        html = [ARLUtils replaceLocalUrlsinHtml:self.activeItem.descriptionText];
//                    }
//                    
//                    [descriptionText loadHTMLString:html baseURL:nil];
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
    CGFloat rh = tableView.rowHeight==-1 ? 44.0f : tableView.rowHeight;
    
    switch (indexPath.section) {
        case QUESTION: {
            return MAX(rh, wbheight);
        }
        case ANSWER:
            return rh;
    }
    
    // Error
    return rh;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    
//    switch (section) {
//        case QUESTION:
//            return wbheight;
//        case ANSWER:
//            return 0.0f;
//    }
//    
//    return 0.0f;
//}

#pragma mark - UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    frame.origin = CGPointMake(0.0f,0.0f);
    webView.frame = frame;

    wbheight = fittingSize.height;
    
    // See http://stackoverflow.com/questions/14066537/is-there-any-way-refresh-cells-height-without-reload-reloadrow
    [self.answersTable beginUpdates];
    [self.answersTable endUpdates];
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
    // Fix itemsTable Vertically.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[answersTable]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}


#pragma mark - Actions

- (IBAction)saveButtonAction:(UIBarButtonItem *)sender {
    
    BeanIds bid = [ARLBeanNames beanTypeToBeanId:self.activeItem.type];
    
    NSString *feedback = @"";
    NSString *title = @"";

    NSInteger correct = 0;
    NSInteger wrong = 0;
    NSInteger answered = 0;
    
    for (int i=0; i<self.answers.count;i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:ANSWER];
        
        UITableViewCell *cell = [self.answersTable cellForRowAtIndexPath:indexPath];
        
        //{
        //    answer = "twee en veertig";
        //    feedback = prima;
        //    id = aHjTIkkje57loHj;
        //    isCorrect = 1;
        //    type = "org.celstec.arlearn2.beans.generalItem.MultipleChoiceAnswerItem";
        //}

        NSDictionary *answer = [self.answers objectAtIndex:i];
        
        // Count number of answers, number of correct answers and number of wrong answers.
        // Prepare feedback if present (value & feedback).
        //
        switch (bid) {
            case SingleChoiceTest: {
                correct += [[answer valueForKey:@"isCorrect"] boolValue] ? 1 : 0;

                if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                    
                    if ([answer valueForKey:@"feedback"]) {
                        feedback = [[answer valueForKey:@"isCorrect"] boolValue] ? [answer valueForKey:@"feedback"] : @"";
                    }

                    answered++;

                    wrong += [[answer valueForKey:@"isCorrect"] boolValue] ? 0 : 1;
                    
                    [ARLCoreDataUtils MarkAnswerAsGiven:self.runId
                                          generalItemid:self.activeItem.generalItemId
                                               answerId:[answer valueForKey:@"id"]];
                    
                    DLog(@"Selected Answer(s): %@ [%@]", [answer valueForKey:@"answer"], [answer valueForKey:@"id"]);
                }
            }
                break;
                
            case MultipleChoiceTest:
            {
                correct += [[answer valueForKey:@"isCorrect"] boolValue] ? 1 : 0;
                
                if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                    if ([answer valueForKey:@"feedback"]) {
                        feedback = [[feedback stringByAppendingString:[answer valueForKey:@"answer"]] stringByAppendingString:@"\n"];
                        feedback = [[feedback stringByAppendingString:[answer valueForKey:@"feedback"]] stringByAppendingString:@"\n\n"];
                    }
                    
                    answered++;
                    
                    wrong += [[answer valueForKey:@"isCorrect"] boolValue] ? 0 : 1;
                    
                    [ARLCoreDataUtils MarkAnswerAsGiven:self.runId
                                          generalItemid:self.activeItem.generalItemId
                                               answerId:[answer valueForKey:@"id"]];
                    
                    DLog(@"Selected Answer(s): %@ [%@]", [answer valueForKey:@"answer"], [answer valueForKey:@"id"]);
                }
            }
                break;
                
            default:
                return;
        }
    }
    
    BOOL answeredOk = (answered == correct) && (wrong == 0);
   
    title = answeredOk ? NSLocalizedString(@"Correct", @"Correct") : NSLocalizedString(@"Wrong", @"Wrong");
    
    NSString *message = [feedback stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    
    // Only show extra feedback when there are no incorrect answers present and not all correct ones are selected.
    //
    if (bid == MultipleChoiceTest && (answered < correct) && (wrong == 0)) {
        message = [[message stringByAppendingString:@"\n\n"] stringByAppendingString:@"At least one correct answer is missing"];
    }
    
    // Show feedback and return to previous screen if the MC has been answered correctly.
    //
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:title
                                                          message:message
                                                         delegate:answeredOk ? self : nil
                                                cancelButtonTitle:NSLocalizedString(@"Continue", @"Continue")
                                                otherButtonTitles:nil, nil];
    
    // Fails for iOS 7+
    //    for (UIView *view in myAlertView.subviews) {
    //        if([[view class] isSubclassOfClass:[UILabel class]]) {
    //            ((UILabel*)view).textAlignment = NSTextAlignmentLeft;
    //        }
    //    }
    
    [myAlertView show];
}

#pragma mark - Events

@end
