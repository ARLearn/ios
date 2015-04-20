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

#import "ARLAudioRecorder.h"
#import "ARLAudioRecorderViewController.h"
#import "ARLAppDelegate.h"
#import "ARLNarratorItemView.h"
#import "ARLWebViewController.h"
#import "ARLNarratorItemHeaderViewController.h"

@interface ARLNarratorItemViewController : UICollectionViewController
<NSFetchedResultsControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UITextFieldDelegate>

//@property (strong, nonatomic) GeneralItem *generalItem;
//@property (strong, nonatomic) Inquiry *inquiry;
//
//@property (strong, nonatomic) Account *account;

@property (strong, nonatomic) NSNumber *runId;

@property (strong, nonatomic) GeneralItem *activeItem;

@end
