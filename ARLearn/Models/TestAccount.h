//
//  TestAccount.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/16/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TestAccount : NSManagedObject

@property (nonatomic, retain) NSNumber * accountLevel;
@property (nonatomic, retain) NSNumber * accountType;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * familyName;
@property (nonatomic, retain) NSString * givenName;
@property (nonatomic, retain) NSString * localId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * picture;

@end
