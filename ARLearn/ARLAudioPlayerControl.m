//
//  ARLAudioPlayerControl.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 04/03/16.
//  Copyright © 2016 Open University of the Netherlands. All rights reserved.
//

#import "ARLAudioPlayerControl.h"

@interface ARLAudioPlayerControl ()

@property (weak, nonatomic) IBOutlet UIButton *playerButton;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@property (weak, nonatomic) IBOutlet UILabel *elapsedLabel;

@property (weak, nonatomic) IBOutlet UISlider *playerSlider;

- (IBAction)playerButtonAction:(UIButton *)sender;

- (IBAction)sliderAction:(UISlider *)sender;
- (IBAction)isScrubbing:(UISlider *)sender;

@property (readonly, nonatomic) NSTimeInterval CurrentAudioTime;
@property (readonly, nonatomic) NSNumber *AudioDuration;

@property BOOL isPaused;
@property BOOL scrubbing;
@property NSTimer *timer;

@property (retain, nonatomic) AVURLAsset *avAsset;
@property (retain, nonatomic) AVPlayerItem *playerItem;
@property (retain, nonatomic) AVPlayer *avPlayer;

@property id playbackTimeObserver;

//@property (strong, nonatomic) GeneralItem *activeItem;

//@property (strong, nonatomic) NSNumber *runId;
@end

@implementation ARLAudioPlayerControl

//@synthesize activeItem = _activeItem;
//@synthesize runId = _runId;

@synthesize CurrentAudioTime;
@synthesize AudioDuration;

ARLCompletion playCompletion;

// static CGFloat const kSliderHeight = 30.0f;

// See https://www.youtube.com/watch?v=xP7YvdlnHfA
// See https://www.youtube.com/watch?v=5ibVlOx2o7I
// See https://www.youtube.com/watch?v=6swkbu2X8ww

#pragma mark - UIControl

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // init code
        [[NSBundle mainBundle] loadNibNamed:@"ARLAudioPlayerControl" owner:self options:nil];
        
        [self addSubview:self.view];
        
        [self initControl];
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder   {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // init code
        [[NSBundle mainBundle] loadNibNamed:@"ARLAudioPlayerControl" owner:self options:nil];
        
        self.bounds = self.view.bounds;
        
        [self addSubview:self.view];
        
        [self initControl];
    }
    
    return self;
}

//- (void)drawRect:(CGRect)rect {
//#if TARGET_INTERFACE_BUILDER
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGRect myFrame = self.bounds;
//    CGContextSetLineWidth(context,10);
//    CGRectInset(myFrame,5,5);
//    [[UIColor redColor] set];
//    UIRectFrame(myFrame);
//#endif
//}

#pragma mark - Properties

/*
 * To set the current Position of the
 * playing audio File
 */
- (void)setCurrentAudioTime:(NSTimeInterval)value {
    //[self.avlayer setCurrentTime:value];
    CMTime current = CMTimeMakeWithSeconds(value, 1000);
    
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

#pragma mark Methods

- (void) initControl {
     [self resetPlayer];
    
 
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      self.view,            @"view",
                                      
                                      self.playerButton,    @"playerButton",
                                      self.durationLabel,   @"durationLabel",
                                      self.playerSlider,    @"playerSlider",
                                      self.elapsedLabel,    @"elapsedLabel",
                                      
                                      nil];

    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.playerButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.durationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.playerSlider.translatesAutoresizingMaskIntoConstraints = NO;
    self.elapsedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[playerButton(48)]-[durationLabel(46)]-[playerSlider]-[elapsedLabel(46)]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];

    //"view1.attr1 = view2.attr2 * multiplier + constant"
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.playerButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.playerButton
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.f constant:0.f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.playerButton
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.f constant:0.f]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.durationLabel
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.playerButton
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.f constant:0.f]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.playerSlider
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.playerButton
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.f constant:0.f]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.elapsedLabel
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.playerButton
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.f constant:0.f]];
}

- (void) load:(NSURL *) audioUrl
     autoPlay:(BOOL) autoPlay
   completion:(ARLCompletion) completion
{
    playCompletion = completion;
    
    self.avAsset = [AVURLAsset URLAssetWithURL:audioUrl
                                       options:nil];
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.avAsset];
    
    self.avPlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    [self resetPlayer];
    
    if (!self.playerButton.isHidden) {
        [self.avPlayer addObserver:self
                        forKeyPath:@"rate"
                           options:0
                           context:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidFinishPlaying:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.avPlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidFailPlaying:)
                                                     name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                   object:self.avPlayer];
    }
    
    if (autoPlay) {
        [self togglePlaying];
    }
}

-(void) unload {
    [self stopAudio];
    
    [self.avPlayer removeObserver:self forKeyPath:@"rate"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                  object:nil];
}

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

- (void)resetPlayer {
    [self.timer invalidate];
    
    [self.playerButton setBackgroundImage:[UIImage imageNamed:@"black_play"]
                                 forState:UIControlStateNormal];
    
    self.playerSlider.value = 0.0;
    self.playerSlider.minimumValue = 0.0;
    self.playerSlider.maximumValue = [self.AudioDuration floatValue];
    self.CurrentAudioTime = 0.0;
    
    self.elapsedLabel.text = @"00:00";
    self.durationLabel.text = [NSString stringWithFormat:@"-%@", [self timeFormat:self.AudioDuration]];
    
    self.isPaused = FALSE;
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
    self.playerSlider.maximumValue = [self.AudioDuration floatValue];
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
- (IBAction)playerButtonAction:(UIButton *)sender {
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
    [self resetPlayer];
}

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    // Will be called when AVPlayer finishes playing playerItem
    
    playCompletion(YES);
    
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
            
            if (timeSeconds >= durationSeconds - 1.5) {
                //song reached end
                self.playerSlider.value=self.playerSlider.maximumValue;
                
                playCompletion(YES);
                
                [self resetPlayer];
            }
        }
    }
}

@end
