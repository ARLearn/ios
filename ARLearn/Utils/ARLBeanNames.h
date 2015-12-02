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
    ActionDependency,           //ok
    ProximityDependency,
    TimeDependency,             //??
    OrDependency,               //ok
    AndDependency,              //ok
    
    // GeneralItems
    AudioObject,                //ok
    VideoObject,
    GeneralItemList,            //??
    NarratorItem,               //ok
    FileReference,              //??
    ScanTag,                    //??
    OpenQuestion,               //??
    SingleChoiceTest,           //ok
    MultipleChoiceTest,         //ok
    MultipleChoiceAnswerItem,
    
    // Game
    ConfigBean,
    GameBean,
    GameFileBean,
    GameList,
    
    // Run
    RunBean,
    RunList,
    
    // Response
    ResponseList,
    
    // Categories
    CategoryList,
    Category,
    GameCategoryList,
    GameCategory
} BeanIds;

@interface ARLBeanNames : NSObject

@property (nonatomic, readonly)  NSDictionary *beanNames;

+(BeanIds) beanTypeToBeanId:(NSString *)type;

+(NSString *) beanIdToBeanName:(BeanIds)bid;

+(NSString *) beanIdToBeanType:(BeanIds)bid;

@end