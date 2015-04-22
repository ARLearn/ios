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

@property (readonly, nonatomic) CGFloat noColumns;
@property (readonly, nonatomic) CGFloat columnInset;

@property (readwrite, nonatomic) UIImagePickerControllerCameraCaptureMode mode;

@property (strong, nonatomic) AVAudioSession *audioSession;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (strong, nonatomic) NSDictionary *openQuestion;
@property (strong, nonatomic) Run *run;

@end

@implementation ARLNarratorItemViewController

//@synthesize inquiry = _inquiry;
//@synthesize generalItem = _generalItem;
//@synthesize account = _account;

@synthesize activeItem = _activeItem;
@synthesize runId = _runId;
@synthesize run;

#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.opaque = NO;
    self.collectionView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDictionary *jsonDict = [NSKeyedUnarchiver unarchiveObjectWithData:self.activeItem.json];
    
    self.navigationItem.title = self.activeItem.name;
    
    [self processJsonSetup:[jsonDict objectForKey:@"openQuestion"]];
    
    self.navigationController.toolbarHidden = NO;
    
#warning TODO Port NarratorItem
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(syncProgress:)
    //                                                 name:INQ_SYNCPROGRESS
    //                                               object:nil];
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(syncReady:)
    //                                                 name:INQ_SYNCREADY
    //                                               object:nil];
    
    [self setupFetchedResultsController];
    
    [self.collectionView reloadData];
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
    
#warning TODO Port NarratorItem
    
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:INQ_SYNCPROGRESS object:nil];
    //
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:INQ_SYNCREADY object:nil];
    
    self.navigationController.toolbarHidden = YES;
    
    self.fetchedResultsController = nil;
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionView Datasource.

/*!
 *  The number of sections in a Collection.
 *
 *  see http://www.raywenderlich.com/22324/beginning-uicollectionview-in-ios-6-part-12
 *
 *  @param view The Table to be served.
 *
 *  @return The number of sections.
 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)view
{
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
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    switch (section){
        case RESPONSES:
            count = [self.fetchedResultsController.fetchedObjects count];
            break;
    }
    
    return count;
}

// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    switch (section){
//        case RESPONSES:
//            return @"";
//    }
//
//    // Error
//    return @"";
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ARLNarratorItemView *cell = (ARLNarratorItemView *)[cv dequeueReusableCellWithReuseIdentifier:self.cellIdentifier
                                                                                     forIndexPath:indexPath];
    
    
    cell.backgroundColor = [UIColor colorWithRed:(float)0xE6
                                           green:(float)0xE6
                                            blue:(float)0xFA
                                           alpha:1.0F];
    
    cell.imgView.frame = CGRectMake(0,0,
                                    cell.frame.size.width,
                                    cell.frame.size.height);
    
    @autoreleasepool {
        switch (indexPath.section) {
            case RESPONSES:{
                Response *response = (Response *)[self.fetchedResultsController objectAtIndexPath:indexPath];
                
                //            Log(@"%@ - %@ %@", response.fileName, response.value, response.contentType);
                
                if (response.fileName) {
                    
                    if (self.withPicture && [response.responseType isEqualToNumber:[NSNumber numberWithInt:PHOTO]]) {
                        
                        if (response.thumb) {
                            cell.imgView.image = [UIImage imageWithData:response.thumb];
                        } else if (response.data) {
                            cell.imgView.image = [UIImage imageWithData:response.data];
                        } else {
                            cell.imgView.image = [UIImage imageNamed:@"task-photo"];
                        }
                    } else if (self.withVideo && [response.responseType isEqualToNumber:[NSNumber numberWithInt:VIDEO]]) {
                        
                        if (response.thumb) {
                            cell.imgView.image = [UIImage imageWithData:response.thumb];
                            
                            // rotate 90' Right (will al least make portrait videos right).
                            CGAffineTransform rotate = CGAffineTransformMakeRotation( M_PI / 2.0 );
                            [cell.imgView setTransform:rotate];
                            
                            // create a new bitmap image context
                            UIGraphicsBeginImageContext(cell.imgView.image.size);
                            
                            // draw original image into the context
                            [cell.imgView.image drawAtPoint:CGPointZero];
                            
                            // draw icon
                            UIImage *ico = [UIImage imageNamed:@"task-video-overlay"];
                            
                            // see http://stackoverflow.com/questions/8858404/uiimage-aspect-fit-when-using-drawinrect
                            CGFloat aspect = cell.imgView.image.size.width / cell.imgView.image.size.height;
                            
                            CGPoint p = CGPointMake(cell.imgView.image.size.width, cell.imgView.image.size.height);
                            
                            if (ico.size.width / aspect <= ico.size.width) {
                                CGSize s = CGSizeMake(ico.size.width, ico.size.width/(aspect));
                                [ico drawInRect:CGRectMake(p.x-s.width-2, 2, s.width, s.height)];
                            }else {
                                CGSize s = CGSizeMake(ico.size.height*aspect, ico.size.height);
                                [ico drawInRect:CGRectMake(p.x-s.width-2, 2, s.width, s.height)];
                            }
                            
                            // make image out of bitmap context
                            UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
                            
                            // free the context
                            UIGraphicsEndImageContext();
                            
                            cell.imgView.image = retImage;
                            //                  } else if (response.data) {
                            //                      cell.imgView.image = [UIImage imageWithData:response.data];
                        } else {
                            cell.imgView.image = [UIImage imageNamed:@"task-video"];
                        }
                        //                  cell.imgView.image = [UIImage imageNamed:@"task-video"];
                        
                    } else if (self.withAudio && [response.responseType isEqualToNumber:[NSNumber numberWithInt:AUDIO]]) {
                        cell.imgView.image = [UIImage imageNamed:@"task-record"];
                    }
                } else {
                    if (response.value) {
                        if ((self.withText  && [response.responseType isEqualToNumber:[NSNumber numberWithInt:TEXT]]) ||
                            (self.withValue && [response.responseType isEqualToNumber:[NSNumber numberWithInt:NUMBER]])) {
                            
                            NSString *txt;
                            NSError * error = nil;
                            NSData *JSONdata = [response.value dataUsingEncoding:NSUTF8StringEncoding];
                            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:JSONdata
                                                                                       options: NSJSONReadingMutableContainers
                                                                                         error:&error];
                            
                            if ([dictionary valueForKey:@"text"]) {
                                txt = [dictionary valueForKey:@"text"];
                            }else if ([dictionary valueForKey:@"value"]) {
                                txt = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"value"]];
                            }else {
                                txt = [NSString stringWithFormat:@"%@", response.value];
                            }
                            
                            // Log(@"%f x %F", [self getCellSize].width, [self getCellSize].height);
                            
                            UIGraphicsBeginImageContextWithOptions(CGSizeMake(100,100), NO, 0.0);
                            cell.imgView.image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            cell.imgView.image  = [self drawText:txt inImage:cell.imgView.image atPoint:CGPointZero];
                        }
                    }
                }
            }
                break;
        }
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        ARLNarratorItemHeaderViewController *headerView = [collectionView
                                                           dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                           withReuseIdentifier:@"NarratorHeader"
                                                           forIndexPath:indexPath];
        
        NSString *description = [ARLUtils cleanHtml:self.activeItem.richText];
        if ([description length] == 0) {
            [headerView.headerText setText:self.activeItem.name];
        } else {
            [headerView.headerText setText:description];
        }
        
        reusableview = headerView;
    }
    
    return reusableview;
}

#pragma mark - UICollectionViewDelegateFlowLayout.

- (CGSize)getCellSize {
    // noColumns
    CGFloat w = self.collectionView.bounds.size.width - ((self.noColumns) * self.columnInset);
    w /= self.noColumns;
    w-= 1 + (2 * self.noColumns);
    
    // 2
    CGSize retval = CGSizeMake(w, w);
    
    return retval;
}

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self getCellSize];
}

// 3
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(self.columnInset, self.columnInset, self.columnInset, self.columnInset);
}

// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
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
                    controller.html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head></head><body><img src='%@?thumbnail=1600&crop=true' style='width:100%%;' /><hr/><div><h2 style='text-align: center;'>%@, %@</h2></div></body></html>",
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
                // Log(@"%@", response.fileName);
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
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PIM", @"PIM")
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

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath :(NSIndexPath *)indexPath {
    // TODO: Deselect item
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
        //            [ARLCloudSynchronizer syncResponses: self.activeItem.managedObjectContext];
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

#pragma mark - Properties

/*!
 *  Getter
 *
 *  @return The Cell Identifier.
 */
-(NSString *) cellIdentifier {
    return  @"imageItemCell";
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

/*!
 *  Getter
 *
 *  @return The Number of Columns.
 */
-(CGFloat) noColumns {
    return  4.0f;
}

/*!
 *  Getter
 *
 *  @return The Column Inset.
 */
-(CGFloat) columnInset {
    return  10.0f;
}

#pragma mark - Methods

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
    
    if (self.withPicture){
        tmp = [NSMutableArray arrayWithArray:[tmp arrayByAddingObject:
                                              [NSPredicate predicateWithFormat:@"responseType=%@", [NSNumber numberWithInt:PHOTO]]]];
    }
    if (self.self.withVideo){
        tmp = [NSMutableArray arrayWithArray:[tmp arrayByAddingObject:
                                              [NSPredicate predicateWithFormat:@"responseType=%@", [NSNumber numberWithInt:VIDEO]]]];
    }
    if (self.withAudio){
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
    NSPredicate *andPredicate = [NSPredicate predicateWithFormat: @"run.runId = %lld AND generalItem.generalItemId = %lld",[self.runId longLongValue], [self.activeItem.generalItemId longLongValue]];
    
    // Example Predicate: (run.runId == 5860462742732800 AND generalItem.generalItemId == 3713019) AND (contentType == "application/jpg" OR contentType == "video/quicktime" OR contentType == "audio/aac")
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:andPredicate, orPredicate, nil]];
    
#warning SOMETIMES BAD-ACCES HERE.
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_defaultContext];
    
    NSFetchRequest *request =  [Response MR_requestAllSortedBy:nil
                                                     ascending:YES
                                                 withPredicate:predicate
                                                     inContext:ctx];
    request.fetchBatchSize = 8;
    
    self.fetchedResultsController = [Response MR_fetchController:request
                                                        delegate:self
                                                    useFileCache:NO
                                                       groupedBy:nil
                                                       inContext:ctx];

    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];

    ELog(error);
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
    
#warning TODO Port NarratorItem
    // controller.inquiry = self.inquiry;
  
    TODO Move saving to code into viewcontroller?
    controller.activeItem = self.activeItem;
    controller.run = self.run;
    
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
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        
        // self.imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        self.mode = UIImagePickerControllerCameraCaptureModeVideo;
        
        self.imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
        self.imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            self.imagePickerController.cameraDevice= UIImagePickerControllerCameraDeviceRear;
        } else {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
        [self.navigationController presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}

/*!
 *  Take a Picture.
 */
- (void) collectImage {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //  if (!self.imagePickerController) {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        
        // self.imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        self.mode = UIImagePickerControllerCameraCaptureModePhoto;
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        // image picker needs a delegate so we can respond to its messages
        [self.imagePickerController setDelegate:self];
    }
    
    // Place image picker on the screen
    [self.navigationController presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark - Actions

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
            // [ARLCloudSynchronizer syncResponses:self.activeItem.managedObjectContext];
        }

        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
        
        ELog(error);

        Log(@"RESPONSES: %d",[self.fetchedResultsController.fetchedObjects count]);
    }
}

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
    
    Response *textResponse = [self responseWithDictionary:data];

    [self.collectionView reloadData];
}

#warning TODO Port NarratorItem

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
    
    Response *valueResponse = [self responseWithDictionary:data];
    
    [self.collectionView reloadData];
}

- (void) createImageResponse:(NSData *)data
                       width:(NSNumber*)width
                      height:(NSNumber *)height {
    
    u_int32_t random = arc4random();
    NSString *fileName =[NSString stringWithFormat:@"%u.%@", random, @"jpg"];
    
    //    // Create thumb here...
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

    // TEST CODE
//    NSError *error = nil;
//    [self.fetchedResultsController performFetch:&error];
//    
//  [self.collectionView reloadData];
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
    
    [self.collectionView reloadData];
}

- (void) createAudioResponse:(NSData *)data
                    fileName:(NSString *)fileName {
#warning TODO Port NarratorItem

//    Response *response = [Response initResponse:run
//                                 forGeneralItem:generalItem
//                                       withData:data
//                         inManagedObjectContext:generalItem.managedObjectContext];
//    
//    if ([fileName hasSuffix:@".m4a"]) {
//        response.contentType = @"audio/aac";
//    } else  if ([fileName hasSuffix:@".mp3"]) {
//        response.contentType = @"audio/mp3";
//    } else  if ([fileName hasSuffix:@".amr"]) {
//        response.contentType = @"audio/amr";
//    } else {
//        // Fallback.
//        response.contentType = @"audio/aac";
//    }
//    
//    response.responseType = [NSNumber numberWithInt:AUDIO];
//    
//    //    u_int32_t random = arc4random();
//    response.fileName = fileName;//[NSString stringWithFormat:@"%u.%@", random, @"mp3"];
//    
//    response.account = [ARLNetworking CurrentAccount];
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
    
    [ctx MR_saveToPersistentStoreAndWait];
    
    return response;
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
        // Comparing cnt fails because the code already does a performFetch before we enter here (because we switch views to add this one is rebuilt).
        // NSUInteger cntBefore = [[self.fetchedResultsController fetchedObjects] count];
        
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
        
        // NSUInteger cntAfter = [[self.fetchedResultsController fetchedObjects] count];
        
        // if (cntBefore!=cntAfter) {
        // Log(@"Responses: %d -> %d", cntBefore, cntAfter);
        
        [self.collectionView reloadData];
        // }
    }
}

@end
