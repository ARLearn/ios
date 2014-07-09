//
//  INQLog.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 7/9/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//


#import "ARLLog.h"
#import "ARLAppDelegate.h"

/*!
 *  See http://iphonedevsdk.com/forum/iphone-sdk-development/6319-a-better-nslog-selectively-turning-logging-off.html
 *  See http://stackoverflow.com/questions/969130/how-to-print-out-the-method-name-and-line-number-and-conditionally-disable-nslog
 *  See http://github.com/InderKumarRathore/MLog/blob/master/MLog.h
 */

@implementation ARLLog

static BOOL _logOn = YES;

//+ (void)setLogOn:(BOOL *)value
//{
//	_logOn = value;
//    
//}

+ (BOOL *)LogOn {
    _logOn = [[NSUserDefaults standardUserDefaults] boolForKey:ENABLE_LOGGING];
    return _logOn;
}

@end
