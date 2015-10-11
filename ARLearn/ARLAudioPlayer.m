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

//@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (readonly, nonatomic) NSTimeInterval CurrentAudioTime;
@property (readonly, nonatomic) NSNumber *AudioDuration;

@property BOOL isPaused;
@property BOOL scrubbing;
@property NSTimer *timer;

@property AVURLAsset *avAsset;
@property AVPlayerItem *playerItem;
@property AVPlayer *avPlayer;
@property id playbackTimeObserver;

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
            [self.descriptionText loadHTMLString:[ARLUtils replaceLocalUrlsinHtml:self.activeItem.richText]
                                         baseURL:nil];
        } else if (TrimmedStringLength(self.activeItem.descriptionText) != 0) {
            self.descriptionText.hidden = NO;
            [self.descriptionText loadHTMLString:[ARLUtils replaceLocalUrlsinHtml:self.activeItem.descriptionText]
                                         baseURL:nil];
            
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
    
#warning FIND BETTER WAY TO SEE WETHER FEED IS PART OF GAMEFILES.
    
    NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:self.activeItem.json];
    
#warning what to do with iconUrl field (and it's MD5 hash)?
    
    //    NSString *iconUrl = [json valueForKey:@"iconUrl"];
    //
    //    UIImage *icon = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]];
    
    NSString *audioFile = [json valueForKey:@"audioFeed"];
    NSURL *audioUrl = [ARLUtils convertStringUrl:audioFile fileExt:@".mp3" gameId:self.activeItem.gameId];
    
    //http://stackoverflow.com/questions/3635792/play-audio-from-internet-using-avaudioplayer
    //http://stackoverflow.com/questions/5501670/how-to-play-movie-files-with-no-file-extension-on-ios-with-mpmovieplayercontroll
    
    self.avAsset = [AVURLAsset URLAssetWithURL:audioUrl
                                       options:nil];
  
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.avAsset];
    
    self.avPlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
    
//    //init the Player to get file properties to set the time labels
//    self.playerSlider.value = 0.0;
//    self.playerSlider.maximumValue = [self.AudioDuration floatValue];
//    
//    //init the current timedisplay and the labels. if a current time was stored
//    //for this player then take it and update the time display
//    self.elapsedLabel.text = @"0:00";
//    
//    self.durationLabel.text = [NSString stringWithFormat:@"-%@", [self timeFormat:self.AudioDuration]];
    
    [self resetPlayer];
    
#pragma warn DEBUG CODE. We show Description instead of avplayer if the internet is not available and the media is not downloaded yet.
    self.descriptionText.hidden = YES;

    if (self.descriptionText.isHidden) {
        [self applyConstraints];
    }
    
    if (![[json objectForKey:@"autoPlay"] boolValue]) {
        [self togglePlaying];
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
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopAudio];
    
    [self.avPlayer removeObserver:self forKeyPath:@"rate"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
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
    
    if (CMTIME_IS_VALID(duration) && duration.value != 0) {
        return [NSNumber numberWithFloat:duration.value/duration.timescale];
    }
    return [NSNumber numberWithInt:0];
}

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

#pragma mark - Observers

-(void)itemDidFailPlaying:(NSNotification *) notification {
    [self.timer invalidate];
    
    [self.playerButton setBackgroundImage:[UIImage imageNamed:@"black_play"]
                                 forState:UIControlStateNormal];
    
    self.playerSlider.value = 0.0;
    self.CurrentAudioTime = self.playerSlider.value;
    
    self.elapsedLabel.text = @"0:00";
    self.durationLabel.text = [NSString stringWithFormat:@"-%@", [self timeFormat:self.AudioDuration]];
    
    self.isPaused = FALSE;
}

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    // Will be called when AVPlayer finishes playing playerItem
    [ARLCoreDataUtils CreateOrUpdateAction:self.runId
                                activeItem:self.activeItem
                                      verb:complete_action];
    
    // This notification contains the rest of the code at en-of-play.
    //
    [self itemDidFailPlaying:notification];
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
                
                [self.timer invalidate];
                
                [self.playerButton setBackgroundImage:[UIImage imageNamed:@"black_play"]
                                             forState:UIControlStateNormal];
                
                self.playerSlider.value = 0.0;
                self.CurrentAudioTime = self.playerSlider.value;
                
                self.elapsedLabel.text = @"0:00";
                self.durationLabel.text = [NSString stringWithFormat:@"-%@", [self timeFormat:self.AudioDuration]];
                
                self.isPaused = FALSE;
            }
        }
    }
}

@end
