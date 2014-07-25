//
//  ARLGamePin.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/25/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLGamePin.h"

@implementation ARLGamePin

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize pinColor;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description pinColor:(MKPinAnnotationColor)color {
    self = [super init];
    
    if (self) {
        coordinate = location;
        title = placeName;
        subtitle = description;
        pinColor = (MKPinAnnotationColor *)color;
    }
    
    return self;
}

- (id)initWithCoordinates:(CLLocationCoordinate2D)location {
    return [self initWithCoordinates:location placeName:nil description:nil pinColor:MKPinAnnotationColorRed];
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    DLog(@"");

    //TODO Implement
}

@end
