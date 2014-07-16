//
//  GeneralItemData.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/16/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GeneralItem;

@interface GeneralItemData : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSNumber * error;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * replicated;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) GeneralItem *generalItem;

@end
