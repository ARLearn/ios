//
//  ARLBeanNames.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 06/01/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#define read_action @"read"
#define complete_action @"complete"
#define answer_given_action @"answer_given"

typedef enum {
    Invalid,
    
    // Dependencies
    ActionDependency,
    ProximityDependency,
    TimeDependency,
    OrDependency,
    AndDependency,
    
    // GeneralItems
    AudioObject,
    GeneralItemList,
    NarratorItem,
    FileReference,
    ScanTag,
    OpenQuestion,
    SingleChoiceTest,
    MultipleChoiceTest,
    MultipleChoiceAnswerItem,
    
    // Game
    ConfigBean,
    GameBean,
    GameFileBean,
    
    // Run
    RunBean,
    RunList,
    
    // Response
    ResponseList,
} BeanIds;

@interface ARLBeanNames : NSObject

@property (nonatomic, readonly)  NSDictionary *beanNames;

+(BeanIds) beanTypeToBeanId:(NSString *)type;
+(NSString *) beanIdToBeanName:(BeanIds)bid;

@end