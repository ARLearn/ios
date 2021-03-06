//
//  NSData+MD5.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 08/12/14.
//
//  See http://iosdevelopertips.com/core-services/create-md5-hash-from-nsstring-nsdata-or-file.html
//

#import <CommonCrypto/CommonDigest.h>

#import "NSData+MD5.h"

@implementation NSData (MD5)

- (NSString *)MD5
{
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(self.bytes, (CC_LONG)self.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    
    return output;
}

+ (NSString *)MD5:(NSString *)path {
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"TestFile" ofType:@"txt"];
    NSData *nsData = [NSData dataWithContentsOfFile:path];
  
    if (nsData) {
        return [nsData MD5];
    }
    
    return NULL;
}

@end
