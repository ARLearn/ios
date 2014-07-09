//
//  TestAccount+Fetched.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/27/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "TestAccount+Lazy.h"

@implementation TestAccount (Lazy)

UIImage * cachedPicture;

/*!
 *  Lazy Loaded the Account Image.
 *
 *  @return
 */
- (UIImage *) lazyPicture {
    // One could also use a Table with Images to Cache....
    
    if (!cachedPicture) {
        NSURL  *url = [NSURL URLWithString:self.picture];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if (urlData ){
            cachedPicture = [UIImage imageWithData:urlData];
        }
    }
    
    return cachedPicture;
}

/*!
 *  Try to retrieve a record from CoreData.
 *
 *  @param giDict  The Dictionary
 *  @param context The CoreData Context
 *
 *  @return The Account
 */
+ (TestAccount *) retrieveFromDb: (NSDictionary *) giDict withManagedContext: (NSManagedObjectContext *) context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TestAccount"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"(localId = %@) AND (accountType = %d)", [giDict objectForKey:@"localId"], [[giDict objectForKey:@"accountType"] intValue]];
    NSArray *accountsFromDb = [context executeFetchRequest:request error:nil];
    if (!accountsFromDb || ([accountsFromDb count] != 1)) {
        return nil;
    } else {
        return [accountsFromDb lastObject];
    }
}

/*!
 *  Create or Update a Record from CoreData with a JSON Derived Dictionary.
 *
 *  @param acDict  Should at least contain localId, accountType, email, name, givenName, familyName, accountLevel and picture.
 *  @param context The NSManagedObjectContext.
 *
 *  @return The Account.
 */
+ (TestAccount *) accountWithDictionary: (NSDictionary *) acDict inManagedObjectContext: (NSManagedObjectContext *) context {
    TestAccount *account = [self retrieveFromDb:acDict withManagedContext:context];
    
    if (!account) {
        account = [NSEntityDescription insertNewObjectForEntityForName:@"TestAccount" inManagedObjectContext:context];
    }
    
    account.localId = [acDict objectForKey:@"localId"];
    account.accountType = [acDict objectForKey:@"accountType"];
    
    account.email = [acDict objectForKey:@"email"];
    account.name= [acDict objectForKey:@"name"];
    account.givenName = [acDict objectForKey:@"givenName"];
    account.familyName = [acDict objectForKey:@"familyName"];
    account.accountLevel= [acDict objectForKey:@"accountLevel"];
    account.picture = [acDict objectForKey:@"picture"];

    NSError *error = nil;
    [context save:&error];
    ELog(error);
    
    return account;
}


@end
