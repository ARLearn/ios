//
//  ARLUtils.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/9/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLUtils.h"

@interface ARLUtils ()

/*!
 *  Static Property containing the gitHash.
 */
@property (strong, readonly) NSString *gitHash;

/*!
 *  Static Property containing the appVersion.
 */
@property (strong, readonly) NSString *appVersion;

/*!
 *  Static Property containing the appBuild number (ie. commit count).
 */
@property (strong, readonly) NSString *appBuild;

@end

@implementation ARLUtils

static NSCondition *_theAbortLock;

/*!
 *  Getter for gitHash property.
 *
 *  @return the gitHash
 */
+(NSString *) gitHash {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleBuildVersion"];
}

/*!
 *  Getter for appVersion property.
 *
 *  @return the appVersion
 */
+(NSString *) appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

/*!
 *  Getter for appBuild property.
 *
 *  @return the appBuild
 */
+(NSString *)appBuild {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

/*!
 *  Log GIT Version Info.
 */
+ (void) LogGitInfo {
    Log(@"Version String:  %@", ARLUtils.appVersion);
    Log(@"Build Number:    %@", ARLUtils.appBuild);
    Log(@"Git Commit Hash: %@", ARLUtils.gitHash);
}

/*!
 *  Register the Default Values for Application Preferences.
 */
+ (void) RegisterDefaultsForPrefences {
    // Register default preferences.
    NSDictionary *appDefault = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:NO],       ENABLE_LOGGING,
                                
                                ARLUtils.gitHash,                   GIT_HASH,
                                ARLUtils.appVersion,                APP_VERSION,
                                
                                nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefault];
    
    // Synchronize preferences.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*!
 *  Creates a NSManagedObject for a certain Entity and fills it with date from a NSDictionary.
 *
 *  See http://stackoverflow.com/questions/2563984/json-to-persistent-data-store-coredata-etc
 *
 *  @param dict   The Dictionary containing the values
 *  @param entity The Entity name to create.
 *
 *  @return The NSManagedObject that has been created and inserted into Core Data.
 */
+ (NSManagedObject *) ManagedObjectFromDictionary:(NSDictionary *)dict
                                       entityName:(NSString *)entity {
    
    return [ARLUtils ManagedObjectFromDictionary:dict
                                      entityName:entity
                                      nameFixups:[NSDictionary dictionaryWithObjectsAndKeys:nil]];
}

/*!
 *  Creates a NSManagedObject for a certain Entity and fills it with date from a NSDictionary.
 *
 *  See http://stackoverflow.com/questions/2563984/json-to-persistent-data-store-coredata-etc
 *
 *  @param dict   The Dictionary containing the values
 *  @param entity The Entity name to create.
 *  @param fixups List of mismatches between dict and NSManagerObject fields. Keys are CoreData names, Values are dict key names.
 *
 *  @return The NSManagedObject that has been created and inserted into Core Data.
 */
+ (NSManagedObject *) ManagedObjectFromDictionary:(NSDictionary *)dict
                                       entityName:(NSString *)entity
                                       nameFixups:(NSDictionary *)fixups {
    
    // 1) Make sure we can modify object inside the MagicalRecord block.
    __block NSManagedObject *object;
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        
        // 2) Create a NSManagedObject by Name.
        object = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:localContext];
        
        // 3) Get its Attributes
        NSDictionary *attributes = [[NSEntityDescription
                                     entityForName:entity
                                     inManagedObjectContext:localContext] attributesByName];
        
        //TODO: Add Key <-> Property Name Lookup.
        
        // 4) Enumerate over Attributes
        for (NSString *attr in attributes) {
            if ([fixups valueForKey:attr]) {
                [object setValue:[dict valueForKey:[fixups valueForKey:attr]] forKey:attr];
            }else {
                [object setValue:[dict valueForKey:attr] forKey:attr];
            }
        }
    }];
    
    // 5) Return the result.
    return object;
}

/*!
 *  Creates a NSDictionary containing data from a certain NSManagedObject.
 *
 *  @param dict   The NSManagedObject to convert
 *  @param entity The Entity name to create.
 *
 *  @return The NSDictionary containing the data.
 */
+ (NSDictionary *) DictionaryFromManagedObject:(NSManagedObject *)object {
    return [ARLUtils DictionaryFromManagedObject:object
                                      nameFixups:[NSDictionary dictionaryWithObjectsAndKeys:nil]];
}

/*!
 *  Creates a NSDictionary containing data from a certain NSManagedObject.
 *
 *  @param object The NSManagedObject to convert
 *  @param fixups List of mismatches between dict and NSManagerObject fields.
 *
 *  @return The NSDictionary containing the object data
 */
+ (NSDictionary *) DictionaryFromManagedObject:(NSManagedObject *)object
                                    nameFixups:(NSDictionary *)fixups {
    // 1) Make sure we can modify object inside the MagicalRecord block.
    __block NSMutableDictionary *json = [[NSMutableDictionary alloc]  init];
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
    
        NSString *entity = [object entity].name;
        
         // 3) Get its Attributes
        NSDictionary *attributes = [[NSEntityDescription entityForName:entity
                                                inManagedObjectContext:localContext] attributesByName];

        ////TODO: Add Key <-> Property Name Lookup.
        
        // 4) Enumerate over Attributes
        for (NSString *attr in attributes) {
            if ([object valueForKey:attr]) {
                if ([fixups valueForKey:attr]) {
                    [json setObject:[object valueForKey:attr] forKey:[fixups valueForKey:attr]];
                }else {
                    [json setObject:[object valueForKey:attr] forKey:attr];
                }
            }
        }
    }];
    
    // 5) Return the result.
    return json;
}

/*!
 *  A NSCondition Lock neccsary to wait for the Abort Dialog to be dismssed.
 *
 *  @return The NSCondition Lock
 */
+ (NSCondition *) theAbortLock {
    if(!_theAbortLock){
        _theAbortLock = [[NSCondition alloc] init];
        //[_theAbortLock setName:@"Show Abort Condition"];
    }
    return _theAbortLock;
}

/*!
 *  Handles the popup of an AlertView.
 *
 *  Note: This method should not be called directly, use the static helper methods.
 *
 *  @param title   The Title.
 *  @param message The Message.
 */
+ (void) _ShowAbortMessage:(NSString *)title
               withMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                          otherButtonTitles:nil, nil];
    
    // UIAlertView should run on the main thread!
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

/*!
 *  Shows an Abort Messages and Waits on the Mainthread until dismissed and then terminates the application.
 *
 *  @param title   The Title
 *  @param message The Message
 */
+ (void) ShowAbortMessage:(NSString *)title
              withMessage:(NSString *)message {

    // 1) Switch to
    // [ARLUtils.InternalShowAbortMessage:title withMessage:message];
    
    if ([ARLUtils respondsToSelector:@selector(_ShowAbortMessage:withMessage:)]) {
        [ARLUtils performSelector:@selector(_ShowAbortMessage:withMessage:) withObject:title withObject:message];
    }
    
    // 2)  Lock the Condition
    [ARLUtils.theAbortLock lock];
    
    // 2) Only do this if not the MainThread!
    if (![NSThread isMainThread]) {
        
        // 3) We wait until OK on the UIAlertView is tapped and provides a Signal to continue.
        [ARLUtils.theAbortLock wait];
        
        // 4) Unlock the Condition also when we exit.
        [ARLUtils.theAbortLock unlock];
        
        [NSThread exit];
    } else {
        // 5) Unlock the Condition when we're not running on the mainthread.
        [ARLUtils.theAbortLock unlock];
    }
}

/*!
 *  Shows an Abort Messages and Waits on the Mainthread until dismissed and then terminates the application.
 *
 *  @param error The Error to Display
 *  @param func  The Name of the Method requesting this Dialog.
 */
+ (void) ShowAbortMessage: (NSError *)error
               fromMethod:(NSString *)func {
    
    NSString *msg = [NSString stringWithFormat:@"%@\n\nUnresolved error code %d,\n\n%@", func, [error code], [error localizedDescription]];
    
    [ARLUtils ShowAbortMessage:NSLocalizedString(@"Error", @"Error")
                         withMessage:msg];
}

/*!
 *  Handle the Dismiss Button by unlocking theAbortLock.
 *
 *  @param alertView   The AlertView Dismissed
 *  @param buttonIndex The Button Index Clicked to Dismiss.
 */
+ (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [ARLUtils.theAbortLock signal];
}

/*!
 *  Returns the Applications Document Directory.
 *
 *  @return Returns a path into the Applications Document Directory.
 */
+ (NSURL *) applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            Log(@"You successfully saved your context.");
        } else if (error) {
            Log(@"Error saving context: %@", error.description);
        }
    }];
}

@end
