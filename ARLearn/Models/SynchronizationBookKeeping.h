//
//  SynchronizationBookKeeping.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 20/04/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SynchronizationBookKeeping : NSManagedObject

@property (nonatomic, retain) NSNumber * context;
@property (nonatomic, retain) NSNumber * lastSynchronization;
@property (nonatomic, retain) NSString * type;

@end
