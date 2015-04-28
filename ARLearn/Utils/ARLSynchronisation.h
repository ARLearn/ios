//
//  ARLSynchronisation.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 28/04/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARLNetworking.h"

@interface ARLSynchronisation : NSObject

+(void) PublishActionsToServer;

+(void) DownloadGeneralItemVisibilities:(NSNumber *)runId;

+(void) DownloadResponses:(NSNumber *)runId;

+(void) DownloadGeneralItems:(NSNumber *)gameId;

/*!
 *  Downloads Actions of the Run we're participating in.
 *
 *  Runs in a background thread.
 */
+(void) DownloadActions:(NSNumber *)runId;

/*!
 *  Downloads Runs we're participating in.
 *
 *  Runs in a background thread.
 */
+(void) DownloadRuns:(NSNumber *)gameId;

+(void) PublishResponsesToServer;

@end
