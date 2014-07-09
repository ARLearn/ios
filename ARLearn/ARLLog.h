//
//  INQLog.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 7/9/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/NSObject.h>
#import <UIKit/UIKit.h>

#import "ARLDefines.h"

/*!
 *  Log with date-time stamp using NSLog.
 *
 *  @param fmt The Format String
 *  @param ... The Arguments.
 */
#define DLog(fmt, ...) if (ARLLog.LogOn) { NSLog(@"[%s:%d] "fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }

/*!
 *  Log error with date-time stamp using NSLog.
 *
 *  @param error The NSError to log.
 */
#define ELog(error) if (ARLLog.LogOn && error) { NSLog(@"[%s:%d] %@ [%d]: %@", __PRETTY_FUNCTION__, __LINE__, NSLocalizedString(@"Error", @"Error"), [error code], [error localizedDescription] ); }

/*!
 *  Log an error message with date-time stamp using NSLog.
 */
#define EELog() if (ARLLog.LogOn) { NSLog(@"[%s:%d] %@", __PRETTY_FUNCTION__, __LINE__, NSLocalizedString(@"Error", @"Error") ); }

/*!
 *  Log message without date-time stamp using CFShow.
 *
 *  @param fmt The Format String
 *  @param ... The Arguments.
 */
#define CLog(fmt, ...) if (ARLLog.LogOn) { CFShow((__bridge CFTypeRef)[NSString stringWithFormat:@"[%s:%d]| "fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]); }

/*!
 *  Log message without date-time stamp using CFShow.
 *
 *  @param fmt The Format String
 *  @param ... The Arguments.
 */
#define Log(fmt, ...) CFShow((__bridge CFTypeRef)[NSString stringWithFormat:@"[%s:%d]| "fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]);


@interface ARLLog : NSObject

+ (BOOL *)LogOn;

@end
