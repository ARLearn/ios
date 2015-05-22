//
//  ARLNarratorItemViewController.m
//  ARLearn
//
//  Created by Stefaan Ternier on 7/18/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLNarratorItemViewController.h"

@interface ARLNarratorItemViewController ()

/*!
 *  ID's and order of the cells sections.
 */
typedef NS_ENUM(NSInteger, responses) {
    /*!
     * Uploaded Responses.
     */
    RESPONSES = 0,
    /*!
     *  Number of Responses
     */
    numResponses
};

// openQuestion

@property (weak, nonatomic) IBOutlet UITableView *itemsTable;
@property (weak, nonatomic) IBOutlet UIWebView *descriptionText;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (nonatomic, readwrite) BOOL withAudio;
@property (nonatomic, readwrite) BOOL withPicture;
@property (nonatomic, readwrite) BOOL withText;
@property (nonatomic, readwrite) BOOL withValue;
@property (nonatomic, readwrite) BOOL withVideo;
@property (nonatomic, readwrite) BOOL isVisible;

@property (strong, nonatomic) UITextField *valueTextField;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@property (strong, nonatomic) NSString *textDescription;
@property (strong, nonatomic) NSString *valueDescription;

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (readwrite, nonatomic) UIImagePickerControllerCameraCaptureMode mode;

// audioFeed

@property (strong, nonatomic) AVAudioSession *audioSession;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (strong, nonatomic) NSDictionary *openQuestion;
@property (strong, nonatomic) Run *run;

@property (weak, nonatomic) IBOutlet UIButton *playerButton;
@property (weak, nonatomic) IBOutlet UISlider *playerSlider;

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *elapsedLabel;

- (IBAction)playerAction:(UIButton *)sender;
- (IBAction)sliderAction:(UISlider *)sender;
- (IBAction)isScrubbing:(UISlider *)sender;

@property (readonly, nonatomic) NSTimeInterval CurrentAudioTime;
@property (readonly, nonatomic) NSNumber *AudioDuration;

@property BOOL isPaused;
@property BOOL scrubbing;
@property NSTimer *timer;

@property AVURLAsset *avAsset;
@property AVPlayerItem *playerItem;
@property AVPlayer *avPlayer;
@property id playbackTimeObserver;

@property BeanIds beanId;

@end

@implementation ARLNarratorItemViewController

@synthesize activeItem = _activeItem;
@synthesize runId = _runId;
@synthesize run;

@synthesize CurrentAudioTime;
@synthesize AudioDuration;
@synthesize beanId;

#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setting a footer hides empty cels at the bottom.
    self.itemsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    CGRect newBounds =  self.descriptionText.bounds;
    newBounds.size.height = 10;
    self.descriptionText.bounds = newBounds;
    
    if (self.activeItem) {
        if (TrimmedStringLength(self.activeItem.richText) != 0) {
            self.descriptionText.hidden = NO;
            [self.descriptionText loadHTMLString:self.activeItem.richText baseURL:nil];
        } else if (TrimmedStringLength(self.activeItem.descriptionText) != 0) {
            self.descriptionText.hidden = NO;
            [self.descriptionText loadHTMLString:self.activeItem.descriptionText baseURL:nil];
        } else {
            self.descriptionText.hidden = YES;
        }
    } else {
        self.descriptionText.hidden = YES;
    }
    
    self.descriptionText.delegate = self;
    
    [ARLCoreDataUtils CreateOrUpdateAction:self.runId
                                activeItem:self.activeItem
                                      verb:read_action];
    
    //create long press gesture recognizer(gestureHandler will be triggered after gesture is detected)
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandler:)];
    
    //adjust time interval(floating value CFTimeInterval in seconds)
    longPressGesture.minimumPressDuration = 1.5;
    longPressGesture.delegate = self;
    longPressGesture.delaysTouchesBegan = YES;
    
    //add gesture to view you want to listen for it(note that if you want whole view to "listen" for gestures you should add gesture to self.view instead)
    [self.itemsTable addGestureRecognizer:longPressGesture];
    
    // Do any additional setup after loading the view.
//    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"run.runId=%@ AND generalItem.generalItemId=%@ AND (revoked=NULL OR revoked=%@)", self.runId, self.activeItem.generalItemId, @NO];
//    
//    self.items = [Response MR_findAllSortedBy:@"sortKey"
//                                       ascending:NO
//                                   withPredicate:predicate1];
//    
//    // Again Sort....
//    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO];
//    self.items = [self.items sortedArrayUsingDescriptors:@[sort]];
    
    self.itemsTable.delegate = self;
    self.itemsTable.dataSource = self;
    
    NSDictionary *jsonDict = [NSKeyedUnarchiver unarchiveObjectWithData:self.activeItem.json];
    
    self.navigationItem.title = self.activeItem.name;
    
    self.beanId = [ARLBeanNames beanTypeToBeanId:[jsonDict valueForKey:@"type"]];
    
    Log(@"BeanId: %@", [jsonDict valueForKey:@"type"]);
    
    // Plays:
    //  org.celstec.arlearn2.beans.generalItem.NarratorItem
    //  org.celstec.arlearn2.beans.generalItem.AudioObject
    
    if ([jsonDict valueForKey:@"audioFeed"]) {
        NSString *audioFile = [jsonDict valueForKey:@"audioFeed"];
        NSURL *audioUrl;
        
        NSRange index = [audioFile rangeOfString:[self.activeItem.gameId stringValue]];
        
        if (index.length != 0) {
            //https://dl.dropboxusercontent.com/u/20911418/ELENA%20pilot%20october%202013/Audio/Voice0001.aac
            // index = 0x7ffffff,0
            NSString *path = [audioFile substringFromIndex:index.location + index.length];
            path = [path stringByAppendingString:@".mp3"];
            audioFile = [ARLUtils GenerateResourceFileName:self.activeItem.gameId
                                                      path:path];
            
            audioUrl = [[NSURL alloc] initFileURLWithPath:audioFile];
        } else {
            audioUrl = [NSURL URLWithString:audioFile];
        }
        
        //http://stackoverflow.com/questions/3635792/play-audio-from-internet-using-avaudioplayer
        //http://stackoverflow.com/questions/5501670/how-to-play-movie-files-with-no-file-extension-on-ios-with-mpmovieplayercontroll
        
        self.avAsset = [AVURLAsset URLAssetWithURL:audioUrl
                                           options:nil];
        
        self.playerItem = [AVPlayerItem playerItemWithAsset:self.avAsset];
        
        self.avPlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
        
        [self resetPlayer];
        
        //init the Player to get file properties to set the time labels
        //        self.playerSlider.value = 0.0;
        //        self.playerSlider.maximumValue = [self.AudioDuration floatValue];
        //
        //        //init the current timedisplay and the labels. if a current time was stored
        //        //for this player then take it and update the time display
        //        self.elapsedLabel.text = @"0:00";
        //
        //        self.durationLabel.text = [NSString stringWithFormat:@"-%@", [self timeFormat:self.AudioDuration]];
        
        if (![[jsonDict objectForKey:@"autoPlay"] boolValue]) {
            [self togglePlaying];
        }
    } else {
        [self.playerButton setHidden:YES];
        [self.playerSlider setHidden:YES];
        [self.durationLabel setHidden:YES];
        [self.elapsedLabel setHidden:YES];
    }
    
    if (![jsonDict objectForKey:@"openQuestion"]) {
        [self.itemsTable setHidden:YES];
        self.navigationController.toolbarHidden = YES;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    if (self.descriptionText.isHidden) {
        [self applyConstraints];
    }

    if (!self.playerButton.isHidden) {
        [self.avPlayer addObserver:self forKeyPath:@"rate" options:0 context:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidFinishPlaying:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.avPlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidFailPlaying:)
                                                     name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                   object:self.avPlayer];
    }
    
    if (!self.itemsTable.isHidden) {
        NSDictionary *jsonDict = [NSKeyedUnarchiver unarchiveObjectWithData:self.activeItem.json];
        
        [self processJsonSetup:[jsonDict objectForKey:@"openQuestion"]];
        
        self.navigationController.toolbarHidden = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(syncProgress:)
                                                     name:ARL_SYNCPROGRESS
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(syncReady:)
                                                     name:ARL_SYNCREADY
                                                   object:nil];
        
        [self setupFetchedResultsController];
        
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
        ELog(error);
        
        DLog("Feched %d Records", [[self.fetchedResultsController fetchedObjects] count]);
        
        [self.itemsTable reloadData];
        
        NSBlockOperation *backBO1 =[NSBlockOperation blockOperationWithBlock:^{
            [ARLSynchronisation DownloadResponses:self.runId];
        }];
        
        [[ARLAppDelegate theOQ] addOperation:backBO1];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (ARLNetworking.networkAvailable) {
        
#warning TODO Port NarratorItem
        
        //        if (self.withPicture) {
        //            [ARLFileCloudSynchronizer syncResponseData:self.inquiry.run.managedObjectContext
        //                                         generalItemId:self.generalItem.generalItemId
        //                                          responseType:[NSNumber numberWithInt:PHOTO]];
        //        }
        //        if (self.withVideo) {
        //            [ARLFileCloudSynchronizer syncResponseData:self.inquiry.run.managedObjectContext
        //                                         generalItemId:self.generalItem.generalItemId
        //                                          responseType:[NSNumber numberWithInt:VIDEO]];
        //        }
        //        if (self.withAudio) {
        //            [ARLFileCloudSynchronizer syncResponseData:self.inquiry.run.managedObjectContext
        //                                         generalItemId:self.generalItem.generalItemId
        //                                          responseType:[NSNumber numberWithInt:AUDIO]];
        //        }
        //        if (self.withText) {
        //            [ARLFileCloudSynchronizer syncResponseData:self.inquiry.run.managedObjectContext
        //                                         generalItemId:self.generalItem.generalItemId
        //                                          responseType:[NSNumber numberWithInt:TEXT]];
        //        }
        //        if (self.withValue) {
        //            [ARLFileCloudSynchronizer syncResponseData:self.inquiry.run.managedObjectContext
        //                                         generalItemId:self.generalItem.generalItemId
        //                                          responseType:[NSNumber numberWithInt:NUMBER]];
        //        }
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!self.itemsTable.isHidden) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ARL_SYNCPROGRESS object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ARL_SYNCREADY object:nil];
        
        self.fetchedResultsController = nil;
    }
    
    if (!self.playerButton.isHidden) {
        
        [self.avPlayer removeObserver:self forKeyPath:@"rate"];
        
        if (self.avPlayer.rate != 0.0) {
            [self stopAudio];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                      object:nil];
    }
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate Datasource.

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return numResponses;
}

/*!
 *  Return the number of Rows in a Section of the Collection.
 *
 *  @param view The Collection to be served.
 *  @param section   The section of the data.
 *
 *  @return The number of Rows in the requested section.
 */
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    
    switch (section){
        case RESPONSES:
            count = [self.fetchedResultsController.fetchedObjects count];
            break;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                            forIndexPath:indexPath];

    switch (indexPath.section) {
        case RESPONSES : {
            Response *response = (Response *)[self.fetchedResultsController objectAtIndexPath:indexPath];
            
            // DLog(@"%@ - %@ %@", response.fileName, response.value, response.contentType);
            if (response.account) {
                cell.textLabel.text = [NSString stringWithFormat:@"Author: %@ %@", response.account.givenName, response.account.familyName];
            }
            cell.detailTextLabel.text = @"";

            if (response.fileName) {
                
                if (self.withPicture && [response.responseType isEqualToNumber:[NSNumber numberWithInt:PHOTO]]) {
                    
                    //                        if (response.thumb) {
                    //                            cell.imgView.image = [UIImage imageWithData:response.thumb];
                    //                        } else if (response.data) {
                    //                            cell.imgView.image = [UIImage imageWithData:response.data];
                    //                        } else {
                    
                    cell.imageView.image = [UIImage imageNamed:@"task-photo"];
                    cell.detailTextLabel.text = [response.responseId stringValue];

                    //                        }
                } else if (self.withVideo && [response.responseType isEqualToNumber:[NSNumber numberWithInt:VIDEO]]) {
                    
                    //                        if (response.thumb) {
                    //                            cell.imgView.image = [UIImage imageWithData:response.thumb];
                    //
                    //                            // rotate 90' Right (will al least make portrait videos right).
                    //                            CGAffineTransform rotate = CGAffineTransformMakeRotation( M_PI / 2.0 );
                    //                            [cell.imgView setTransform:rotate];
                    //
                    //                            // create a new bitmap image context
                    //                            UIGraphicsBeginImageContext(cell.imgView.image.size);
                    //
                    //                            // draw original image into the context
                    //                            [cell.imgView.image drawAtPoint:CGPointZero];
                    //
                    //                            // draw icon
                    //                            UIImage *ico = [UIImage imageNamed:@"task-video-overlay"];
                    //
                    //                            // see http://stackoverflow.com/questions/8858404/uiimage-aspect-fit-when-using-drawinrect
                    //                            CGFloat aspect = cell.imgView.image.size.width / cell.imgView.image.size.height;
                    //
                    //                            CGPoint p = CGPointMake(cell.imgView.image.size.width, cell.imgView.image.size.height);
                    //
                    //                            if (ico.size.width / aspect <= ico.size.width) {
                    //                                CGSize s = CGSizeMake(ico.size.width, ico.size.width/(aspect));
                    //                                [ico drawInRect:CGRectMake(p.x-s.width-2, 2, s.width, s.height)];
                    //                            }else {
                    //                                CGSize s = CGSizeMake(ico.size.height*aspect, ico.size.height);
                    //                                [ico drawInRect:CGRectMake(p.x-s.width-2, 2, s.width, s.height)];
                    //                            }
                    //
                    //                            // make image out of bitmap context
                    //                            UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
                    //
                    //                            // free the context
                    //                            UIGraphicsEndImageContext();
                    //
                    //                            cell.imgView.image = retImage;
                    
                    //                        } else {
                    
                    cell.imageView.image = [UIImage imageNamed:@"task-video"];
                    cell.detailTextLabel.text = [response.responseId stringValue];

                    //                        }
                    
                } else if (self.withAudio && [response.responseType isEqualToNumber:[NSNumber numberWithInt:AUDIO]]) {
                    cell.imageView.image = [UIImage imageNamed:@"task-record"];
                    cell.detailTextLabel.text = [response.responseId stringValue];
                }
            } else {
                if (response.value) {
                    NSError * error = nil;
                    NSData *JSONdata = [response.value dataUsingEncoding:NSUTF8StringEncoding];
                    
                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:JSONdata
                                                                               options: NSJSONReadingMutableContainers
                                                                                 error:&error];
                    
                    if (self.withText  && [response.responseType isEqualToNumber:[NSNumber numberWithInt:TEXT]]) {
                        cell.imageView.image = [UIImage imageNamed:@"task-text"];
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"text"]];
                    } else if (self.withValue  && [response.responseType isEqualToNumber:[NSNumber numberWithInt:NUMBER]]) {
                        cell.imageView.image = [UIImage imageNamed:@"task-explore"];
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"value"]];
                    }

                    //                    if ((self.withText  && [response.responseType isEqualToNumber:[NSNumber numberWithInt:TEXT]]) ||
                    //                        (self.withValue && [response.responseType isEqualToNumber:[NSNumber numberWithInt:NUMBER]])) {
                    //
                    //                        NSString *txt;
                    //                        NSError * error = nil;
                    //                        NSData *JSONdata = [response.value dataUsingEncoding:NSUTF8StringEncoding];
                    //                        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:JSONdata
                    //                                                                                   options: NSJSONReadingMutableContainers
                    //                                                                                     error:&error];
                    //
                    //                        if ([dictionary valueForKey:@"text"]) {
                    //                            txt = [dictionary valueForKey:@"text"];
                    //                        } else if ([dictionary valueForKey:@"value"]) {
                    //                            txt = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"value"]];
                    //                        } else {
                    //                            txt = [NSString stringWithFormat:@"%@", response.value];
                    //                        }
                    //
                    //                        // DLog(@"%f x %F", [self getCellSize].width, [self getCellSize].height);
                    //
                    //                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(100,100), NO, 0.0);
                    //                        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                    //                        UIGraphicsEndImageContext();
                    //
                    //                        cell.imageView.image  = [self drawText:txt inImage:cell.imageView.image atPoint:CGPointZero];
                }
            }
        }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case RESPONSES : {
            Response *response = (Response *)[self.fetchedResultsController objectAtIndexPath:indexPath];
            
            NSDate *stamp = [NSDate dateWithTimeIntervalSince1970:[response.timeStamp doubleValue]/1000.f];
            NSString *who;
            if (response.account) {
                who = [NSString stringWithFormat:@"by %@ %@ at %@",response.account.givenName, response.account.familyName, stamp];
            } else {
                who = [NSString stringWithFormat:@"at %@", stamp];
            }
            
            if (response.fileName) {
                BOOL http = [[response.fileName lowercaseString] hasPrefix:@"http://"] || [[response.fileName lowercaseString] hasPrefix:@"https://"] ;
                
                // if (http) {
                CGSize size = [[UIScreen mainScreen] bounds].size;
                CGFloat screenScale = [[UIScreen mainScreen] scale];
                
                ARLWebViewController *controller = (ARLWebViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
                
                switch ([response.responseType intValue]) {
                    case PHOTO: {
                        if (http && ARLNetworking.networkAvailable /*&& !response.thumb*/) {
                            controller.html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head></head><body><img src='%@?thumbnail=1600&crop=true' style='width:100%%;' alt='Loading...'/><hr/><div><h2 style='text-align: center;'>%@, %@</h2></div></body></html>",
                                               response.fileName, [response.fileName pathExtension], who];
                        } else {
                            // NSString *strEncoded = [Base64 encode:data];
                            controller.html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head></head><body><img src='data:%@;base64,%@' style='width:100%%;' /><hr/><div><h2 style='text-align: center;'>%@, %@</h2></div></body></html>",
                                               response.contentType,
                                               [ARLUtils base64forData:response.thumb], [response.fileName pathExtension], who];
                        }
                    }
                        break;
                        
                    case VIDEO: {
                        // See http://www.iandevlin.com/blog/2012/09/html5/html5-media-and-data-uri
                        controller.html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head></head><body><div style='text-align:center;'><video src='%@' controls autoplay width='%f' height='%f' type='%@'/></div><br/><br/><br/><hr/><div><h2 style='text-align: center;'>%@, by %@ %@ at %@</h2></div></body></html>",
                                           response.fileName, size.width * screenScale, size.height * screenScale, response.contentType, [response.fileName pathExtension], response.account.givenName, response.account.familyName, stamp];
                    }
                        break;
                        
                    case AUDIO: {
                        // DLog(@"%@", response.fileName);
                        controller.html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head><script type='text/javascript'>function play() { document.getElementById('audio').play();}</script></head><body onload='play();'><div style='text-align:center; margin-top:100px;'><audio id='audio' src='%@' controls type='%@'></audio></div><br/><br/><br/><hr/><div><h2 style='text-align: center;'>%@, %@</h2></div></body></html>",
                                           response.fileName, response.contentType, [response.fileName pathExtension], who];
                        /*
                         NSError *error = nil;
                         
                         // See http://www.raywenderlich.com/69369/audio-tutorial-ios-playing-audio-programatically-2014-edition
                         self.audioSession = [AVAudioSession sharedInstance];
                         [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
                         
                         ELog(error);
                         
                         NSString *audioString = [response.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                         NSURL *audioUrl = [[NSURL alloc] initWithString:audioString];
                         NSData *audioFile = [[NSData alloc] initWithContentsOfURL:audioUrl options:NSDataReadingMappedIfSafe error:&error];
                         
                         self.audioPlayer = [[AVAudioPlayer alloc] initWithData:audioFile error:&error];
                         self.audioPlayer.volume=1.0;
                         
                         [self.audioPlayer prepareToPlay];
                         [self.audioPlayer play];
                         */
                    }
                        break;
                }
                
                if (controller && controller.html) {
                    [self.navigationController pushViewController:controller animated:FALSE];
                } else {
                    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                                          message:NSLocalizedString(@"NotSynced", @"NotSynced")
                                                                         delegate:nil
                                                                cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                                otherButtonTitles:nil, nil];
                    [myAlertView show];
                }
                
            } else {
                
                //TODO: Textarea does not forward clicks.
                
                // SEE http://iphonedevsdk.com/forum/iphone-sdk-development/82096-onclick-event-in-textfield.html
                //  (void)textFieldDidBeginEditing:(UITextField *)textField
                
                if (response.value) {
                    NSError *error = nil;
                    NSData *JSONdata = [response.value dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:JSONdata
                                                                               options: NSJSONReadingMutableContainers
                                                                                 error:&error];
                    NSString *msg;
                    
                    if ([dictionary valueForKey:@"text"]) {
                        msg = [NSString stringWithFormat:@"%@\r\n\r\n%@", [dictionary valueForKey:@"text"], who];
                    } else if ([dictionary valueForKey:@"value"]) {
                        msg = [NSString stringWithFormat:@"%@\r\n\r\n%@", [dictionary valueForKey:@"value"], who];
                    } else {
                        msg = [NSString stringWithFormat:@"%@\r\n\r\n%@", response.value, who];
                    }
                    
                    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Value", @"Value")
                                                                          message:msg
                                                                         delegate:nil
                                                                cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                                otherButtonTitles:nil, nil];
                    [myAlertView show];
                }
            }
        }
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate

/*!
 *  Handle recording of Videos and taking Photo with the iOS Api.
 *  Sync responses after selecting a Video or Photo.
 *
 *  @param picker <#picker description#>
 *  @param info   <#info description#>
 */
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //    NSString *url = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    //    DLog(@"Image Url: %@", url);
    
    // see http://stackoverflow.com/questions/3837115/display-image-from-url-retrieved-from-alasset-in-iphone
    // see http://stackoverflow.com/questions/8085267/load-an-image-to-uiimage-from-a-file-path-to-the-asset-library
    
    // url = assets-library://asset/asset.JPG?id=A4ECA96B-4B7B-43B7-B3A0-3D83FDEC68B6&ext=JPG
    
    if (image) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        [self createImageResponse:imageData
                            width:[NSNumber numberWithFloat:image.size.width]
                           height:[NSNumber numberWithFloat:image.size.height]];
    } else {
        id object = [info objectForKey:UIImagePickerControllerMediaURL];
        
        DLog(@"Dict %@", info);
        DLog(@"Object %@", [object class ]);
        
        // Zie http://stackoverflow.com/questions/20282672/record-save-and-or-convert-video-in-mp4-format
        // voor conversie nar mp4
        
        NSData* videoData = [NSData dataWithContentsOfURL:object];
        [self createVideoResponse:videoData];
        
        // [picker dismissViewControllerAnimated:YES completion:NULL];
    }
    
    [ARLCoreDataUtils CreateOrUpdateAction:self.runId
                                activeItem:self.activeItem
                                      verb:answer_given_action];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    if (ARLNetworking.networkAvailable) {
#warning TODO Port NarratorItem
        // [ARLCloudSynchronizer syncResponses: self.activeItem.managedObjectContext];
    }
}

#pragma mark - UINavigationControllerDelegate

// See http://stackoverflow.com/questions/8528880/enabling-the-photo-library-button-on-the-uiimagepickercontroller
- (void) navigationController: (UINavigationController *)navigationController
       willShowViewController: (UIViewController *)viewController
                     animated: (BOOL) animated {
    
    // 1) video/photo
    // 2) video -> front/back (standard user-ineterface)
    // 3) photo -> camera/roll/library front/back (not available as the navigationbar obscures the default interface!)
    
    // Camera Available.
    switch (self.mode) {
            
            // Photo
        case UIImagePickerControllerCameraCaptureModePhoto:
            
            switch (self.imagePickerController.sourceType) {
                    
                    // Library
                case UIImagePickerControllerSourceTypePhotoLibrary: {
                    UIBarButtonItem* cancelbutton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtn:)];
                    
                    viewController.toolbarItems = [NSArray arrayWithObject:cancelbutton];
                    
                    viewController.navigationController.toolbarHidden = NO;
                    
                    UIBarButtonItem* cambutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera:)];
                    UIBarButtonItem* rollbutton = [[UIBarButtonItem alloc] initWithTitle:@"Roll" style:UIBarButtonItemStylePlain target:self action:@selector(showRoll:)];
                    
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:cambutton, rollbutton, nil];
                    } else {
                        viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: rollbutton, nil];
                    }
                }
                    break;
                    
                    // Camera
                case UIImagePickerControllerSourceTypeCamera:
                {
                    viewController.navigationController.toolbarHidden = YES;
                    
                    UIBarButtonItem* libbutton = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStylePlain target:self action:@selector(showLibrary:)];
                    UIBarButtonItem* rollbutton = [[UIBarButtonItem alloc] initWithTitle:@"Roll" style:UIBarButtonItemStylePlain target:self action:@selector(showRoll:)];
                    
                    viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:libbutton, rollbutton, nil];
                    
                    viewController.navigationItem.title = @"Take Photo";
                    viewController.navigationController.navigationBarHidden = NO;
                }
                    break;
                    
                    // Saved Photo's.
                case UIImagePickerControllerSourceTypeSavedPhotosAlbum: {
                    UIBarButtonItem* cancelbutton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtn:)];
                    
                    viewController.toolbarItems = [NSArray arrayWithObject:cancelbutton];
                    
                    viewController.navigationController.toolbarHidden = NO;
                    
                    UIBarButtonItem* cambutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera:)];
                    UIBarButtonItem* libbutton = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStylePlain target:self action:@selector(showLibrary:)];
                    
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:cambutton, libbutton, nil];
                    } else {
                        viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: libbutton, nil];
                    }
                }
                    break;
            }
            break;
            
            // Video
        case UIImagePickerControllerCameraCaptureModeVideo:
            //
            break;
    }
}

#pragma mark - UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    CGRect newBounds = webView.bounds;
    newBounds.size.height = webView.scrollView.contentSize.height;
    webView.bounds = newBounds;
    
    [self applyConstraints];
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
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"OK", @"OK")]) {
        UITextField *alertTextField = [alertView textFieldAtIndex:0];
        
        NSString *trimmed = [alertTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        switch (alertView.tag) {
            case 1: {
                
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                NSString *decimalSymbol = [formatter decimalSeparator];
                
                trimmed = [trimmed stringByReplacingOccurrencesOfString:@"." withString:decimalSymbol];
                trimmed = [trimmed stringByReplacingOccurrencesOfString:@"," withString:decimalSymbol];
                
                NSNumber *number = [formatter numberFromString:trimmed];
                
                if (number != nil) {
                    [self createValueResponse:trimmed //[trimmed stringByReplacingOccurrencesOfString:decimalSymbol withString:@"."]
                                      withRun:self.run
                              withGeneralItem:self.activeItem];
                } else {
                    // Invalid Number.
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                                    message:NSLocalizedString(@"Invalid Number", @"Invalid Number")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
                break;
            case 2:
                [self createTextResponse: trimmed
                                 withRun:self.run
                         withGeneralItem:self.activeItem];
                break;
        }
        
        [ARLCoreDataUtils CreateOrUpdateAction:self.runId
                                    activeItem:self.activeItem
                                          verb:answer_given_action];
        
        if (ARLNetworking.networkAvailable) {
#warning TODO Port NarratorItem
            // [ARLCloudSynchronizer  :self.activeItem.managedObjectContext];
        }
        
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
        
        ELog(error);
        
        DLog(@"RESPONSES: %d",[self.fetchedResultsController.fetchedObjects count]);
    } else if ([alertView.message isEqualToString: NSLocalizedString(@"Delete Collected Item?", @"Delete Collected Item?")]) {
        if ([title isEqualToString:NSLocalizedString(@"YES", @"YES")]) {
            NSIndexPath *path = [NSIndexPath indexPathForItem:alertView.tag inSection:RESPONSES];
            
            Response *response = (Response *)[self.fetchedResultsController objectAtIndexPath:path];
            
            response.revoked = @YES;
            response.synchronized = @NO;
            
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

            NSError *error;
            [self.fetchedResultsController performFetch:&error];
            ELog(error);
            
            [self.itemsTable reloadData];
        } else {
            // DLog("NOT Deleting Item %d", alertView.tag);
        }
    }

}

#pragma mark UIGestureRecognizer.

-(void)gestureHandler:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if(UIGestureRecognizerStateBegan == gestureRecognizer.state)
    {//your code here
        
        /*uncomment this to get which exact row was long pressed */
        CGPoint location = [gestureRecognizer locationInView:self.itemsTable];
        
        NSIndexPath *indexPath = [self.itemsTable indexPathForRowAtPoint:location];
        
        if (indexPath) {
            // Check Ownership of Collected Item.
            
            // DLog(@"CollectionItem: %@", indexPath);
            
            Response *response = (Response *)[self.fetchedResultsController objectAtIndexPath:indexPath];

            if ([ARLNetworking isLoggedIn] &&
                response.account &&
                response.account.localId == [ARLNetworking CurrentAccount].localId &&
                response.account.accountType == [ARLNetworking CurrentAccount].accountType
                ) {
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                                      message:NSLocalizedString(@"Delete Collected Item?", @"Delete Collected Item?")
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"NO", @"NO")
                                                            otherButtonTitles:NSLocalizedString(@"YES", @"YES"), nil];
                myAlertView.tag = indexPath.row;
                
                [myAlertView show];
            } else {
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                                      message:NSLocalizedString(@"You can only delete your own collected items.", @"You can only delete your own collected items.")
                                                                     delegate:nil
                                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                            otherButtonTitles:nil, nil];
                [myAlertView show];
            }
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
    return  @"ResponseItemCell";
}

- (void)setActiveItem:(GeneralItem *)activeItem {
    _activeItem = activeItem;
    
    NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:self.activeItem.json];
    
    self.openQuestion = [json valueForKey:@"openQuestion"];
}

- (GeneralItem *)activeItem {
    return _activeItem;
}

- (void)setRunId:(NSNumber *)runId {
    _runId = runId;
    
    self.run = [Run MR_findFirstByAttribute:@"runId" withValue:self.runId];
}

- (NSNumber *)runId {
    return _runId;
}

/*
 * To set the current Position of the
 * playing audio File
 */
- (void)setCurrentAudioTime:(NSTimeInterval)value {
    //[self.avlayer setCurrentTime:value];
    CMTime current = CMTimeMakeWithSeconds(value, 1);
    
    [self.avPlayer seekToTime:current];
}

- (NSTimeInterval)CurrentAudioTime {
    CMTime current = self.avPlayer.currentTime;
    
    if (CMTIME_IS_VALID(current)) {
        return [[NSNumber numberWithDouble:current.value/current.timescale] doubleValue];
    }
    return [[NSNumber numberWithDouble:0.0] doubleValue];
}

/*
 * Get the whole length of the audio file
 */
- (NSNumber *)AudioDuration {
    CMTime duration = self.avPlayer.currentItem.asset.duration;
    
    if (CMTIME_IS_VALID(duration)) {
        return [NSNumber numberWithFloat:duration.value/duration.timescale];
    }
    return [NSNumber numberWithInt:0];
}

#pragma mark - Methods

- (void) applyConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,             @"view",
                                     
                                     self.backgroundImage,  @"backgroundImage",
                                     
                                     self.itemsTable,       @"itemsTable",
                                     self.descriptionText,  @"descriptionText",
                                     
                                     self.playerButton,     @"playerButton",
                                     self.playerSlider,     @"playerSlider",
                                     self.durationLabel,    @"durationLabel",
                                     self.elapsedLabel,     @"elapsedLabel",
                                     
                                     nil];
    
    // See http://stackoverflow.com/questions/17772922/can-i-use-autolayout-to-provide-different-constraints-for-landscape-and-portrait
    // See https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/Bars.html
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.itemsTable.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionText.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.playerButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.playerSlider.translatesAutoresizingMaskIntoConstraints = NO;
    self.durationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.elapsedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[itemsTable]-|"
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
        if (self.playerButton.isHidden) {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[itemsTable]-|"
                                                                              options:NSLayoutFormatDirectionLeadingToTrailing
                                                                              metrics:nil
                                                                                views:viewsDictionary]];
        } else {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[playerButton(==70)]-[itemsTable]-|"
                                                                              options:NSLayoutFormatDirectionLeadingToTrailing
                                                                              metrics:nil
                                                                                views:viewsDictionary]];
        }
    } else {
        if (self.playerButton.isHidden) {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-[descriptionText(==%f)]-[itemsTable]-|",
                                                                                       self.descriptionText.bounds.size.height]
                                                                              options:NSLayoutFormatDirectionLeadingToTrailing
                                                                              metrics:nil
                                                                                views:viewsDictionary]];
        } else {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-[descriptionText(==%f)]-[playerButton(==70)]-[itemsTable]-|",
                                                                                       self.descriptionText.bounds.size.height]
                                                                              options:NSLayoutFormatDirectionLeadingToTrailing
                                                                              metrics:nil
                                                                                views:viewsDictionary]];
        }
    }
    
    
    if (!self.playerButton.isHidden) {
        // Fix player Horizontal.
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[playerButton(==70)]-[durationLabel]-[playerSlider]-[elapsedLabel]-|"
                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
        
        // Vertical Center rest of player.
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.playerButton
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.durationLabel
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.playerButton
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.playerSlider
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.playerButton
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.elapsedLabel
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0]];
    }
}

/*!
 *  Create a UIBarButton with a background image depending on the enabled state.
 *
 *  See http://stackoverflow.com/questions/7101608/setting-image-for-uibarbuttonitem-image-stretched
 *
 *  @param imageString The name of the Image.
 *  @param enabled     If YES the button is enabled else disabled (and having a grayed image).
 *  @param selector    The selector to use when the button is tapped.
 *
 *  @return The created UIBarButtonItem.
 */
- (UIBarButtonItem *)addUIBarButtonWithImage:(NSString *)imageString enabled:(BOOL)enabled action:(SEL)selector {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    
    if (enabled) {
        [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    
    // button.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIImage * image = [UIImage imageNamed:imageString];
    if (!enabled) {
        image = [self grayishImage:image];
    }
    
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setEnabled:enabled];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

/*!
 *  Transform the image in grayscale, while keeping its transparency.
 *
 *  See http://stackoverflow.com/questions/1298867/convert-image-to-grayscale
 *
 *  @param inputImage The Image to be grayed.
 *
 *  @return The GrayScale Image.
 */
- (UIImage *)grayishImage:(UIImage *)inputImage {
    UIGraphicsBeginImageContextWithOptions(inputImage.size, NO, inputImage.scale);
    
    @autoreleasepool {
        CGRect imageRect = CGRectMake(0.0f, 0.0f, inputImage.size.width, inputImage.size.height);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        // Draw a white background
        CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 1.0f);
        CGContextFillRect(ctx, imageRect);
        
        // Draw the luminosity on top of the white background to get grayscale
        [inputImage drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0f];
        
        // Apply the source image's alpha
        [inputImage drawInRect:imageRect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
        
    }
    
    UIImage* grayscaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return grayscaleImage;
}

/*!
 *  Process the JSON (the openQuestion object) that is stored with the GeneralItem.
 *
 *  @param jsonDict The openQuestion object in JSON format.
 */
- (void) processJsonSetup:(NSDictionary *) jsonDict {
    self.isVisible = YES;
    
    self.withAudio =   [(NSNumber*)[jsonDict objectForKey:@"withAudio"] intValue] ==1;
    self.withPicture = [(NSNumber*)[jsonDict objectForKey:@"withPicture"] intValue] ==1;
    self.withText =    [(NSNumber*)[jsonDict objectForKey:@"withText"] intValue] ==1;
    self.withValue =   [(NSNumber*)[jsonDict objectForKey:@"withValue"] intValue] ==1;
    self.withVideo =   [(NSNumber*)[jsonDict objectForKey:@"withVideo"] intValue] ==1;
    
    self.textDescription =  [jsonDict objectForKey:@"textDescription"];
    self.valueDescription = [jsonDict objectForKey:@"valueDescription"];
    
    UIBarButtonItem *audioButton = [self addUIBarButtonWithImage:@"task-record"  enabled:self.withAudio   action:@selector(collectAudio)];
    UIBarButtonItem *imageButton = [self addUIBarButtonWithImage:@"task-photo"   enabled:self.withPicture action:@selector(collectImage)];
    UIBarButtonItem *videoButton = [self addUIBarButtonWithImage:@"task-video"   enabled:self.withVideo   action:@selector(collectVideo)];
    UIBarButtonItem *noteButton  = [self addUIBarButtonWithImage:@"task-explore" enabled:self.withValue   action:@selector(collectNumber)];
    UIBarButtonItem *textButton  = [self addUIBarButtonWithImage:@"task-text"    enabled:self.withText    action:@selector(collectText)];
    
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *buttons = [[NSArray alloc] initWithObjects:audioButton, flexButton, imageButton, flexButton, videoButton, flexButton, noteButton, flexButton, textButton, nil];
    
    [self setToolbarItems:buttons];
}

- (void)setupFetchedResultsController {
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    
    if (self.withPicture) {
        tmp = [NSMutableArray arrayWithArray:[tmp arrayByAddingObject:
                                              [NSPredicate predicateWithFormat:@"responseType=%@", [NSNumber numberWithInt:PHOTO]]]];
    }
    if (self.self.withVideo) {
        tmp = [NSMutableArray arrayWithArray:[tmp arrayByAddingObject:
                                              [NSPredicate predicateWithFormat:@"responseType=%@", [NSNumber numberWithInt:VIDEO]]]];
    }
    if (self.withAudio) {
        tmp = [NSMutableArray arrayWithArray:[tmp arrayByAddingObject:
                                              [NSPredicate predicateWithFormat:@"responseType=%@", [NSNumber numberWithInt:AUDIO]]]];
    }
    if (self.withText) {
        tmp = [NSMutableArray arrayWithArray:[tmp arrayByAddingObject:
                                              [NSPredicate predicateWithFormat:@"responseType=%@", [NSNumber numberWithInt:TEXT]]]];
    }
    if (self.withValue) {
        tmp = [NSMutableArray arrayWithArray:[tmp arrayByAddingObject:
                                              [NSPredicate predicateWithFormat:@"responseType=%@", [NSNumber numberWithInt:NUMBER]]]];
    }

    // See http://stackoverflow.com/questions/4476026/add-additional-argument-to-an-existing-nspredicate
    NSPredicate *orPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:tmp];
    NSPredicate *andPredicate = [NSPredicate predicateWithFormat:@"run.runId = %lld AND generalItem.generalItemId = %lld AND (revoked=NULL OR revoked=%@)",
                                 [self.runId longLongValue],
                                 [self.activeItem.generalItemId longLongValue],
                                 @NO];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:andPredicate, orPredicate, nil]];

    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context]; //was MR_DefaultContext
    
    NSFetchRequest *request =  [Response MR_requestAllSortedBy:@"timeStamp"
                                                     ascending:YES
                                                 withPredicate:predicate
                                                     inContext:ctx];
    // request.fetchBatchSize = 8;

    self.fetchedResultsController = [Response MR_fetchController:request
                                                        delegate:self
                                                    useFileCache:NO
                                                       groupedBy:nil
                                                       inContext:ctx];
}

-(UIImage *) drawText:(NSString*) text inImage:(UIImage*)image atPoint:(CGPoint)point
{
    //See http://stackoverflow.com/questions/4670851/nsstring-drawatpoint-blurry
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    
    //See http://stackoverflow.com/questions/4670851/nsstring-drawatpoint-blurry
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), true);
    
    //[image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    rect = CGRectInset(rect, 5, 5);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{
                                 // UIFont, default Helvetica(Neue) 12
                                 NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                 NSParagraphStyleAttributeName: paragraphStyle,
                                 NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSBackgroundColorAttributeName: [UIColor whiteColor]
                                 };
    
    //    NSStringDrawingContext *drawingContext = [[NSStringDrawingContext alloc] init];
    //    drawingContext.minimumScaleFactor = 0.5; // Half the font siz
    
    [text drawInRect:rect withAttributes:attributes]; //CGRectIntegral(rect)
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

/*!
 *  Record Audio.
 */
- (void) collectAudio {
    ARLAudioRecorderViewController *controller = [[ARLAudioRecorderViewController alloc] init];
    
    // controller.inquiry = self.inquiry;
  
   // TODO Move saving to code into viewcontroller?
    controller.activeItem = self.activeItem;
    controller.run = self.run;
    controller.controller = self;
    
    [self.navigationController pushViewController:controller animated:TRUE];
}

/*!
 *  Request a Number.
 */
- (void) collectNumber
{
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:self.valueDescription
                                                          message:NSLocalizedString(@"Enter Number", @"Enter Number")
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
    
    //    self.valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    //    [self.valueTextField setBackgroundColor:[UIColor whiteColor]];
    //
    //    [myAlertView addSubview:self.valueTextField];
    
    myAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    myAlertView.tag = 1;
    
    [myAlertView show];
    
    // see: http://stackoverflow.com/questions/10579658/uialertview-uialertviewstylesecuretextinput-numeric-keyboard
    [[myAlertView textFieldAtIndex:0] setDelegate:self];
    [[myAlertView textFieldAtIndex:0] resignFirstResponder];
    [[myAlertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [[myAlertView textFieldAtIndex:0] becomeFirstResponder];
}

/*!
 *  Request Text.
 */
- (void) collectText
{
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:self.textDescription
                                                          message:NSLocalizedString(@"Enter Text",@"Enter Text")
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
    
    myAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    myAlertView.tag = 2;
    
    //self.valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    //[self.valueTextField setBackgroundColor:[UIColor whiteColor]];
    // see http://stackoverflow.com/questions/9407338/xcode-how-to-uialertview-with-a-text-field-on-a-loop-until-correct-value-en
    
    //[myAlertView addSubview:self.valueTextField];
    [myAlertView show];
}

/*!
 *  Record Video.
 */
- (void) collectVideo {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        if (!self.imagePickerController) {
            self.imagePickerController = [[UIImagePickerController alloc] init];
            self.imagePickerController.delegate = self;
            self.mode = UIImagePickerControllerCameraCaptureModeVideo;
        }
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            self.imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
            
            if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
                self.imagePickerController.cameraDevice= UIImagePickerControllerCameraDeviceRear;
            } else {
                self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
        } else {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }

        self.imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];

        [self.navigationController presentViewController:self.imagePickerController animated:YES completion:nil];
    } else {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                              message:NSLocalizedString(@"No Camera available",@"No Camera available")
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                    otherButtonTitles:nil];
        
        [myAlertView show];
    }
}

/*!
 *  Take a Picture.
 */
- (void) collectImage {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ) {
        if (!self.imagePickerController) {
            self.imagePickerController = [[UIImagePickerController alloc] init];
            self.imagePickerController.delegate = self;
            self.mode = UIImagePickerControllerCameraCaptureModePhoto;
        }
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        // Place image picker on the screen
        [self.navigationController presentViewController:self.imagePickerController animated:YES completion:nil];
    } else {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                              message:NSLocalizedString(@"No Camera available",@"No Camera available")
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                    otherButtonTitles:nil];
        
        [myAlertView show];
    }
}

- (void) createTextResponse:(NSString *)text
                    withRun:(Run*)run
            withGeneralItem:(GeneralItem *)generalItem {
    
    NSDictionary *jsonDict= [[NSDictionary alloc] initWithObjectsAndKeys:
                             text, @"text", nil];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          [ARLUtils jsonString:jsonDict],                                         @"value",
                          [NSNumber numberWithInt:0],                                             @"responseId",
                          [NSNumber numberWithBool:NO],                                           @"synchronized",
                          [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000], @"timeStamp",
                          [NSNumber numberWithInt:TEXT],                                          @"responseType",
                          nil];
    
    [self responseWithDictionary:data];
}

- (void) createValueResponse:(NSString *)value
                     withRun:(Run *)run
             withGeneralItem:(GeneralItem *)generalItem {
    
    NSDictionary *jsonDict= [[NSDictionary alloc] initWithObjectsAndKeys:
                             value, @"value",
                             nil];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          [ARLUtils jsonString:jsonDict],                                         @"value",
                          [NSNumber numberWithInt:0],                                             @"responseId",
                          [NSNumber numberWithBool:NO],                                           @"synchronized",
                          [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000], @"timeStamp",
                          [NSNumber numberWithInt:NUMBER],                                        @"responseType",
                          nil];
    
    [self responseWithDictionary:data];
}

- (void) createImageResponse:(NSData *)data
                       width:(NSNumber*)width
                      height:(NSNumber *)height {
    
    u_int32_t random = arc4random();
    NSString *fileName =[NSString stringWithFormat:@"%u.%@", random, @"jpg"];
    
    // Create thumb here...
    UIImage *img = [[UIImage alloc] initWithData:data];
    NSData *thumb = UIImageJPEGRepresentation([img thumbnailImage:320 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationDefault], 1.0);
    
    NSDictionary *jsonDict= [[NSDictionary alloc] initWithObjectsAndKeys:
                             data,                                                                   @"data",
                             [NSNumber numberWithInt:0],                                             @"responseId",
                             [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000], @"timeStamp",
                             [NSNumber numberWithBool:NO],                                           @"synchronized",
                             width,                                                                  @"width",
                             height,                                                                 @"height",
                             @"application/jpg",                                                     @"contentType",
                             [NSNumber numberWithInt:PHOTO],                                         @"responseType",
                             fileName,                                                               @"fileName",
                             thumb,                                                                  @"thumb",
                             nil];
    
    [self responseWithDictionary:jsonDict];
}

- (void) createVideoResponse:(NSData *)data {
    u_int32_t random = arc4random();
    NSString *fileName =[NSString stringWithFormat:@"%u.%@", random, @"mov"];
    
    NSDictionary *jsonDict= [[NSDictionary alloc] initWithObjectsAndKeys:
                             data,                                                                   @"data",
                             [NSNumber numberWithInt:0],                                             @"responseId",
                             [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000], @"timeStamp",
                             [NSNumber numberWithBool:NO],                                           @"synchronized",
                             @"video/quicktime",                                                     @"contentType",
                             [NSNumber numberWithInt:VIDEO],                                         @"responseType",
                             fileName,                                                               @"fileName",
                             nil];
    
    [self responseWithDictionary:jsonDict];
}

- (void) createAudioResponse:(NSData *)data
                    fileName:(NSString *)fileName {
    NSString *contentType = @"audio/aac";
    
    if ([fileName hasSuffix:@".m4a"]) {
        contentType = @"audio/aac";
    } else  if ([fileName hasSuffix:@".mp3"]) {
        contentType = @"audio/mp3";
    } else  if ([fileName hasSuffix:@".amr"]) {
        contentType = @"audio/amr";
    }
    
    NSDictionary *jsonDict= [[NSDictionary alloc] initWithObjectsAndKeys:
                             data,                                                                   @"data",
                             [NSNumber numberWithInt:0],                                             @"responseId",
                             [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000], @"timeStamp",
                             [NSNumber numberWithBool:NO],                                           @"synchronized",
                             contentType,                                                            @"contentType",
                             [NSNumber numberWithInt:AUDIO],                                         @"responseType",
                             fileName,                                                               @"fileName",
                             nil];
    
    [self responseWithDictionary:jsonDict];
}

- (Response *)responseWithDictionary:(NSDictionary *)respDict
{
    //    @property (nonatomic, retain) NSString * contentType;
    //    @property (nonatomic, retain) NSData * data;
    //    @property (nonatomic, retain) NSString * fileName;
    //    @property (nonatomic, retain) NSNumber * height;
    //    @property (nonatomic, retain) NSNumber * responseId;
    //    @property (nonatomic, retain) NSNumber * synchronized;
    //    @property (nonatomic, retain) NSData * thumb;
    //    @property (nonatomic, retain) NSNumber * timeStamp;
    //    @property (nonatomic, retain) NSString * value;
    //    @property (nonatomic, retain) NSNumber * width;
    //    @property (nonatomic, retain) NSNumber * responseType;
    //    @property (nonatomic, retain) NSNumber * lat;
    //    @property (nonatomic, retain) NSNumber * lng;
    //    @property (nonatomic, retain) Account *account;
    //    @property (nonatomic, retain) GeneralItem *generalItem;
    //    @property (nonatomic, retain) Run *run;
    
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_defaultContext];
    
    Response *response = (Response *)[ARLUtils ManagedObjectFromDictionary:respDict
                                                                entityName:[Response MR_entityName]
                                                                nameFixups:[NSDictionary dictionaryWithObjectsAndKeys:nil]
                                                                dataFixups:[NSDictionary dictionaryWithObjectsAndKeys:nil]
                                                            managedContext:ctx];
    
    // Fixup object references.
    response.account = [[ARLNetworking CurrentAccount] MR_inContext:ctx];
    response.generalItem = [self.activeItem MR_inContext:ctx];
    response.run = [self.run MR_inContext:ctx];
    response.synchronized = @NO;
    response.revoked = @NO;
    
    [ctx MR_saveToPersistentStoreAndWait];
    
    // Update Query annd Table.
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    ELog(error);
    
    DLog("Feched %d Records", [[self.fetchedResultsController fetchedObjects] count]);
    
    [self.itemsTable reloadData];
    
    return response;
}

/*
 * Format the float time values like duration
 * to format with minutes and seconds
 */
-(NSString*)timeFormat:(NSNumber *)value {
    
    float minutes = floor(lroundf([value floatValue])/60);
    float seconds = lroundf([value floatValue]) - (minutes * 60);
    
    int roundedSeconds = lroundf(seconds);
    int roundedMinutes = lroundf(minutes);
    
    NSString *time = [[NSString alloc]
                      initWithFormat:@"%d:%02d",
                      roundedMinutes, roundedSeconds];
    return time;
}


- (void)togglePlaying {
    [self.timer invalidate];
    
    if (!self.isPaused) {
        [self.playerButton setBackgroundImage:[UIImage imageNamed:@"black_pause"]
                                     forState:UIControlStateNormal];
        
        //start a timer to update the time label display
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self
                                                    selector:@selector(updateTime:)
                                                    userInfo:nil
                                                     repeats:YES];
        
        [self playAudio];
        
        self.isPaused = TRUE;
    } else {
        //player is paused and Button is pressed again
        [self.playerButton setBackgroundImage:[UIImage imageNamed:@"black_play"]
                                     forState:UIControlStateNormal];
        
        [self pauseAudio];
        
        self.isPaused = FALSE;
    }
}

/*
 * Simply fire the play Event
 */
- (void)playAudio {
    [self.avPlayer play];
}

/*
 * Simply fire the pause Event
 */
- (void)pauseAudio {
    [self.avPlayer pause];
}

/*
 * Simply fire the stop Event
 */
- (void)stopAudio {
    [self.avPlayer pause];
}

- (void)resetPlayer {
    [self.timer invalidate];
    
    [self.playerButton setBackgroundImage:[UIImage imageNamed:@"black_play"]
                                 forState:UIControlStateNormal];
    
    self.playerSlider.value = 0.0;
    self.playerSlider.maximumValue = [self.AudioDuration floatValue];
    self.CurrentAudioTime = 0.0;
    
    self.elapsedLabel.text = @"0:00";
    self.durationLabel.text = [NSString stringWithFormat:@"-%@", [self timeFormat:self.AudioDuration]];
    
    self.isPaused = FALSE;
}

#pragma mark - Actions

// See http://stackoverflow.com/questions/8528880/enabling-the-photo-library-button-on-the-uiimagepickercontroller
- (void) showCamera: (id) sender {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
}

// See http://stackoverflow.com/questions/8528880/enabling-the-photo-library-button-on-the-uiimagepickercontroller
- (void) showLibrary: (id) sender {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

// See http://stackoverflow.com/questions/8528880/enabling-the-photo-library-button-on-the-uiimagepickercontroller
- (void) showRoll: (id) sender {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
}

// See http://stackoverflow.com/questions/8528880/enabling-the-photo-library-button-on-the-uiimagepickercontroller
- (void) cancelBtn: (id) sender {
    // self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self.imagePickerController dismissViewControllerAnimated:YES completion:NULL];
}

/*
  * Updates the time label display and
  * the current value of the slider
  * while audio is playing
  */
- (void)updateTime:(NSTimer *)timer {
    //to don't update every second. When scrubber is mouseDown the the slider will not set
    if (!self.scrubbing) {
        self.playerSlider.value = self.CurrentAudioTime;
    }
    self.elapsedLabel.text = [NSString stringWithFormat:@"%@",
                              [self timeFormat:[NSNumber numberWithDouble:self.CurrentAudioTime]]];
    self.durationLabel.text = [NSString stringWithFormat:@"-%@",
                               [self timeFormat:@([self.AudioDuration doubleValue] - self.CurrentAudioTime)]];
}

/*
  * PlayButton is pressed
  * plays or pauses the audio and sets
  * the play/pause Text of the Button
  */
- (IBAction)playerAction:(UIButton *)sender {
    [self togglePlaying];
}

- (IBAction)sliderAction:(UISlider *)sender {
    //if scrubbing update the timestate, call updateTime faster not to wait a second and dont repeat it
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(updateTime:)
                                   userInfo:nil
                                    repeats:NO];
    
    self.CurrentAudioTime = self.playerSlider.value;
    
    self.scrubbing = FALSE;
}

- (IBAction)isScrubbing:(UISlider *)sender {
    self.scrubbing = TRUE;
}

#pragma mark - Notifications.

- (void)syncProgress:(NSNotification*)notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(syncProgress:)
                               withObject:notification
                            waitUntilDone:YES];
        return;
    }
    
    NSString *recordType = notification.object;
    
    // DLog(@"syncProgress: %@", recordType);
    
    if ([NSStringFromClass([Response class]) isEqualToString:recordType]) {
        //
    }
}

- (void)syncReady:(NSNotification*)notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(syncReady:)
                               withObject:notification
                            waitUntilDone:YES];
        return;
    }
    
    NSString *recordType = notification.object;
    
    // DLog(@"syncReady: %@", recordType);
    
    if ([NSStringFromClass([Response class]) isEqualToString:recordType]) {
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
        ELog(error);
        
        DLog("Feched %d Records", [[self.fetchedResultsController fetchedObjects] count]);
        
        [self.itemsTable reloadData];
    } else {
        DLog(@"syncReady, unhandled recordType: %@", recordType);
    }
}

#pragma mark - Observers

-(void)itemDidFailPlaying:(NSNotification *) notification {
    [self resetPlayer];
}

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    // Will be called when AVPlayer finishes playing playerItem
    [ARLCoreDataUtils CreateOrUpdateAction:self.runId
                                activeItem:self.activeItem
                                      verb:complete_action];
    
    [self resetPlayer];
}

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
    if ([keyPath isEqualToString:@"rate"]) {
        if (self.avPlayer.rate == 0.0) {
            CMTime time = self.avPlayer.currentTime;
            NSTimeInterval timeSeconds = CMTimeGetSeconds(time);
            CMTime duration = self.avPlayer.currentItem.asset.duration;
            NSTimeInterval durationSeconds = CMTimeGetSeconds(duration);
            
            if (timeSeconds >= durationSeconds - 1.0) {
                //song reached end
                
                [ARLCoreDataUtils CreateOrUpdateAction:self.runId
                                            activeItem:self.activeItem
                                                  verb:complete_action];
                
                [self resetPlayer];
            }
        }
    }
}

@end
