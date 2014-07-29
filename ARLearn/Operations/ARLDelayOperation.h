//
//  ARLDelayOperation.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/28/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARLDelayOperation : NSOperation

/*!
 *  Delay 100ms.
 *
 *  @return The NSOperation
 */
- (id)init;

/*!
 *  Delay.
 *
 *  @param delay Delay in msec
 *
 *  @return The NSOperation
 */
- (id)initWithDelay:(int)delay;

@end
