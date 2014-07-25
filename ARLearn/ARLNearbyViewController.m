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

@property (nonatomic, strong) NSArray *results;

@property (readonly, nonatomic) NSString *query;

@end

#pragma mark - ViewController

// See https://developers.google.com/maps/documentation/ios/start

@implementation ARLNearbyViewController

@synthesize mapView;

@synthesize results = _results;
@synthesize query = _query;

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
    
    CLLocationCoordinate2D location = [ARLAppDelegate CurrentLocation];

    _query = [NSString stringWithFormat:@"myGames/search/lat/%f/lng/%f/distance/%d", location.latitude, location.longitude, 25000];
    
    [ARLNetworking sendHTTPGetWithDelegate:self withService:self.query];
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

- (MKAnnotationView *) mapView:(MKMapView *)mapView
             viewForAnnotation:(id <MKAnnotation>) annotation {
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc]
                                  initWithAnnotation:annotation reuseIdentifier:@"pin"];
   
    NSLog(@"%d %@", [[self.mapView annotations] indexOfObject:annotation], [annotation title]);
    // First pin is home.
    //if ([[self.mapView annotations] indexOfObject:annotation] != 0) {
    if ([annotation isKindOfClass:[ARLGamePin class]]) {

        annView.pinColor = (MKPinAnnotationColor)((ARLGamePin *)annotation).pinColor;
    }
    //}

    return annView;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"Got HTTP Response");
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    NSLog(@"Got HTTP Data");
    
    //NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // NSLog(@"Received String %@",str);
    
    [ARLUtils LogJsonData:data url:[[[dataTask response] URL] absoluteString]];
    
    NSDictionary *json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    self.results = (NSArray *)[json objectForKey:@"games"];
    
    [self reloadMap];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSLog(@"Completed HTTP Task");
    
    if(error == nil)
    {
        // Update UI Here?
        NSLog(@"Download is Succesfull");
    }
    else
        NSLog(@"Error %@",[error userInfo]);
}

#pragma mark - Properties

#pragma mark - Methods

- (void) reloadMap {
    [self.mapView setShowsUserLocation:NO];

    //games to markers.
    //bounds around games.
    
    //Ourselves.
    {
        CLLocationCoordinate2D  ctrpoint;
        ctrpoint.latitude = 50.964428;
        ctrpoint.longitude = 5.774894;
        
        ARLGamePin *gp = [[ARLGamePin alloc] initWithCoordinates:ctrpoint
                                                       placeName:@"me"
                                                     description:nil
                                                        pinColor:MKPinAnnotationColorRed];
        
        [self.mapView addAnnotation:gp];
    }
    
    for (NSDictionary *game in self.results) {
        {
            CLLocationCoordinate2D  ctrpoint;
            ctrpoint.latitude = [[game valueForKey:@"lat"] doubleValue];
            ctrpoint.longitude =[[game valueForKey:@"lng"] doubleValue];
            
            ARLGamePin *gp = [[ARLGamePin alloc] initWithCoordinates:ctrpoint
                                                           placeName:[game valueForKey:@"title"]
                                                         description:[NSString stringWithFormat:@"[%@]", [game valueForKey:@"language"]]
                                                            pinColor:MKPinAnnotationColorGreen];
            [self.mapView addAnnotation:gp];
        }
    }
    
    [self zoomMapViewToFitAnnotations:self.mapView animated:TRUE];
}

/*!
 *  Size the mapView region to fit its annotations
 *
 *  See http://brianreiter.org/2012/03/02/size-an-mkmapview-to-fit-its-annotations-in-ios-without-futzing-with-coordinate-systems/
 *
 *  @param mapView  <#mapView description#>
 *  @param animated <#animated description#>
 */
- (void)zoomMapViewToFitAnnotations:(MKMapView *)map animated:(BOOL)animated
{
#define MINIMUM_ZOOM_ARC                0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR    1.5
#define MAX_DEGREES_ARC                 360
    
    NSArray *annotations = map.annotations;
    int count = [map.annotations count];
    
    if ( count == 0) { return; } //bail if no annotations
    
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    MKMapPoint points[count]; //C array of MKMapPoint struct
    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
    
    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if( count == 1 )
    {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    
    [mapView setRegion:region animated:animated];
}

@end
