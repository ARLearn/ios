//
//  ARLNetworking.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/16/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#include "NSURLSession+SynchronousTask.h"

#include "ARLAppDelegate.h"

@interface ARLNetworking : NSObject

/*!
 *  ID's and order of the cells.
 
 *  Must match ARLNetwork oauthInfo!
 */
typedef NS_ENUM(NSInteger, services) {
    /*!
     *  Internal (Admin).
     */
    INTERNAL = 0,
    
    /*!
     *  Facebook.
     */
    FACEBOOK = 1,
    
    /*!
     *  Google.
     */
    GOOGLE,
    
    /*!
     *  Linked-in
     */
    LINKEDIN,
    
    /*!
     *  Twitter.
     */
    TWITTER,
    
    ///*!
    // *  WeSpot.
    // */
    //    WESPOT,
    
    /*!
     *  Number of oAuth Services.
    */
    numServices
};


+(void) sendHTTPGetWithDelegate:(id <NSURLSessionDelegate>)delegate withService:(NSString *)service;
+(NSString *)generateGetDescription:(NSString *)service;

+(void) sendHTTPPostWithDelegate:(id <NSURLSessionDelegate>)delegate withService:(NSString *)service withBody:(NSString *)body;
+(NSString *)generatePostDescription:(NSString *)service withBody:(NSString *)body;

+(void) setupOauthInfo;

@property (readonly, strong, nonatomic) NSString *facebookLoginString;
@property (readonly, strong, nonatomic) NSString *googleLoginString;
@property (readonly, strong, nonatomic) NSString *linkedInLoginString;
@property (readonly, strong, nonatomic) NSString *twitterLoginString;

+ (BOOL)networkAvailable;

@end
