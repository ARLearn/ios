//
//  Account.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 20/04/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Action, Message, Response;

@interface Account : NSManagedObject

@property (nonatomic, retain) NSNumber * accountLevel;
@property (nonatomic, retain) NSNumber * accountType;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * familyName;
@property (nonatomic, retain) NSString * givenName;
@property (nonatomic, retain) NSString * localId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * picture;
@property (nonatomic, retain) NSSet *actions;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *responses;
@end

@interface Account (CoreDataGeneratedAccessors)

- (void)addActionsObject:(Action *)value;
- (void)removeActionsObject:(Action *)value;
- (void)addActions:(NSSet *)values;
- (void)removeActions:(NSSet *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addResponsesObject:(Response *)value;
- (void)removeResponsesObject:(Response *)value;
- (void)addResponses:(NSSet *)values;
- (void)removeResponses:(NSSet *)values;

@end
