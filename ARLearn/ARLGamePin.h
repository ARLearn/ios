//
//  ARLGamePin.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/25/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARLGamePin : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subTitle;
    MKPinAnnotationColor *pinColor;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

@property (nonatomic, readonly) MKPinAnnotationColor *pinColor;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description pinColor:(MKPinAnnotationColor)pinColor;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end

