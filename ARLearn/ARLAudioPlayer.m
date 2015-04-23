//
//  ARLAudioPlayer.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 23/04/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//  Based on YMCAudioPlayer / http://www.ymc.ch/en/building-a-simple-audioplayer-in-ios / https://github.com/ymc-thzi/ios-audio-player/

#import "ARLAudioPlayer.h"

@interface ARLAudioPlayer ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIWebView *descriptionText;

@property (weak, nonatomic) IBOutlet UIButton *playerButton;
@property (weak, nonatomic) IBOutlet UISlider *playerSlider;

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *elapsedLabel;

- (IBAction)playerAction:(UIButton *)sender;
- (IBAction)sliderAction:(UISlider *)sender;
- (IBAction)isScrubbing:(UISlider *)sender;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (readonly, nonatomic) NSTimeInterval CurrentAudioTime;
@property (readonly, nonatomic) NSNumber *AudioDuration;

@property BOOL isPaused;
@property BOOL scrubbing;

@property NSTimer *timer;

@end

@implementation ARLAudioPlayer

@synthesize activeItem= _activeItem;
@synthesize runId;

@synthesize CurrentAudioTime;
@synthesize AudioDuration;

#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // The ContentSize of the UIWebView will only grow so start small.
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
        }
    }else {
        self.descriptionText.hidden = YES;
    }
    
    self.descriptionText.delegate = self;
    
    [ARLCoreDataUtils CreateOrUpdateAction:self.runId
                                activeItem:self.activeItem
                                      verb:read_action];
    
    NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:self.activeItem.json];
    
    NSString *audioFeed = [json valueForKey:@"audioFeed"];
    
    NSRange index = [audioFeed rangeOfString:[self.activeItem.gameId stringValue]];
    
    NSString *path = [audioFeed substringFromIndex:index.location + index.length];
    
    NSString *audioFile = [ARLUtils GenerateResourceFileName:self.activeItem.gameId
                                                        path:path];
    
    NSURL *audioUrl = [[NSURL alloc] initFileURLWithPath:audioFile];
    
    // See http://stackoverflow.com/questions/1973902/play-mp3-files-with-iphone-sdk
    // See http://www.raywenderlich.com/69369/audio-tutorial-ios-playing-audio-programatically-2014-edition
    // See http://stackoverflow.com/questions/9683547/avaudioplayer-throws-breakpoint-in-debug-mode
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:&error];
    
    ELog(error);
    
    [self.audioPlayer setDelegate:self];
    [self.audioPlayer prepareToPlay];
    
    //init the Player to get file properties to set the time labels
    self.playerSlider.value = 0.0;
    self.playerSlider.maximumValue = [self.AudioDuration floatValue];
    
    //init the current timedisplay and the labels. if a current time was stored
    //for this player then take it and update the time display
    self.elapsedLabel.text = @"0:00";
    
    self.durationLabel.text = [NSString stringWithFormat:@"-%@", [self timeFormat:self.AudioDuration]];
    
    // [self.playerButton setTitle:@"" forState:UIControlStateNormal];
    
    if (self.descriptionText.isHidden) {
        [self applyConstraints];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopAudio];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [ARLCoreDataUtils CreateOrUpdateAction:self.runId
                                activeItem:self.activeItem
                                      verb:complete_action];
    
    [self.timer invalidate];
    
    [self.playerButton setBackgroundImage:[UIImage imageNamed:@"black_play"]
                                 forState:UIControlStateNormal];

    self.playerSlider.value = 0.0;
    self.CurrentAudioTime = self.playerSlider.value;

    self.elapsedLabel.text = @"0:00";
    self.durationLabel.text = [NSString stringWithFormat:@"-%@", [self timeFormat:self.AudioDuration]];

    self.isPaused = FALSE;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {

    [self.timer invalidate];
    
    [self.playerButton setBackgroundImage:[UIImage imageNamed:@"black_play"]
                                 forState:UIControlStateNormal];

    self.playerSlider.value = 0.0;
    self.CurrentAudioTime = self.playerSlider.value;

    self.elapsedLabel.text = @"0:00";
    self.durationLabel.text = [NSString stringWithFormat:@"-%@", [self timeFormat:self.AudioDuration]];

    self.isPaused = FALSE;
}


#pragma mark - UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    CGRect newBounds = webView.bounds;
    newBounds.size.height = webView.scrollView.contentSize.height;
    webView.bounds = newBounds;
    
    [self applyConstraints];
}

#pragma mark - Properties

- (void)setActiveItem:(GeneralItem *)activeItem {
    _activeItem = activeItem;
}

- (GeneralItem *)activeItem {
    return _activeItem;
}

/*
 * To set the current Position of the
 * playing audio File
 */
- (void)setCurrentAudioTime:(NSTimeInterval)value {
    [self.audioPlayer setCurrentTime:value];
}

- (NSTimeInterval)CurrentAudioTime {
    return [self.audioPlayer currentTime];
}

/*
 * Get the whole length of the audio file
 */
- (NSNumber *)AudioDuration {
    return [NSNumber numberWithFloat:[self.audioPlayer duration]];
}

//[self.audioPlayer setDelegate:self];
//[self.audioPlayer prepareToPlay];
//[self.audioPlayer play];
//
//[self.itemsTable setUserInteractionEnabled:NO];
//}
#pragma mark - Methods

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

- (void) applyConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,             @"view",
                                     
                                     self.backgroundImage,  @"backgroundImage",
                                     
                                     //self.itemsTable,       @"itemsTable",
                                     self.descriptionText,  @"descriptionText",
                                     self.playerButton,     @"playerButton",
                                     self.playerSlider,     @"playerSlider",
                                     self.durationLabel,    @"durationLabel",
                                     self.elapsedLabel,     @"elapsedLabel",
                                     
                                     nil];
    
    // See http://stackoverflow.com/questions/17772922/can-i-use-autolayout-to-provide-different-constraints-for-landscape-and-portrait
    // See https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/Bars.html
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
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
    
    // Fix descriptionText Horizontal.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[descriptionText]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    // Fix player Horizontal.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[playerButton(==70)]-[durationLabel]-[playerSlider]-[elapsedLabel]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    // Fix player/descriptionText Vertically.
    if (self.descriptionText.isHidden) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[playerButton(==70)]"
                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-[descriptionText(==%f)]-[playerButton(==70)]",
                                                                                   self.descriptionText.bounds.size.height]
                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
    }
    
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

#pragma mark - Actions.
/*
 * Simply fire the play Event
 */
- (void)playAudio {
    [self.audioPlayer play];
}

/*
 * Simply fire the pause Event
 */
- (void)pauseAudio {
    [self.audioPlayer pause];
}

/*
 * Simply fire the stop Event
 */
- (void)stopAudio {
    [self.audioPlayer stop];
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
    [self.timer invalidate];
    
    if (!self.isPaused) {
        [self.playerButton setBackgroundImage:[UIImage imageNamed:@"black_pause"]
                                     forState:UIControlStateNormal];
        
        //start a timer to update the time label display
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
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

@end
