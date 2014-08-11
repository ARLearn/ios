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

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *nearbyGamesTable;

@property (nonatomic, strong) NSArray *results;

@property (readonly, nonatomic) NSString *query;

@property (readonly, nonatomic) NSString *cellIdentifier;

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, ARLNearbyViewControllerGroups) {
    /*!
     *  NearBy Search Results.
     */
    NEARBYRESULTS = 0,
    
    /*!
     *  Number of Groups
     */
    numARLNearByViewControllerGroups
};

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
    
//    self.portraitView = self.portrait;
//    self.landscapeView = self.landscape;
    // self.view = self.portrait;
    
    // Do any additional setup after loading the view.
    self.mapView.delegate = self;
    
    [self.mapView setShowsUserLocation:YES];
    
    //??? didFailToLocateUserWithError sometimes called.
    //MKCoordinateRegion zoomRegion = MKCoordinateRegionMakeWithDistance([ARLAppDelegate CurrentLocation], 1500, 1500);
    
    //[self.mapView setRegion:zoomRegion animated:YES];
    
    [self applyConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    @autoreleasepool {
        CLLocationCoordinate2D location = [ARLAppDelegate CurrentLocation];
        
        _query = [NSString stringWithFormat:@"myGames/search/lat/%f/lng/%f/distance/%d", location.latitude, location.longitude, 25000];
        
        NSString *cacheIdentifier = [ARLNetworking generateGetDescription:self.query];
        
        NSData *response = [[ARLAppDelegate theQueryCache] getResponse:cacheIdentifier];
        
        if (!response) {
            [ARLNetworking sendHTTPGetWithDelegate:self withService:self.query];
        } else {
            NSLog(@"Using cached query data");
            [self processData:response];
        }
    }
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.mapView.delegate = nil;
    self.mapView = nil;

     _query = nil;
    _results = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
     _results =  nil;
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

    if ([annotation isKindOfClass:[ARLGamePin class]]) {
        annView.pinColor = (MKPinAnnotationColor)((ARLGamePin *)annotation).pinColor;
    }

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
    
    // [ARLUtils LogJsonData:data url:[[[dataTask response] URL] absoluteString]];

    [self processData:data];
    
    [ARLQueryCache addQuery:dataTask.taskDescription withResponse:data];
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


#pragma mark - TabelViewController

/*!
 *  Number of Sections of the Table.
 *
 *  @param tableView The TableView
 *
 *  @return The number of Groups.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return numARLNearByViewControllerGroups;
}

/*!
 *  Number of Tabel Rows in a Section.
 *
 *  @param tableView The TableView
 *  @param section   The Section
 *
 *  @return The number of Rows in the Section.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case NEARBYRESULTS : {
            return 2;
        }
    }
    
    // Should not happen!!
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case NEARBYRESULTS : {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
            
            switch (indexPath.item) {
                case 0:
                    cell.textLabel.text = @"Game1";
                    cell.detailTextLabel.text = @"Starting tomorrow";
                    break;
                case 1:
                    cell.textLabel.text = @"Game2";
                    cell.detailTextLabel.text = @"Starting now";
                    break;
            }
            cell.imageView.image = [UIImage imageNamed:@"MyGames"];
            
            return cell;
        }
    }
    
    // Should not happen!!
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;{
    switch (section) {
        case NEARBYRESULTS : {
            return @"Nearby games";
        }
    }
    
    // Should not happen!!
    return @"";
}

#pragma mark - Properties

/*!
 *  Getter
 *
 *  @return The Cell Identifier.
 */
-(NSString *) cellIdentifier {
    return  @"aNearByGames";
}

#pragma mark - Methods

- (void) reloadMap {
    [self.mapView setShowsUserLocation:NO];
    
    @autoreleasepool {
        
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
}

- (void)processData:(NSData *)data
{
    //Example Data:
    //
    //{
    // "type": "org.celstec.arlearn2.beans.game.GamesList",
    // "games": [
    //           {
    //               "type": "org.celstec.arlearn2.beans.game.Game",
    //               "gameId": 27766001,
    //               "title": "Heerlen game met Mark",
    //               "config": {
    //                   "type": "org.celstec.arlearn2.beans.game.Config",
    //                   "mapAvailable": false,
    //                   "manualItems": [],
    //                   "locationUpdates": []
    //               },
    //               "lng": 5.958768,
    //               "lat": 50.878495,
    //               "language": "en"
    //           },
    //           ]
    //}
    
    @autoreleasepool {
        NSDictionary *json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        self.results = (NSArray *)[json objectForKey:@"games"];
        
        [self reloadMap];
    }
    
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
    @autoreleasepool {
        NSArray *annotations = map.annotations;
        int count = [map.annotations count];
        
        if (count == 0) { return; } //bail if no annotations
        
        //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
        //can't use NSArray with MKMapPoint because MKMapPoint is not an id
        MKMapPoint points[count]; //C array of MKMapPoint struct
        for (int i=0; i<count; i++) //load points C array by converting coordinates to points
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
        if (region.span.latitudeDelta > MAX_DEGREES_ARC) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
        if (region.span.longitudeDelta > MAX_DEGREES_ARC){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
        
        //and don't zoom in stupid-close on small samples
        if (region.span.latitudeDelta  < MINIMUM_ZOOM_ARC) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
        if (region.span.longitudeDelta < MINIMUM_ZOOM_ARC) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
        
        //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
        if (count == 1)
        {
            region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
            region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
        }
        
        [mapView setRegion:region animated:animated];
    }
}

- (void) applyConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,             @"view",
                                     
                                     self.backgroundImage,  @"backgroundImage",
                                     
                                     self.mapView,          @"mapView",
                                     self.nearbyGamesTable, @"nearbyGamesTable",
                                     
                                     nil];
    
    // See http://stackoverflow.com/questions/17772922/can-i-use-autolayout-to-provide-different-constraints-for-landscape-and-portrait
    // See https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/Bars.html
    
    //    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.mapView.translatesAutoresizingMaskIntoConstraints =NO;
    self.nearbyGamesTable.translatesAutoresizingMaskIntoConstraints = NO;
    
    // CGFloat sw = self.screenWidth;
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
    
    // Fix Map & Table Horizontal.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[mapView]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[nearbyGamesTable]-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
        // Fix Map & Table Vertically.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-[mapView]-[nearbyGamesTable(200)]-|"]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}

@end
