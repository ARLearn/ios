//
//  ARLNetworking.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/16/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLNetworking.h"

@implementation ARLNetworking

/*!
 *  See http://hayageek.com/ios-nsurlsession-example/
 */
+(void) sendHTTPGetWithDelegate:(id <NSURLSessionDelegate>)delegate withService:(NSString *)service
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject
                                                                 delegate: delegate
                                                            delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://streetlearn.appspot.com/rest/%@", service]];
    
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    // Setup Authorization Token (should not be neccesary for search, but it is!)
    [urlRequest addValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", authtoken] forHTTPHeaderField:@"Authorization"];
    
    // Setup Headers
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
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

+(void) sendHTTPPostWithDelegate:(id <NSURLSessionDelegate>)delegate withService:(NSString *)service withBody:(NSString *)body
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:delegate
                                                            delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://streetlearn.appspot.com/rest/%@", service]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
  
    // Setup Authorization Token (should not be neccesary for search, but it is!)
    [urlRequest addValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", authtoken] forHTTPHeaderField:@"Authorization"];
    
    // Setup Headers
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

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
+(NSString *)generatePostDescription:(NSString *)service withBody:(NSString *)body {
#pragma warn Replace by MD5 of complete URL+BODY?
    return [[service stringByAppendingString:@"|"] stringByAppendingString:body];
}

@end
