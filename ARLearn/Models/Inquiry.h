//
//  Inquiry.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/16/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Run;

@interface Inquiry : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * hypothesis;
@property (nonatomic, retain) NSData * icon;
@property (nonatomic, retain) NSNumber * inquiryId;
@property (nonatomic, retain) NSString * reflection;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Run *run;

@end
