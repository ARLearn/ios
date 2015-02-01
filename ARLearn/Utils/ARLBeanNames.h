//
//  ARLBeanNames.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 06/01/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

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
    ResponseList,
} BeanIds;

@interface ARLBeanNames : NSObject

@property (nonatomic, readonly)  NSDictionary *beanNames;

+(BeanIds) beanTypeToBeanId:(NSString *)type;
+(NSString *) beanIdToBeanName:(BeanIds)bid;

@end