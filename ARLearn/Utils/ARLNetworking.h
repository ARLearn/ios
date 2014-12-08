//
//  ARLNetworking.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/16/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#include "NSURLSession+SynchronousTask.h"

#include "ARLAppDelegate.h"

#include "Account.h"

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

/*!
 *  Asynchronous.
 *
 *  @param delegate <#delegate description#>
 *  @param service  <#service description#>
 */
+ (void) sendHTTPGetWithDelegate:(id <NSURLSessionDelegate>)delegate withService:(NSString *)service;

+ (NSString *)generateGetDescription:(NSString *)service;

/*!
 *  Asynchronous.
 *
 *  @param delegate <#delegate description#>
 *  @param service  <#service description#>
 *  @param body     <#body description#>
 */
+ (void) sendHTTPPostWithDelegate:(id <NSURLSessionDelegate>)delegate withService:(NSString *)service withBody:(NSString *)body;

+ (NSString *)generatePostDescription:(NSString *)service withBody:(NSString *)body;

/*!
 *  Synchronous.
 *
 *  @param service <#service description#>
 *
 *  @return <#return value description#>
 */
+ (NSData *)sendHTTPGetWithAuthorization:(NSString *) service;

+ (void) setupOauthInfo;

+ (BOOL)networkAvailable;
+ (BOOL)isLoggedIn;

+ (NSString *) facebookLoginString;
+ (NSString *) googleLoginString;
+ (NSString *) linkedInLoginString;
+ (NSString *) twitterLoginString;

+ (NSDictionary *) accountDetails;

@end
