//
//  ARLCoreDataUtils.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 20/04/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#include "ARLNetworking.h"
#include "ARLLog.h"
#include "ARLSynchronisation.h"

#include "Action.h"
#include "GeneralItem.h"

@interface ARLCoreDataUtils : NSObject

+ (void)CreateOrUpdateAction:(NSNumber *)runId
                  activeItem:(GeneralItem *)activeItem
                        verb:(NSString *)verb;
/*!
 *  Mark the ActiveItem as Read.
 */
+ (void)MarkAnswerAsGiven:(NSNumber*)runId
            generalItemid:(NSNumber *)generalItemId
                 answerId:(NSString *)answerId;
@end
