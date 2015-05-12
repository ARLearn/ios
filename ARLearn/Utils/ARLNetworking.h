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
    
    /*!
     *  WeSpot.
     */
    WESPOT,
    
    /*!
     *  Eco.
     */
    ECO,
    
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
+ (void) sendHTTPGetWithDelegate:(id <NSURLSessionDelegate>)delegate
                     withService:(NSString *)service;

+ (NSString *)generateGetDescription:(NSString *)service;

/*!
 *  Asynchronous.
 *
 *  @param delegate <#delegate description#>
 *  @param service  <#service description#>
 *  @param body     <#body description#>
 */
+ (void) sendHTTPPostWithDelegate:(id <NSURLSessionDelegate>)delegate
                      withService:(NSString *)service
                         withBody:(NSString *)body;

/*!
 *  Generate a Cache Identifier based on Url and Body (if present).
 *
 *  @param service <#service description#>
 *  @param body    <#body description#>
 *
 *  @return <#return value description#>
 */
+ (NSString *)generatePostDescription:(NSString *)service
                             withBody:(NSString *)body;

/*!
 *  Synchronous.
 *
 *  @param service <#service description#>
 *
 *  @return <#return value description#>
 */
+ (NSData *)sendHTTPGetWithAuthorization:(NSString *)service;

/*!
 *  Post a URL's content synchronously
 *
 *  @param service The Rest Service Url part.
 *
 *  @return the URL's content as NSData.
 */
+(NSData *)sendHTTPPostWithAuthorization:(NSString *)service
                                    json:(NSDictionary *)json;

/*!
 *  Get a URL's content synchronously
 *
 *  @param service The Rest Service Url part.
 *
 *  @return the URL's content as NSData.
 */
+(NSData *)sendHTTPPostWithAuthorization:(NSString *)service
                                    data:(NSData *)body
                              withAccept:(NSString *)withAccept
                         withContentType:(NSString *)withContentType;

+ (NSData *)executeARLearnDeleteWithAuthorization:(NSString *)service;

+ (void) setupOauthInfo;

+ (BOOL)networkAvailable;
+ (BOOL)isLoggedIn;
+ (Account *) CurrentAccount ;

+ (NSString *) facebookLoginString;
+ (NSString *) googleLoginString;
+ (NSString *) linkedInLoginString;
+ (NSString *) twitterLoginString;
+ (NSString *) wespotLoginString;
+ (NSString *) ecoLoginString;

+ (NSString *) MakeRestUrl:(NSString *) service;

+ (NSDictionary *) accountDetails;

+ (NSData *) getUserInfo:(NSNumber *)runId
                        userId:(NSString *)userId
                    providerId:(NSString *)providerId;

+ (NSData *) createRun:(NSNumber *)gameId
             withTitle:(NSString *)runTitle;

@end
