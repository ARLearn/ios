//
//  ARLNetworking.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/16/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLNetworking.h"

@implementation ARLNetworking

static NSString *_facebookLoginString;
static NSString *_googleLoginString;
static NSString *_linkedInLoginString;
static NSString *_twitterLoginString;

#pragma mark Properties

+ (NSString *) facebookLoginString {
    return _facebookLoginString;
}

+ (NSString *) googleLoginString {
    return _googleLoginString;
}

+ (NSString *) linkedInLoginString {
    return _linkedInLoginString;
}

+ (NSString *) twitterLoginString {
    return _twitterLoginString;
}

+ (NSString *) MakeRestUrl:(NSString *) service {
    if ([service hasPrefix:@"/"]) {
        return [NSString stringWithFormat:@"%@%@", serverUrl, service];
    } else {
        return [NSString stringWithFormat:serviceUrlFmt, serverUrl, service];
    }
    // return [NSString stringWithFormat:serviceUrlFmt, serverUrl, service];
}

+ (NSDictionary *) accountDetails {
    NSData *data = [self sendHTTPGetWithAuthorization:[NSString stringWithFormat:@"account/accountDetails"]];
    
    NSError *error = nil;
    
    NSDictionary *details = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                     error:&error] : nil;
    ELog(error);
    
    return details;
}

/*!
 *  Returns YES if a wifi connection is available.
 *
 *  @return YES if wifi is there.
 */
+ (BOOL) networkAvailable {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSNumber *result = nil;
    
    if ([appDelegate respondsToSelector:@selector(networkAvailable)]) {
        result = [appDelegate performSelector:@selector(networkAvailable) withObject: nil];
    }
    
    if (result && [result boolValue]) {
        //WARNING: DEBUG CODE (Change to NO for debugging off-line code).
        return YES;
    }
    
    return NO;
}

/*!
 *  Returns YES if logged-in.
 *
 *  @return YES if logged-in.
 */
+ (BOOL)isLoggedIn {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    
    Account *account = ARLNetworking.CurrentAccount;
    
    if (account && [appDelegate respondsToSelector:@selector(isLoggedIn)]) {
        return [appDelegate performSelector:@selector(isLoggedIn) withObject: nil]== [NSNumber numberWithBool:YES];
    }
    
    return NO;
}

/*!
 *  Returns the current account (or nil).
 *
 *  @return the current account.
 */
+ (Account *) CurrentAccount {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if ([appDelegate respondsToSelector:@selector(CurrentAccount)]) {
        return [appDelegate performSelector:@selector(CurrentAccount) withObject:nil];
    }
    
    return nil;
}

#pragma mark Methods

/*!
 *  GET data with a URL and process it using a delegate
 *
 *  See http://hayageek.com/ios-nsurlsession-example/
 *
 *  @param delegate The delegate to process data.
 *  @param service  The rest service part of the url.
 */
+(void) sendHTTPGetWithDelegate:(id <NSURLSessionDelegate>)delegate
                    withService:(NSString *)service
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject
                                                                 delegate: delegate
                                                            delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:serviceUrlFmt, serverUrl, service]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    // Setup Authorization Token (should not be neccesary for search, but it is!)
    // WRONG CODE, authtoken is hardcoded!
    // [urlRequest addValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", authtoken] forHTTPHeaderField:@"Authorization"];
    
    NSString * authorizationString = [NSString stringWithFormat:@"GoogleLogin auth=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"auth"]];
    [urlRequest setValue:authorizationString forHTTPHeaderField:@"Authorization"];
    
    // Setup Headers
    [urlRequest addValue:applicationjson
      forHTTPHeaderField:acceptHeader];
    [urlRequest addValue:applicationjson
      forHTTPHeaderField:contenttypeHeader];
    
    // Setup Method
    [urlRequest setHTTPMethod:@"GET"];
    
    // Setup Parameters (plain text or parameters like =@"name=Ravi&loc=India&age=31&submit=true") + Content encoding
    // Android: Content-Type: text/plain; charset=ISO-8859-1
    //[urlRequest setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest];
    
    dataTask.taskDescription = dataTask.taskDescription = [self generateGetDescription:service];
    
    [dataTask resume];
}

/*!
 *  Generate an ID for the Cache Entry.
 *
 *  @param service The Rest Service Url part.
 *
 *  @return The Cache ID.
 */
+(NSString *)generateGetDescription:(NSString *)service {
    
#pragma warn Replace by MD5 of complete URL?
    
    return service;
}

/*!
 *  POST data with a URL and process it using a delegate
 *
 *  See http://hayageek.com/ios-nsurlsession-example/
 *
 *  @param delegate The delegate to process data.
 *  @param service  The rest service part of the url.
 *  @param body     The additional data to OST in the request body.
 */
+(void) sendHTTPPostWithDelegate:(id <NSURLSessionDelegate>)delegate
                     withService:(NSString *)service
                        withBody:(NSString *)body
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:delegate
                                                            delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:serviceUrlFmt, serverUrl, service]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
  
    // Setup Authorization Token (should not be neccesary for search, but it is!)
    // WRONG CODE, authtoken is hardcoded!
    // [urlRequest addValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", authtoken] forHTTPHeaderField:@"Authorization"];
    NSString * authorizationString = [NSString stringWithFormat:@"GoogleLogin auth=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"auth"]];
    [urlRequest setValue:authorizationString forHTTPHeaderField:@"Authorization"];
    
    // Setup Headers
    [urlRequest addValue:applicationjson
      forHTTPHeaderField:acceptHeader];
    [urlRequest addValue:applicationjson
      forHTTPHeaderField:contenttypeHeader];

    // Setup Method
    [urlRequest setHTTPMethod:@"POST"];

    // Setup Parameters (plain text or parameters like =@"name=Ravi&loc=India&age=31&submit=true") + Content encoding
    // Android: Content-Type: text/plain; charset=ISO-8859-1
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest];
    
    dataTask.taskDescription = [self generatePostDescription:service withBody:body];
    
    [dataTask resume];
}

/*!
 *  Generate an ID for the Cache Entry.
 *
 *  @param service The Rest Service Url part.
 *  @param body    service The Rest POST request Body.
 *
 *  @return The Cache ID.
 */
+(NSString *)generatePostDescription:(NSString *)service
                            withBody:(NSString *)body {
    
#pragma warn Replace by MD5 of complete URL+BODY?
    
    return [[service stringByAppendingString:@"|"] stringByAppendingString:body];
}

/*!
 *  Get a URL's content synchronously
 *
 *  @param service The Rest Service Url part.
 *
 *  @return the URL's content as NSData.
 */
+(NSData *)sendHTTPGet:(NSString *) service {
    NSURLResponse *response = nil;
    
// NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
// NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject];
    
    NSURL *url = [NSURL URLWithString:[ARLNetworking MakeRestUrl:service]];

    DLog(@"URL: %@", url);
    
    NSError *error = nil;
   
    NSData *data = [NSURLSession sendSynchronousDataTaskWithURL:url
                                              returningResponse:&response
                                                          error:&error];
    
    ELog(error);
    
    return data;
}

/*!
 *  Get a URL's content synchronously
 *
 *  @param service The Rest Service Url part.
 *
 *  @return the URL's content as NSData.
 */
+(NSData *)sendHTTPGetWithAuthorization:(NSString *) service {
    NSURLResponse *response = nil;
    
    //    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    //    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject];
    
    NSURL *url = [NSURL URLWithString:[ARLNetworking MakeRestUrl:service]];
    
    // DLog(@"URL: %@", url);

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    // Setup Authorization Token (should not be neccesary for search, but it is!)
    NSString *authorizationString = [NSString stringWithFormat:@"GoogleLogin auth=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"auth"]];
    [urlRequest setValue:authorizationString
      forHTTPHeaderField:@"Authorization"];
    
    NSError *error = nil;
    
    NSData *data = [NSURLSession sendSynchronousDataTaskWithRequest:urlRequest
                                                  returningResponse:&response
                                                              error:&error];
    
    if (error==nil) {
        // [ARLUtils LogJsonData:data url:[url absoluteString]];
    }
    
    ELog(error);
    
    return data;
}

/*!
 *  Get a URL's content synchronously
 *
 *  @param service The Rest Service Url part.
 *
 *  @return the URL's content as NSData.
 */
+(NSData *)sendHTTPPostWithAuthorization:(NSString *)service
                                    json:(NSDictionary *)json {
    NSError *error = nil;
    NSData *data =  [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
    ELog(error);
    
    return [ARLNetworking sendHTTPPostWithAuthorization:service
                                                   data:data
                                             withAccept:@"application/json"
                                        withContentType:@"application/json"];
}

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
                         withContentType:(NSString *)withContentType {
    NSURLResponse *response = nil;
    
    //    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    //    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject];
    
    NSURL *url = [NSURL URLWithString:[ARLNetworking MakeRestUrl:service]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    // Setup Authorization Token (should not be neccesary for search, but it is!)
    NSString *authorizationString = [NSString stringWithFormat:@"GoogleLogin auth=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"auth"]];
    [urlRequest setValue:authorizationString
      forHTTPHeaderField:@"Authorization"];
    
    // Setup Other Headers
    [urlRequest addValue:withAccept
      forHTTPHeaderField:acceptHeader];
    [urlRequest addValue:withContentType
      forHTTPHeaderField:contenttypeHeader];
    
    // Add Body.
    [urlRequest setHTTPBody:body];
    
    // Setup Method
    [urlRequest setHTTPMethod:@"POST"];
    
    NSError *error = nil;
    
    NSData *data = [NSURLSession sendSynchronousDataTaskWithRequest:urlRequest
                                                  returningResponse:&response
                                                              error:&error];
    
    if (error==nil) {
        // [ARLUtils LogJsonData:data url:[url absoluteString]];
        
        //{
        //    action = read;
        //    deleted = 0;
        //    generalItemId = 6180497885495296;
        //    generalItemType = "org.celstec.arlearn2.beans.generalItem.AudioObject";
        //    identifier = 5861948851748864;
        //    runId = 4977978815545344;
        //    time = 1421237414518;
        //    timestamp = 1421237414637;
        //    type = "org.celstec.arlearn2.beans.run.Action";
        //    userEmail = "2:103021572104496509774";
        //}
    }
    
    ELog(error);
    
    return data;
}

/**
 *  Get and process OAUTH Info from ARLearn server.
 */
+(void) setupOauthInfo {
    NSData *data = [ARLNetworking sendHTTPGet:@"oauth/getOauthInfo"];
    
    NSError *error = nil;
    
    NSDictionary* network = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                                     error:&error] : nil;
    
    ELog(error);
    
    for (NSDictionary* dict in [network objectForKey:@"oauthInfoList"]) {
        switch ([(NSNumber*)[dict objectForKey:@"providerId"] intValue]) {
            case FACEBOOK:
                _facebookLoginString = [NSString stringWithFormat:@"https://graph.facebook.com/oauth/authorize?client_id=%@&display=page&redirect_uri=%@&scope=publish_stream,email", [dict objectForKey:@"clientId"], [dict objectForKey:@"redirectUri"]];
                break;
                
            case GOOGLE:
                _googleLoginString = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?redirect_uri=%@&response_type=code&client_id=%@&approval_prompt=force&scope=profile+email", [dict objectForKey:@"redirectUri"], [dict objectForKey:@"clientId"]];
                break;
                
            case LINKEDIN:
                _linkedInLoginString = [NSString stringWithFormat:@"https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=%@&scope=r_fullprofile+r_emailaddress+r_network&state=BdhOU9fFb6JcK5BmoDeOZbaY58&redirect_uri=%@", [dict objectForKey:@"clientId"], [dict objectForKey:@"redirectUri"]];
                break;
                
            case TWITTER:
                _twitterLoginString = [NSString stringWithFormat:@"%@?twitter=init", [dict objectForKey:@"redirectUri"]];
                break;
                
        }
    }
    
    //    Log(@"%@", self.facebookLoginString);
    //    Log(@"%@", self.googleLoginString);
    //    Log(@"%@", self.linkedInLoginString);
    //    Log(@"%@", self.twitterLoginString);
}

#pragma mark AbortMessage

+ (void)ShowAbortMessage: (NSString *) title message:(NSString *) message {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    
    // See http://stackoverflow.com/questions/3753154/make-uialertview-blocking
    //NSRunLoop *run_loop = [NSRunLoop currentRunLoop];
    
    if ([appDelegate respondsToSelector:@selector(ShowAbortMessage:message:)]) {
        [appDelegate performSelector:@selector(ShowAbortMessage:message:) withObject:title withObject:message];
    }
    
    // Lock the Condition
    [ARLAppDelegate.theAbortLock lock];
    
    //WARNING: Only do this if not the MainThread.
    if (![NSThread isMainThread]) {
        
        // We wait until OK on the UIAlertView is tapped and provides a Signal to continue.
        [ARLAppDelegate.theAbortLock wait];
        
        // Unlock the Condition also when we exit.
        [ARLAppDelegate.theAbortLock unlock];
        
        [NSThread exit];
    } else {
        // Unlock the Condition when we're not running on the mainthread.
        [ARLAppDelegate.theAbortLock unlock];
    }
}

+ (void)ShowAbortMessage: (NSError *) error func:(NSString *)func {
    
    NSString *msg = [NSString stringWithFormat:@"%@\n\nUnresolved error code %d,\n\n%@", func, [error code], [error localizedDescription]];
    
    [ARLNetworking ShowAbortMessage:NSLocalizedString(@"Error", @"Error")
                         message:msg];
}

//+(NSString *) requestAuthToken: (NSString *) username password: (NSString *) password {
//    NSData *postData = [self stringToData:[NSString stringWithFormat:@"%@\n%@", username, password]];
//    
//    return [[self executeARLearnPostWithAuthorization:@"login" postData:postData withContentType:textplain] objectForKey:@"auth"];
//}

+ (NSData *) getUserInfo:(NSNumber *)runId
                        userId:(NSString *)userId
                    providerId:(NSString *)providerId {
    return [self sendHTTPGetWithAuthorization:[NSString stringWithFormat:@"users/runId/%@/account/%@:%@", runId, providerId, userId]];
}

@end
