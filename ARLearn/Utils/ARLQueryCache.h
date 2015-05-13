//
//  ARLQueryCache.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/28/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARLQueryCache : NSObject

@property (strong, readonly) NSString *query;
@property (strong, readonly) NSDate *stamp;
@property (strong, readonly) NSData *response;

- (BOOL)isHit:(NSString *)aquery;

- (NSData *)getResponse:(NSString *)aquery;

+ (void) addQuery:(NSString *)aquery withResponse:(NSData *)aresponse;

+(void)clearCache;

@end
