//
//  Run.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 28/04/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Action, CurrentItemVisibility, Game, GeneralItemVisibility, Inquiry, Message, Response;

@interface Run : NSManagedObject

@property (nonatomic, retain) NSNumber * revoked;
@property (nonatomic, retain) NSNumber * gameId;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSNumber * runId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *actions;
@property (nonatomic, retain) NSSet *currentVisibility;
@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) Inquiry *inquiry;
@property (nonatomic, retain) NSSet *itemVisibilityRules;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *responses;
@end

@interface Run (CoreDataGeneratedAccessors)

- (void)addActionsObject:(Action *)value;
- (void)removeActionsObject:(Action *)value;
- (void)addActions:(NSSet *)values;
- (void)removeActions:(NSSet *)values;

- (void)addCurrentVisibilityObject:(CurrentItemVisibility *)value;
- (void)removeCurrentVisibilityObject:(CurrentItemVisibility *)value;
- (void)addCurrentVisibility:(NSSet *)values;
- (void)removeCurrentVisibility:(NSSet *)values;

- (void)addItemVisibilityRulesObject:(GeneralItemVisibility *)value;
- (void)removeItemVisibilityRulesObject:(GeneralItemVisibility *)value;
- (void)addItemVisibilityRules:(NSSet *)values;
- (void)removeItemVisibilityRules:(NSSet *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addResponsesObject:(Response *)value;
- (void)removeResponsesObject:(Response *)value;
- (void)addResponses:(NSSet *)values;
- (void)removeResponses:(NSSet *)values;

@end
