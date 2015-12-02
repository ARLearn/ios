//
//  ARLCategoriesViewController.m
//  ARLearn
//
//  Created by Wim van der Vegt on 8/7/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLCategoriesViewController.h"

@interface ARLCategoriesViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (retain, nonatomic) NSMutableData *accumulatedData;
@property (nonatomic) long long accumulatedSize;

@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSArray *buttons;

@end

@implementation ARLCategoriesViewController

#pragma mark - ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set the background of the UIScrollView.
    UIImage *img = [UIImage imageNamed:@"background"];
    [self.scrollView setBackgroundColor:[UIColor colorWithPatternImage:img]];
    
    [self applyConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([ARLNetworking networkAvailable]) {
        [self performQuery];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    _results = nil;
    _buttons = nil;
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

#pragma mark - Properties

/*************************************************************************************/

#pragma mark - Methods

- (void) applyConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,             @"view",
                                     
                                     self.backgroundImage,  @"backgroundImage",

                                     nil];
    
    // See http://stackoverflow.com/questions/17772922/can-i-use-autolayout-to-provide-different-constraints-for-landscape-and-portrait
    // See https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/Bars.html
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Fix Background.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}

- (void)processData:(NSData *)data
{
    //Example Data:
    
    //    {
    //        categoryList =     (
    //                            {
    //                                categoryId = 2;
    //                                deleted = 0;
    //                                id = 22426001;
    //                                lang = nl;
    //                                title = "Crisis Simulatie";
    //                                type = "org.celstec.arlearn2.beans.store.Category";
    //                            },
    //                            {
    //                                categoryId = 3;
    //                                deleted = 0;
    //                                id = 22436001;
    //                                lang = nl;
    //                                title = "Taal Leren";
    //                                type = "org.celstec.arlearn2.beans.store.Category";
    //                            },
    //                            {
    //                                categoryId = 1;
    //                                deleted = 0;
    //                                id = 22466001;
    //                                lang = nl;
    //                                title = Cultuur;
    //                                type = "org.celstec.arlearn2.beans.store.Category";
    //                            }
    //                            );
    //        type = "org.celstec.arlearn2.beans.store.CategoryList";
    //    }
    
    // NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
    
    NSDictionary *json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    BeanIds bid = [ARLBeanNames beanTypeToBeanId:[json valueForKey:@"type"]];
    
    CGFloat sw = self.screenWidth;
    CGFloat bw = sw/2 - 3*8.0;
    
    self.buttons = [NSArray array];
    
    NSMutableDictionary *viewsDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                            self.view,                         @"view",
                                            
                                            nil];
    
    switch (bid) {
        case CategoryList: {
            self.results = (NSArray *)[json objectForKey:@"categoryList"];
            
            int i=0;
            
            for (int j=0; j< 1;j++) {
                for (NSDictionary *dict in self.results) {
                    ARLButton *btn = [[ARLButton alloc] init];
                    
                    btn.frame = CGRectMake(20, 20, bw, bw);
                    btn.backgroundColor = [UIColor redColor];
                    btn.tag = [[NSNumber numberWithInt:i] integerValue];
                    
                    [btn addTarget:self
                            action:@selector(CategoryButtonAction:)
                  forControlEvents:UIControlEventTouchUpInside];
                    
                    NSString *name = [NSString stringWithFormat:@"button_%d",i];
                    
                    [btn makeButtonWithImageAndGradient:@"Category"
                                              titleText:[dict valueForKey:@"title"]
                                             titleColor:[UIColor whiteColor]
                                             startColor:UIColorFromRGB(0xff664c)
                                               endColor:UIColorFromRGB(0xe94a35)];
                    btn.translatesAutoresizingMaskIntoConstraints = NO;
                    
                    self.buttons = [self.buttons arrayByAddingObject:btn];
                    
                    [self.scrollView insertSubview:[self.buttons objectAtIndex:i] aboveSubview:self.backgroundImage];
                    
                    viewsDictionary[name] = [self.buttons objectAtIndex:i];
                    
                    switch (i % 2) {
                        case 0:
                            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-[%@(==%f)]", name, bw]
                                                                                              options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                              metrics:nil
                                                                                                views:viewsDictionary]];
                            break;
                        case 1:
                            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[%@(==%f)]-|", name, bw]
                                                                                              options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                              metrics:nil
                                                                                                views:viewsDictionary]];
                            break;
                    }
                    
                    // Make Buttons Square.
                    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:[self.buttons objectAtIndex:i]
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:btn
                                                                          attribute:NSLayoutAttributeWidth
                                                                         multiplier:1.0
                                                                           constant:0]];
                    
                    // Fix Top Images Position Vertically.
                    //                    if (i==0) {
                    //                        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:[self.buttons objectAtIndex:i]
                    //                                                                              attribute:NSLayoutAttributeTop
                    //                                                                              relatedBy:NSLayoutRelationEqual
                    //                                                                                 toItem:self.topLayoutGuide
                    //                                                                              attribute:NSLayoutAttributeBottom
                    //                                                                             multiplier:1.0
                    //                                                                               constant:10.0]];
                    //                    }
                    
                    if (i>1) {
                        // 2nd row and lower, anchor to previous button row.
                        NSString *prevname = [NSString stringWithFormat:@"button_%d",i-2];
                        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[%@]-[%@]", prevname, name]
                                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                          metrics:nil
                                                                                            views:viewsDictionary]];
                    } else {
                        // Top Offset = 12 = 20-8
                        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(12)-[%@]", name]
                                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                          metrics:nil
                                                                                            views:viewsDictionary]];
                    }

                    
                    i++;
                }
                
                // Adjust size of the UIScrollView.
                if (i%2) {
                    [self.scrollView setContentSize : CGSizeMake(
                                                                 self.scrollView.frame.size.width,
                                                                 (i/2+1)*(bw+8)+8)];
                }else {
                    [self.scrollView setContentSize : CGSizeMake(
                                                                 self.scrollView.frame.size.width,
                                                                 (i/2+0)*(bw+8)+8)];
                }
            }
            break;
            
        default:
            break;
        }
    }
    
    
}

/*!
 *  Won't work off-line.
 */
- (void)performQuery {
    NSString *cacheIdentifier = [ARLNetworking generateGetDescription:@"store/categories/lang/nl"];
    
    NSData *response = [[ARLAppDelegate theQueryCache] getResponse:cacheIdentifier];
    
    if (!response) {
        [ARLNetworking sendHTTPGetWithDelegate:self withService:@"store/categories/lang/nl"];
    } else {
        DLog(@"Using cached query data");
        [self processData:response];
    }
}

#pragma mark - Actions

- (IBAction)CategoryButtonAction:(ARLButton *)sender {
    DLog(@"");
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:sender.titleLabel.text
    //                                                    message:[NSString stringWithFormat:@"Index: %ld", (long)sender.tag]
    //                                                   delegate:self
    //                                          cancelButtonTitle:@"OK1"
    //                                          otherButtonTitles:@"OK2",nil];
    //
    //    [alert show];
    
    NSDictionary *dict = (NSDictionary *)[self.results objectAtIndex:sender.tag];

    NSInteger catId = [[dict objectForKey:@"categoryId"] integerValue];
 
    ARLCategoryGamesViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryGamesView"];
    
    if (newViewController) {
        newViewController.categoryId = [NSNumber numberWithInteger:catId];
        
        // [newViewController setBackViewControllerClass:[self class]];
        
        // Move to another UINavigationController or UITabBarController etc.
        // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
        [self.navigationController pushViewController:newViewController animated:YES];
        
        newViewController = nil;
    }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    // NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    
    self.accumulatedSize = [response expectedContentLength];
    self.accumulatedData = [[NSMutableData alloc]init];
    
    // DLog(@"Got HTTP Response [%d], expect %lld byte(s)", [httpResponse statusCode], self.accumulatedSize);
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    // DLog(@"Got HTTP Data, %d of %lld byte(s)", [data length], self.accumulatedSize);
    
    // [ARLUtils LogJsonData:data url:[[[dataTask response] URL] absoluteString]];
    
    [self.accumulatedData appendData:data];
    
    if ([self.accumulatedData length]==self.accumulatedSize) {
        [ARLQueryCache addQuery:dataTask.taskDescription withResponse:data];
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    // DLog(@"Completed HTTP Task");
    
    if (error == nil)
    {
        [ARLQueryCache addQuery:task.taskDescription withResponse:self.accumulatedData];
        
        [self processData:self.accumulatedData];
        
        // DLog(@"Download is Succesfull");
    } else {
        ELog(error);
    }
    
    // Invalidate Session
    [session finishTasksAndInvalidate];
}

@end
