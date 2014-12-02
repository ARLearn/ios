//
//  ARLScanViewController.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/21/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLScanViewController.h"

@interface ARLScanViewController ()

@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureMetadataOutput *output;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;
@property (strong, nonatomic) AVCaptureSession *session;

@property (weak, nonatomic) IBOutlet UILabel *scannedLabel;
@property (weak, nonatomic) IBOutlet UISwitch *torchSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *torchLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

- (IBAction)torchSwitchAction:(UISwitch *)sender;

#define VIDEOSIZE 200.0f

@end

/*!
 *  See https://gist.github.com/Alex04/6976945
 *  See http://www.ama-dev.com/iphone-qr-code-library-ios-7/
 *  See http://stackoverflow.com/questions/5117770/avcapturevideopreviewlayer
 *  See http://stackoverflow.com/questions/16515921/get-camera-preview-to-avcapturevideopreviewlayer
 *
 *  See http://www.qr-code-generator.com
 *
 *  TODO Add Constraints.
 *  TODO Add Focus Button.
 */

@implementation ARLScanViewController

#pragma mark - ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self isCameraAvailable]) {
        [self setupNoCameraView];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  
    [self setVideoFrame];
    
    [self setVideoOrientation];
    
    [self startScanning];
}

/*!
 *  viewDidLoad
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self applyConstraints];

    self.delegate = self;

    if ([self isCameraAvailable]) {
        [self setupScanner];
    }
}

/*!
 *  viewWillDisappear
 *
 *  @param animated <#animated description#>
 */
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.delegate = nil;
    
    [self.torchSwitch setOn:NO];
    
    [self stopScanning];

}

/*!
 *  didReceiveMemoryWarning
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self stopScanning];
    
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortrait;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setVideoFrame];
    
    [self stopScanning];
    
    [self setVideoOrientation];

    [self startScanning];
}

#pragma mark - Properties

#pragma mark - Methods

/*!
 *  Add Visual Constraints.
 */
- (void) applyConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,             @"view",
                                     
                                     self.backgroundImage,  @"backgroundImage",
                                     self.scannedLabel,     @"scannedLabel",
                                     self.torchSwitch,      @"torchSwitch",
                                     self.torchLabel,       @"torchLabel",
                                     self.typeLabel,        @"typeLabel",
                                     
                                     nil];
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.scannedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.torchSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    self.torchLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // CGFloat bw = sw/2 - 3*8.0;
    
    // Fix Background.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundImage]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(%f)-[scannedLabel]-[typeLabel]", VIDEOSIZE + 3*8.0f - 4.0f]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];

    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[torchLabel]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[torchSwitch]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[torchLabel]-[torchSwitch]"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
   
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[scannedLabel]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[typeLabel]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}

#pragma mark - Camera

/*!
 *  Set the scanners video orientation to match the device orientation.
 */
- (void)setVideoOrientation
{
    switch ([[UIDevice currentDevice] orientation]) {
            //Seems to happen when the home button is on the RIGHT side. Works.
        case  UIDeviceOrientationLandscapeLeft :
        {
            AVCaptureConnection *con = self.preview.connection;
            con.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
            break;
            
            //Seems to happen when the home button is on the LEFT side. Works.
        case UIDeviceOrientationLandscapeRight :
        {
            AVCaptureConnection *con = self.preview.connection;
            con.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
            break;
            
            //Happens when the home button is on the bottom side. Works.
        case UIDeviceOrientationPortrait :
        {
            AVCaptureConnection *con = self.preview.connection;
            con.videoOrientation = AVCaptureVideoOrientationPortrait;
        }
            break;
            
        default:
            break;
    }
}

/*!
 *  Position the scanner's video image to match the device orientation.
 */
- (void)setVideoFrame
{
    CGFloat sw = self.screenWidth;
    CGFloat sh = self.screenHeight;
    
    // NSLog(@"ScreenWidth: %f", sw); //320
   
    // UIDeviceOrientation o = [[UIDevice currentDevice] orientation];
    
    switch ([[UIDevice currentDevice] orientation]) {
            //Seems to happen when the home button is on the RIGHT side. Works.
        case  UIDeviceOrientationLandscapeLeft :
            self.preview.frame = CGRectMake(sh - VIDEOSIZE - 8.0f, 8.0f, VIDEOSIZE, VIDEOSIZE);
            self.scannedLabel.textAlignment = NSTextAlignmentRight;
            self.typeLabel.textAlignment = NSTextAlignmentRight;
            break;
            
            //Seems to happen when the home button is on the LEFT side. Works.
        case UIDeviceOrientationLandscapeRight :
            self.preview.frame = CGRectMake(sh - VIDEOSIZE - 8.0f, 8.0f, VIDEOSIZE, VIDEOSIZE);
            self.scannedLabel.textAlignment = NSTextAlignmentRight;
            self.typeLabel.textAlignment = NSTextAlignmentRight;
            break;
            
            //Happens when the home button is on the bottom side. Works.
        case UIDeviceOrientationUnknown :
        case UIDeviceOrientationPortrait :
        case UIDeviceOrientationPortraitUpsideDown :
        case UIDeviceOrientationFaceUp :
        case UIDeviceOrientationFaceDown :
            self.preview.frame = CGRectMake((sw / 2) - (VIDEOSIZE/2), 8.0f, VIDEOSIZE, VIDEOSIZE);
            self.scannedLabel.textAlignment = NSTextAlignmentCenter;
            self.typeLabel.textAlignment = NSTextAlignmentCenter;
            break;
    }
}

/*!
 *  Change UI to refect that there are no camera's present/detected.
 */
- (void) setupNoCameraView
{
    UILabel *labelNoCam = [[UILabel alloc] init];
    
    labelNoCam.text = @"No Camera available";
    labelNoCam.textColor = [UIColor blackColor];
    [self.view addSubview:labelNoCam];
    
    [labelNoCam sizeToFit];
    
#warning Set Label at same spot as video inside a rectangle!
    
    labelNoCam.center = self.view.center;
    
    [self.scannedLabel setHidden:YES];
    [self.torchLabel setHidden:YES];
    [self.torchSwitch setHidden:YES];
}

/*!
 *  Setup the scanner for all kinds of code including QRCode and various BarCodes.
 */
- (void) setupScanner
{
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    self.session = [[AVCaptureSession alloc] init];
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    
    [self.session addOutput:self.output];
    [self.session addInput:self.input];
    
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeUPCECode,
                                        AVMetadataObjectTypeCode39Code,
                                        AVMetadataObjectTypeCode39Mod43Code,
                                        AVMetadataObjectTypeEAN13Code,
                                        AVMetadataObjectTypeEAN8Code,
                                        AVMetadataObjectTypeCode93Code,
                                        AVMetadataObjectTypeCode128Code,
                                        AVMetadataObjectTypePDF417Code,
                                        AVMetadataObjectTypeQRCode,
                                        AVMetadataObjectTypeAztecCode];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self setVideoFrame];
    
    //float margin = (self.screenWidth - VIDEOSIZE)/2.0f;
    //self.preview.frame = CGRectMake(8.0f, 8.0f, self.screenWidth - 2*8.0, VIDEOSIZE);
    //self.preview.frame = CGRectMake(margin, 8.0f, VIDEOSIZE, VIDEOSIZE);
 
    //!!! Replaces the next two lines.
    [self setVideoOrientation];

    [self.view.layer addSublayer:self.preview];
}

/*!
 *  Check if there is a camera available for use.
 *
 *  @return <#return value description#>
 */
- (BOOL) isCameraAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    return [videoDevices count] > 0;
}

/*!
 *  Turn the Torch.FlashLight on or off.
 *
 *  @param aStatus <#aStatus description#>
 */
-(void) setTorch:(BOOL) aStatus
{
  	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    [device lockForConfiguration:nil];
    if ( [device hasTorch] ) {
        if ( aStatus ) {
            [device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
    }
    [device unlockForConfiguration];
}

/*!
 *  Focus at a point (does not seem to work).
 *
 *  @param aPoint <#aPoint description#>
 */
- (void) focus:(CGPoint) aPoint
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if([device isFocusPointOfInterestSupported] &&
       [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        double screenWidth = screenRect.size.width;
        double screenHeight = screenRect.size.height;
        double focus_x = aPoint.x/screenWidth;
        double focus_y = aPoint.y/screenHeight;
        
        if([device lockForConfiguration:nil]) {
            if(self.delegate) {
                [self.delegate scanViewController:self didTapToFocusOnPoint:aPoint];
            }
            
            [self scanViewController:self didTapToFocusOnPoint:aPoint];
            
            [device setFocusPointOfInterest:CGPointMake(focus_x,focus_y)];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            
            if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
                [device setExposureMode:AVCaptureExposureModeAutoExpose];
            }
            
            [device unlockForConfiguration];
        }
    }
}

/*!
 *  Start scanning for codes.
 */
- (void)startScanning
{
    [self.session startRunning];
    
}

/*!
 *  Stop scanning for codes.
 */
- (void) stopScanning
{
    [self.session stopRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    for(AVMetadataObject *current in metadataObjects) {
        if([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            if(self.delegate) {
                NSString *scannedValue = [((AVMetadataMachineReadableCodeObject *) current) stringValue];
                NSString *scannedType = [((AVMetadataMachineReadableCodeObject *) current) type];
                [self.delegate scanViewController:self
                              didSuccessfullyScan:scannedValue
                          didSuccessfullyScanType:scannedType];
            }
        }
    }
}

- (void) scanViewController:(ARLScanViewController *) aCtler
       didTapToFocusOnPoint:(CGPoint) aPoint {
  
        NSLog(@"%@", NSStringFromCGPoint(aPoint));
}

- (void) scanViewController:(ARLScanViewController *) aCtler
        didSuccessfullyScan:(NSString *) aScannedValue
        didSuccessfullyScanType:(NSString *) aScannedType
{
    if (![self.scannedLabel.text isEqualToString:aScannedValue]) {
        self.scannedLabel.text = aScannedValue;
       
        NSOperation *delay = [[ARLDelayOperation alloc] initWithDelay:1000];
    
        NSBlockOperation *glow = [NSBlockOperation blockOperationWithBlock:^{
            self.scannedLabel.layer.shadowColor = [[UIColor greenColor] CGColor];
            self.scannedLabel.layer.shadowRadius = 8.0f;
            self.scannedLabel.layer.shadowOpacity = .9;
            //self.scannedLabel.layer.shadowOffset = CGSizeZero;
            self.scannedLabel.layer.masksToBounds = NO;
            
            self.scannedLabel.font = [UIFont boldSystemFontOfSize:self.scannedLabel.font.pointSize];
        }];
        
        NSBlockOperation *noglow = [NSBlockOperation blockOperationWithBlock:^{
            self.scannedLabel.layer.shadowColor = [[UIColor clearColor] CGColor];
            self.scannedLabel.layer.shadowRadius = 0.0f;
            self.scannedLabel.layer.shadowOpacity = 1.0f;
            //self.scannedLabel.layer.shadowOffset = CGSizeZero;
            //self.scannedLabel.layer.masksToBounds = NO;
            self.scannedLabel.font = [UIFont systemFontOfSize:self.scannedLabel.font.pointSize];
        }];
        
        [delay addDependency:glow];
        [noglow addDependency:delay];
        
        [[NSOperationQueue currentQueue] addOperations: @[delay] waitUntilFinished:NO];
        [[NSOperationQueue mainQueue] addOperations: @[noglow, glow] waitUntilFinished:NO];
    }

    self.typeLabel.text = aScannedType;
}

#pragma mark - Actions

/*!
 *  Action for the Torch button.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)torchSwitchAction:(UISwitch *)sender {
    [self setTorch:self.torchSwitch.isOn];
}

@end
