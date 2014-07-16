//
//  Action.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/16/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, GeneralItem, Run;

@interface Action : NSManagedObject

@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSNumber * synchronized;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) GeneralItem *generalItem;
@property (nonatomic, retain) Run *run;

@end
