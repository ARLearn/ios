//
//  SynchronizationBookKeeping.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/16/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SynchronizationBookKeeping : NSManagedObject

@property (nonatomic, retain) NSNumber * context;
@property (nonatomic, retain) NSNumber * lastSynchronization;
@property (nonatomic, retain) NSString * type;

@end
