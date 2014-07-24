//
//  ARLNearbyViewController.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/22/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "ARLNearbyViewController.h"

@interface ARLNearbyViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

#pragma mark - ViewController

// See https://developers.google.com/maps/documentation/ios/start

@implementation ARLNearbyViewController

@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.mapView.delegate = self;
   
    //if ([ARLAppDelegate CurrentLocation]) {
        [self.mapView setShowsUserLocation:YES];
    //}
    
    //??? didFailToLocateUserWithError sometimes called.
    //MKCoordinateRegion zoomRegion = MKCoordinateRegionMakeWithDistance([ARLAppDelegate CurrentLocation], 1500, 1500);
    
    //[self.mapView setRegion:zoomRegion animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    DLog(@"lat: %f, lng: %f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);

    CLLocationCoordinate2D newLocation = [userLocation coordinate];

    MKCoordinateRegion zoomRegion = MKCoordinateRegionMakeWithDistance(newLocation, 250, 250);
    
    [self.mapView setRegion:zoomRegion animated:YES];
    // [self.mapView regionThatFits:zoomRegion];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    if (error != nil) {
        DLog(@"locate failed: %@", [error localizedDescription]);
    } else {
        DLog(@"locate failed");
    }
}

#pragma mark - Properties

#pragma mark - Methods

@end
