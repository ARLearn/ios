//
//  ARLVideoPlayerViewController.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 09/10/15.
//  Copyright © 2015 Open University of the Netherlands. All rights reserved.
//

#import "ARLVideoPlayerViewController.h"

@interface ARLVideoPlayerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIWebView *descriptionText;

@property (weak, nonatomic) IBOutlet UIButton *playerButton;
@property (weak, nonatomic) IBOutlet UISlider *playerSlider;

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *elapsedLabel;

- (IBAction)playerAction:(UIButton *)sender;
- (IBAction)sliderAction:(UISlider *)sender;
- (IBAction)isScrubbing:(UISlider *)sender;

@property (readonly, nonatomic) NSTimeInterval CurrentVideoTime;
@property (readonly, nonatomic) NSNumber *VideoDuration;

@property BOOL isPaused;
@property BOOL scrubbing;
@property NSTimer *timer;

@property AVURLAsset *avAsset;

@property AVPlayerItem *playerItem;
@property AVPlayer *avPlayer;
@property id playbackTimeObserver;

@end

@implementation ARLVideoPlayerViewController

@synthesize activeItem= _activeItem;
@synthesize runId;

@synthesize CurrentVideoTime;
@synthesize VideoDuration;

-(void)viewDidLoad {
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
    
    NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:self.activeItem.json];
    
#warning what to do with iconUrl field (and it's MD5 hash)?
    
    //NSString *iconUrl = [json valueForKey:@"iconUrl"];
    //
    //UIImage *icon = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]];
    
    NSString *videoFile = [json valueForKey:@"videoFeed"];
    NSURL *videoUrl = [ARLUtils convertStringUrl:videoFile fileExt:@".mov" gameId:self.activeItem.gameId];
    
    // see http://stackoverflow.com/questions/1266750/iphone-sdkhow-do-you-play-video-inside-a-view-rather-than-fullscreen
    self.avPlayer = [AVPlayer playerWithURL:videoUrl];
    
    // Add Player to main view.
    AVPlayerLayer *layer = [AVPlayerLayer layer];
    
    #pragma warn TODO Correctly Position Player.
    
    [layer setPlayer:self.avPlayer];
    [layer setFrame:CGRectMake(10, 10, 300, 200)];
    [layer setBackgroundColor:[UIColor clearColor].CGColor];
    [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [self.view.layer addSublayer:layer];

    [self resetPlayer];
    
#pragma warn DEBUG CODE. We show Description instead of avplayer if the internet is not available and the media is not downloaded yet.
    if (self.descriptionText.isHidden) {
        [self applyConstraints];
    }
    
    //[self playVideo];
    self.descriptionText.hidden = YES;
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
    
    [self stopVideo];
    
    [self.avPlayer removeObserver:self forKeyPath:@"rate"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
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
- (void)setCurrentVideoTime:(NSTimeInterval)value {
    //[self.avlayer setCurrentTime:value];
    CMTime current = CMTimeMakeWithSeconds(value, 1);
    
    [self.avPlayer seekToTime:current];
}

- (NSTimeInterval)CurrentVideoTime {
    CMTime current = self.avPlayer.currentTime;
    
    if (CMTIME_IS_VALID(current)) {
        return [[NSNumber numberWithDouble:current.value/current.timescale] doubleValue];
    }
    return [[NSNumber numberWithDouble:0.0] doubleValue];
}

/*
 * Get the whole length of the video file
 */
- (NSNumber *)VideoDuration {
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
    
    long roundedSeconds = lroundf(seconds);
    long roundedMinutes = lroundf(minutes);
    
    NSString *time = [[NSString alloc]
                      initWithFormat:@"%ld:%02ld",
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
        
        [self playVideo];
        
        self.isPaused = TRUE;
    } else {
        //player is paused and Button is pressed again
        [self.playerButton setBackgroundImage:[UIImage imageNamed:@"black_play"]
                                     forState:UIControlStateNormal];
        
        [self pauseVideo];
        
        self.isPaused = FALSE;
    }
}

- (void) applyConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,             @"view",
                                     
                                     self.backgroundImage,  @"backgroundImage",
                                    
                                     //self.avPlayer,         @"avPlayer",
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
    //self.avPlayer.translatesAutoresizingMaskIntoConstraints = NO;
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
    
    // Fix player Horizontal.
    // Not needed as it's in a Layer on top.
    //    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[avPlayer]-|"
    //                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
    //                                                                      metrics:nil
    //                                                                        views:viewsDictionary]];

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
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[playerButton(==70)]-|"
                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[descriptionText(==%f)]-[playerButton(==70)]-|",
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

#pragma mark - Actions

/*
 * Simply fire the play Event
 */
- (void)playVideo {
    [self.avPlayer play];
}

/*
 * Simply fire the pause Event
 */
- (void)pauseVideo {
    [self.avPlayer pause];
}

/*
 * Simply fire the stop Event
 */
- (void)stopVideo {
    [self.avPlayer pause];
}

- (void)resetPlayer {
    [self.timer invalidate];
    
    [self.playerButton setBackgroundImage:[UIImage imageNamed:@"black_play"]
                                 forState:UIControlStateNormal];
    
    self.playerSlider.value = 0.0;
    self.playerSlider.maximumValue = [self.VideoDuration floatValue];
    self.CurrentVideoTime = 0.0;
    
    self.elapsedLabel.text = @"0:00";
    self.durationLabel.text = [NSString stringWithFormat:@"-%@", [self timeFormat:self.VideoDuration]];
    
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
        self.playerSlider.value = self.CurrentVideoTime;
    }
    self.elapsedLabel.text = [NSString stringWithFormat:@"%@",
                              [self timeFormat:[NSNumber numberWithDouble:self.CurrentVideoTime]]];
    self.durationLabel.text = [NSString stringWithFormat:@"-%@",
                               [self timeFormat:@([self.VideoDuration doubleValue] - self.CurrentVideoTime)]];
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
    
    self.CurrentVideoTime = self.playerSlider.value;
    
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
    self.CurrentVideoTime = self.playerSlider.value;
    
    self.elapsedLabel.text = @"0:00";
    self.durationLabel.text = [NSString stringWithFormat:@"-%@", [self timeFormat:self.VideoDuration]];
    
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
                self.CurrentVideoTime = self.playerSlider.value;
                
                self.elapsedLabel.text = @"0:00";
                self.durationLabel.text = [NSString stringWithFormat:@"-%@", [self timeFormat:self.VideoDuration]];
                
                self.isPaused = FALSE;
            }
        }
    }
}

@end
