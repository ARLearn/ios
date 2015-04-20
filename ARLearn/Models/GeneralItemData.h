//
//  GeneralItemData.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 20/04/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
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
