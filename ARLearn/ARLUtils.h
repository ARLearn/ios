//
//  ARLUtils.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/9/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARLUtils : NSObject <UIAlertViewDelegate>

/*!
 *  Log GIT Version Info.
 */
+ (void) LogGitInfo;

/*!
 *  Log Device Version Info.
 */
+ (void) LogDeviceInfo;

/*!
 *  Register the Default Values for Application Preferences.
 */
+ (void) RegisterDefaultsForPrefences;

/*!
 *  Shows an Abort Messages and Waits on the Mainthread until dismissed and then terminates the application.
 *
 *  @param title   The Title
 *  @param message The Message
 */
+ (void) ShowAbortMessage:(NSString *)title
              withMessage:(NSString *)message;

/*!
 *  Shows an Abort Messages and Waits on the Mainthread until dismissed and then terminates the application.
 *
 *  @param error The Error to Display
 *  @param func  The Name of the Method requesting this Dialog.
 */
+ (void) ShowAbortMessage:(NSError *)error
               fromMethod:(NSString *)func;

/*!
 *  Returns the Applications Document Directory.
 *
 *  @return Returns a path into the Applications Document Directory.
 */
+ (NSURL *) applicationDocumentsDirectory;

/*!
 *  Creates a NSManagedObject for a certain Entity and fills it with date from a NSDictionary.
 *
 *  See http://stackoverflow.com/questions/2563984/json-to-persistent-data-store-coredata-etc
 *
 *  @param dict   The Dictionary containing the values
 *  @param entity The Entity name to create.
 *
 *  @return The NSManagedObject that has been created and inserted into Core Data
 */
+ (NSManagedObject *) ManagedObjectFromDictionary:(NSDictionary *)dict
                                       entityName:(NSString *)entity;

/*!
 *  Creates a NSManagedObject for a certain Entity and fills it with date from a NSDictionary.
 *
 *  See http://stackoverflow.com/questions/2563984/json-to-persistent-data-store-coredata-etc
 *
 *  @param dict   The Dictionary containing the values
 *  @param entity The Entity name to create.
 *  @param fixups List of mismatches between dict and NSManagerObject fields.
 *
 *  @return The NSManagedObject that has been created and inserted into Core Data
 */
+ (NSManagedObject *) ManagedObjectFromDictionary:(NSDictionary *)dict
                                       entityName:(NSString *)entity
                                       nameFixups:(NSDictionary *)fixups;

/*!
 *  Creates a NSDictionary containing data from a certain NSManagedObject.
 *
 *  @param dict   The NSManagedObject to convert
 *  @param entity The Entity name to create.
 *
 *  @return The NSDictionary containing the data
 */
+ (NSDictionary *) DictionaryFromManagedObject:(NSManagedObject *)object;

/*!
 *  Creates a NSDictionary containing data from a certain NSManagedObject.
 *
 *  @param object The NSManagedObject to convert
 *  @param fixups List of mismatches between dict and NSManagerObject fields.
 *
 *  @return The NSDictionary containing the object data
 */
+ (NSDictionary *) DictionaryFromManagedObject:(NSManagedObject *)object
                                    nameFixups:(NSDictionary *)fixups;

+(void) LogJsonData: (NSData *)jsonData
                 url: (NSString *)url;

@end
