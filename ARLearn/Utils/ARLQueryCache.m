//
//  ARLQueryCache.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/28/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLQueryCache.h"

//@interface ARLQueryCache ()
//    
//@end
static NSMutableArray *queryCache = nil;

// See http://ajourneywithios.blogspot.nl/2011/03/simplified-use-of-nstimer-class-in-ios.html
static NSTimer *expireTimer;

@implementation ARLQueryCache

@synthesize query;
@synthesize stamp;
@synthesize response;

- (id) init {
    self = [super init];
    
    if (self) {
        if (!queryCache) {
            queryCache = [[NSMutableArray alloc] init];
        }
        
        if (!expireTimer) {
            expireTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                           target:self
                                                         selector:@selector(expire:)
                                                         userInfo:nil
                                                          repeats:YES];
        }
    }
    return self;
}

- (id) initWithQuery:(NSString *)aquery withResponse:(NSData *)aresponse {
    self = [self init];
    
    query = aquery;
    stamp = [NSDate date];
    response = aresponse;
    
    return self;
}

+ (void) addQuery:(NSString *)aquery withResponse:(NSData *)aresponse {
    @synchronized(queryCache) {
        ARLQueryCache *item = [[ARLQueryCache alloc] initWithQuery:aquery withResponse:aresponse];
        
        DLog(@"Adding Query '%@' to Cache at %@", item.query, item.stamp);
        
        [queryCache addObject:item];
    }
}

- (BOOL)isHit:(NSString *)aquery {
    @synchronized(queryCache) {
        for (ARLQueryCache *item in queryCache) {
            if ([item.query isEqualToString:aquery])
                return YES;
        }
    }
    return NO;
}

- (NSData *)getResponse:(NSString *)aquery {
    @synchronized(queryCache) {
        for (ARLQueryCache *item in queryCache) {
            if ([item.query isEqualToString:aquery]) {
                NSTimeInterval age = [[NSDate date] timeIntervalSinceDate:item.stamp];
                
                DLog(@"Using cached query '%@' (aged %d [s])", aquery, (int)age);
                
                return item.response;
            }
        }
    }
    return nil;
}

-(void)expire:(NSTimer *)aTimer
{
    // DLog(@"Expiring @ %@", [aTimer fireDate]);
    @synchronized(queryCache) {
        @autoreleasepool {
            NSDate *then = [NSDate dateWithTimeIntervalSinceNow:-CACHINGTIME];
            
            NSInteger oldcnt = queryCache.count;
            
            for (int i=queryCache.count-1;i>=0;i--) {
                ARLQueryCache *item = (ARLQueryCache *)[queryCache objectAtIndex:i];
                
                if ([item.stamp compare:then] != NSOrderedDescending) {
                    NSTimeInterval age = [[NSDate date] timeIntervalSinceDate:item.stamp];
                    
                    DLog(@"Deleted Cached Query '%@' (aged %d [s])", item.query, (int)age);
                    
                    [queryCache removeObjectAtIndex:i];
                }
            }
            
            if (oldcnt != queryCache.count) {
                DLog(@"Chached itemcount changed @ %@", [aTimer fireDate]);
                switch (queryCache.count) {
                    case 0:
                        DLog(@"No Queries Cached");
                        break;
                    case 1:
                        DLog(@"%d Query Cached", queryCache.count);
                        break;
                    default:
                        DLog(@"%d Queries Cached", queryCache.count);
                        break;
                }
            }
        }
    }
}

+(void)clearCache {
    @synchronized(queryCache) {
        [queryCache removeAllObjects];
    }
}

@end
