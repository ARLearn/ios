//
//  Inquiry.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 20/04/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
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
