//
//  ARLBeanNamesm
//  ARLearn
//
//  Created by G.W. van der Vegt on 05/12/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLBeanNames.h"

//@interface ARLBeanNames ()
//
//@end

@implementation ARLBeanNames

@synthesize beanNames;

+(NSDictionary*) beanNames
{
    static NSDictionary* _beanNames = nil;
    
    if (_beanNames == nil)
    {
        // create dict
        _beanNames =
        @{
            @"invalid": @(Invalid),
            
            @"org.celstec.arlearn2.beans.dependencies.ActionDependency": @(ActionDependency),
            @"org.celstec.arlearn2.beans.dependencies.ProximityDependency": @(ProximityDependency),
            @"org.celstec.arlearn2.beans.dependencies.TimeDependency": @(TimeDependency),
            @"org.celstec.arlearn2.beans.dependencies.OrDependency": @(OrDependency),
            @"org.celstec.arlearn2.beans.dependencies.AndDependency": @(AndDependency),
            
            @"org.celstec.arlearn2.beans.generalItem.AudioObject": @(AudioObject),
            @"org.celstec.arlearn2.beans.generalItem.GeneralItemList": @(GeneralItemList),
            @"org.celstec.arlearn2.beans.generalItem.NarratorItem": @(NarratorItem),
            @"org.celstec.arlearn2.beans.generalItem.FileReference": @(FileReference),
            @"org.celstec.arlearn2.beans.generalItem.ScanTag": @(ScanTag),
            @"org.celstec.arlearn2.beans.generalItem.OpenQuestion": @(OpenQuestion),
            @"org.celstec.arlearn2.beans.generalItem.SingleChoiceTest": @(SingleChoiceTest),
            @"org.celstec.arlearn2.beans.generalItem.MultipleChoiceTest": @(MultipleChoiceTest),
            @"org.celstec.arlearn2.beans.generalItem.MultipleChoiceAnswerItem": @(MultipleChoiceAnswerItem),
            
            @"org.celstec.arlearn2.beans.game.Config": @(ConfigBean),
            @"org.celstec.arlearn2.beans.game.Game": @(GameBean),
            @"org.celstec.arlearn2.beans.game.GameFile": @(GameFileBean),
            
            @"org.celstec.arlearn2.beans.run.Run": @(RunBean),
            @"org.celstec.arlearn2.beans.run.RunList": @(RunList),
            
            @"org.celstec.arlearn2.beans.run.ResponseList": @(ResponseList),
        };
        
    }
    
    return _beanNames;
}

+(BeanIds) beanTypeToBeanId:(NSString *)type {
    return (BeanIds)[[self.beanNames valueForKey:type] integerValue];
}

+(NSString *) beanIdToBeanName:(BeanIds)bid {
    for (NSString *key in ARLBeanNames.beanNames) {
        int val = [[ARLBeanNames.beanNames valueForKey:key] intValue];
        if (val == (int)bid) {
            NSRange r = [key rangeOfString:@"." options:NSBackwardsSearch];
            if (r.location == NSNotFound) {
                return key;
            }else {
                return [key substringFromIndex:r.location + 1];
            }
        }
    }
    
    return [ARLBeanNames beanIdToBeanName:Invalid];
}

@end
