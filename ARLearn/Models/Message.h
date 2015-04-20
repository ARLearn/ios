//
//  Message.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 20/04/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, Run;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * date;
@property (nonatomic, retain) NSNumber * messageId;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSNumber * threadId;
@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) Run *run;

@end
