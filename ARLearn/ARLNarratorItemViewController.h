//
//  ARLNarratorItemViewController.h
//  ARLearn
//
//  Created by Stefaan Ternier on 7/18/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "GeneralItem.h"
#import "GeneralItemData.h"
#import "Response.h"
#import "GeneralItem.h"
#import "Run.h"
#import "Action.h"

#import "ARLAppDelegate.h"
#import "ARLAudioRecorder.h"
#import "ARLAudioRecorderViewController.h"
#import "ARLAppDelegate.h"
#import "ARLWebViewController.h"
#import "ARLCoreDataUtils.h"
#import "ARLUtils.h"
#import "ARLBeanNames.h"
#import "ARLDownloadViewController.h"

#import "UIImage+Resize.h"

@interface ARLNarratorItemViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSNumber *runId;

@property (strong, nonatomic) GeneralItem *activeItem;

- (void) createAudioResponse:(NSData *)data
                    fileName:(NSString *)fileName;

@end
