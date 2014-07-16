//
//  TestAccount+Fetched.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/27/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "TestAccount.h"

@interface TestAccount (Lazy)

@property (nonatomic, readonly) UIImage *lazyPicture;

+ (instancetype) retrieveFromDb: (NSDictionary *) giDict withManagedContext: (NSManagedObjectContext *) context;

+ (instancetype) accountWithDictionary: (NSDictionary *) acDict inManagedObjectContext: (NSManagedObjectContext *) context;

@end
