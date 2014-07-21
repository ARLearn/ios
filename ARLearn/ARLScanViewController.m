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

@end

@implementation ARLScanViewController

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
    if(![self isCameraAvailable]) {
        [self setupNoCameraView];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startScanning];
}

/*!
 *  See https://gist.github.com/Alex04/6976945
 *  See http://www.ama-dev.com/iphone-qr-code-library-ios-7/
 *  See http://stackoverflow.com/questions/5117770/avcapturevideopreviewlayer
 *  See http://stackoverflow.com/questions/16515921/get-camera-preview-to-avcapturevideopreviewlayer
 *
 *  See http://www.qr-code-generator.com
 * 
 *  TODO Only Landscape/Left works ok. Should change that.
 *  TODO Add Constraints.
 *  TODO Add Focus Button.
 *  TODO Add Torch Button.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]];
    
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
//    self.view.layer.contents = (id)[UIImage imageNamed:@"Background"].CGImage;
    
    if([self isCameraAvailable]) {
        [self setupScanner];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
{
    return (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
        AVCaptureConnection *con = self.preview.connection;
        con.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    } else {
        AVCaptureConnection *con = self.preview.connection;
        con.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
}

#pragma mark - Methods

- (void) setupNoCameraView
{
    UILabel *labelNoCam = [[UILabel alloc] init];
    labelNoCam.text = @"No Camera available";
    labelNoCam.textColor = [UIColor blackColor];
    [self.view addSubview:labelNoCam];
    [labelNoCam sizeToFit];
    labelNoCam.center = self.view.center;
}

- (void) setupScanner
{
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    self.session = [[AVCaptureSession alloc] init];
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:self.output];
    [self.session addInput:self.input];
    
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.preview.frame = CGRectMake(10, 10, 200, 200);
                                    
    AVCaptureConnection *con = self.preview.connection;
    
    con.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    
    //[self.view.layer insertSublayer:self.preview atIndex:0];
    [self.view.layer addSublayer:self.preview];
}

- (BOOL) isCameraAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return [videoDevices count] > 0;
}

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
//            if([self.delegate respondsToSelector:@selector(scanViewController:didTapToFocusOnPoint:)]) {
//                [self.delegate scanViewController:self didTapToFocusOnPoint:aPoint];
//            }
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

- (void)startScanning
{
    [self.session startRunning];
    
}

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
            //if([self.delegate respondsToSelector:@selector(scanViewController:didSuccessfullyScan:)]) {
                NSString *scannedValue = [((AVMetadataMachineReadableCodeObject *) current) stringValue];
                // [self.delegate scanViewController:self didSuccessfullyScan:scannedValue];
                [self scanViewController:self didSuccessfullyScan:scannedValue];
            //}
        }
    }
}

- (void) scanViewController:(ARLScanViewController *) aCtler
       didTapToFocusOnPoint:(CGPoint) aPoint {
  
        NSLog(@"%@", NSStringFromCGPoint(aPoint));
}

- (void) scanViewController:(ARLScanViewController *) aCtler
        didSuccessfullyScan:(NSString *) aScannedValue
{
   // NSLog(@"%@", aScannedValue);
    
    self.scannedLabel.text = aScannedValue;
}

@end
