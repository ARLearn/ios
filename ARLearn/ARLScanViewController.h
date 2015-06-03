//
//  ARLScanViewController.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/21/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "UIViewController+UI.h"

#import "ARLAppDelegate.h"
#import "ARLDelayOperation.h"

#import "ARLGameViewController.h"

/*!
 *  Forward Declaration.
 */
@class ARLScanViewController;


/*!
 *  Procol to handle results.
 */
@protocol AMScanViewControllerDelegate <NSObject>

@optional

- (void) scanViewController:(ARLScanViewController *) aCtler
       didTapToFocusOnPoint:(CGPoint) aPoint;

- (void) scanViewController:(ARLScanViewController *) aCtler
        didSuccessfullyScan:(NSString *) aScannedValue
    didSuccessfullyScanType:(NSString *) aScannedType;

@end

/*!
 *  The ViewController.
 */
@interface ARLScanViewController : UIViewController <AMScanViewControllerDelegate,AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) GeneralItem *activeItem;

@property (strong, nonatomic) NSNumber *runId;

@property (nonatomic, weak) id<AMScanViewControllerDelegate> delegate;

@property (assign, nonatomic) BOOL touchToFocusEnabled;

- (BOOL) isCameraAvailable;
- (void) startScanning;
- (void) stopScanning;
- (void) setTorch:(BOOL) aStatus;

- (void) scanViewController:(ARLScanViewController *) aCtler
       didTapToFocusOnPoint:(CGPoint) aPoint;

- (void) scanViewController:(ARLScanViewController *) aCtler
        didSuccessfullyScan:(NSString *) aScannedValue
    didSuccessfullyScanType:(NSString *) aScannedType;

@end
