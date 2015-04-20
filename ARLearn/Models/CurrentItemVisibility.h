//
//  CurrentItemVisibility.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 20/04/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GeneralItem, Run;

@interface CurrentItemVisibility : NSManagedObject

@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) GeneralItem *item;
@property (nonatomic, retain) Run *run;

@end
