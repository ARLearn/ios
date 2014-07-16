//
//  CurrentItemVisibility.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/16/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GeneralItem, Run;

@interface CurrentItemVisibility : NSManagedObject

@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) GeneralItem *item;
@property (nonatomic, retain) Run *run;

@end
