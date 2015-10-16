//
//  NSString+NSString_MD5.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 08/12/14.
//
//  See http://iosdevelopertips.com/core-services/create-md5-hash-from-nsstring-nsdata-or-file.html
//

#import <CommonCrypto/CommonDigest.h>

#import "NSString+MD5.h"

@implementation NSString (MD5)

- (NSString *)MD5
{
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    
    return output;
}

@end
