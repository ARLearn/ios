//
//  ARLAudioRecorderViewController.h
//  ARLearn
//
//  Created by Stefaan Ternier on 8/9/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARLAudioRecorder.h"
#import "ARLAudioRecordButtons.h"
// #import "ARLNarratorItemViewController.h"

@class ARLAudioRecorder;
@class ARLAudioRecordButtons;

@interface ARLAudioRecorderViewController : UIViewController

@property (nonatomic, weak) GeneralItem* activeItem;
@property (nonatomic, weak) Run* run;

@property (strong, nonatomic ) ARLAudioRecorder * recorder;
@property (strong, nonatomic) AVAudioSession *session;

@property (nonatomic, strong) UILabel *countField;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) ARLAudioRecordButtons *recordButtons;

- (void) clickedSaveButton: (NSData*) audioData;

@property (nonatomic, strong) UIViewController *controller;

@end
