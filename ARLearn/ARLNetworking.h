//
//  ARLNetworking.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/16/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARLNetworking : NSObject

+(void) sendHTTPGetWithDelegate:(id <NSURLSessionDelegate>)delegate;
+(void) sendHTTPPostWithDelegate:(id <NSURLSessionDelegate>)delegate withBody:(NSString *)body;

@end
