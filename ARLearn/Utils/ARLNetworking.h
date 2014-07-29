//
//  ARLNetworking.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/16/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

@interface ARLNetworking : NSObject

+(void) sendHTTPGetWithDelegate:(id <NSURLSessionDelegate>)delegate withService:(NSString *)service;
+(NSString *)generateGetDescription:(NSString *)service;

+(void) sendHTTPPostWithDelegate:(id <NSURLSessionDelegate>)delegate withService:(NSString *)service withBody:(NSString *)body;
+(NSString *)generatePostDescription:(NSString *)service withBody:(NSString *)body;

@end
