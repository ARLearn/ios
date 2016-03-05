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

@property (weak, nonatomic) IBOutlet ARLAudioPlayerControl *audioPlayer;

@end

@implementation ARLAudioPlayer

@synthesize activeItem = _activeItem;
@synthesize runId = _runId;

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
    
    // NSString *iconUrl = [json valueForKey:@"iconUrl"];
    //
    // UIImage *icon = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]];
    
#pragma warn DEBUG CODE. We show Description instead of avplayer if the internet is not available and the media is not downloaded yet.
    // self.descriptionText.hidden = YES;
    
    [self applyConstraints];

    
#pragma warn AUDIOPLAYERCONTROL : Pass AutoPlay, not parsing JSON.
#pragma warn USE BLOCK TO SET COMPLETION.
    NSString *audioFile = [json valueForKey:@"audioFeed"];
    NSURL *audioUrl = [ARLUtils convertStringUrl:audioFile fileExt:@".mp3" gameId:self.activeItem.gameId];
    
    [self.audioPlayer load:audioUrl
                  autoPlay:[[json objectForKey:@"autoPlay"] boolValue]
                completion:^(BOOL finished) {
                    if (finished) {
                        [ARLCoreDataUtils CreateOrUpdateAction:self.runId
                                                    activeItem:self.activeItem
                                                          verb:complete_action];
                    }
                }
     ];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.descriptionText.isHidden) {
        [self applyConstraints];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.audioPlayer unload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [self applyConstraints];
}

#pragma mark - Properties

- (void)setActiveItem:(GeneralItem *)activeItem {
    _activeItem = activeItem;
}

- (GeneralItem *)activeItem {
    return _activeItem;
}

#pragma mark - Methods

- (void) applyConstraints {
    NSDictionary *viewsDictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,             @"view",
                                     
                                     self.backgroundImage,  @"backgroundImage",
                                      
                                     self.audioPlayer,      @"audioPlayer",
                                     
                                     //self.itemsTable,       @"itemsTable",
                                     self.descriptionText,  @"descriptionText",
                                 
                                     nil];
    
    // See http://stackoverflow.com/questions/17772922/can-i-use-autolayout-to-provide-different-constraints-for-landscape-and-portrait
    // See https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/Bars.html
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionText.translatesAutoresizingMaskIntoConstraints = NO;
    self.audioPlayer.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Fix Background.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary1]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary1]];
    
    // Fix playerView Horizontal.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[audioPlayer]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary1]];
    
    
    
    // Fix descriptionText Horizontal.
    if (![self.descriptionText isHidden]) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[descriptionText]-|"
                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:nil
                                                                            views:viewsDictionary1]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[audioPlayer(46)]-[descriptionText(200)]"
                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:nil
                                                                            views:viewsDictionary1]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[audioPlayer(46)]"
                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:nil
                                                                            views:viewsDictionary1]];
    }
}

@end
