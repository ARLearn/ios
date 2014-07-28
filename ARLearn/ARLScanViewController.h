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

@protocol AMScanViewControllerDelegate;

@interface ARLScanViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, weak) id<AMScanViewControllerDelegate> delegate;

@property (assign, nonatomic) BOOL touchToFocusEnabled;

- (BOOL) isCameraAvailable;
- (void) startScanning;
- (void) stopScanning;
- (void) setTorch:(BOOL) aStatus;

- (void) scanViewController:(ARLScanViewController *) aCtler
       didTapToFocusOnPoint:(CGPoint) aPoint;

- (void) scanViewController:(ARLScanViewController *) aCtler
        didSuccessfullyScan:(NSString *) aScannedValue;

@end

@protocol AMScanViewControllerDelegate <NSObject>

@optional

- (void) scanViewController:(ARLScanViewController *) aCtler
       didTapToFocusOnPoint:(CGPoint) aPoint;

- (void) scanViewController:(ARLScanViewController *) aCtler
        didSuccessfullyScan:(NSString *) aScannedValue;

@end