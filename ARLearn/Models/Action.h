//
//  Action.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 20/04/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
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
