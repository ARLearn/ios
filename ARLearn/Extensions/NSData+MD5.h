//
//  NSData+MD5.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 08/12/14.
//
//  See http://iosdevelopertips.com/core-services/create-md5-hash-from-nsstring-nsdata-or-file.html
//

#import <Foundation/Foundation.h>

@interface NSData (MD5)

- (NSString *)MD5;
+ (NSString *)MD5:(NSString *)path;

@end
