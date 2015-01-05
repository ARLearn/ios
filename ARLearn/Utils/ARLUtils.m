//
//  ARLUtils.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/9/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLUtils.h"

#import "NSData+MD5.h"

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

#pragma mark - Properties

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

#pragma mark - Methods

/*!
 *  Log GIT Version Info.
 */
+ (void) LogGitInfo {
    Log(@"Version String:  %@", ARLUtils.appVersion);
    Log(@"Build Number:    %@", ARLUtils.appBuild);
    Log(@"Git Commit Hash: %@", ARLUtils.gitHash);
}

/*!
 *  Log Device Version Info.
 */
+ (void) LogDeviceInfo {
    Log(@"deviceUniqueIdentifier: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceUniqueIdentifier"]);
    Log(@"deviceToken:            %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]);
    Log(@"bundleIdentifier:       %@", [[NSBundle mainBundle] bundleIdentifier]);
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
                                      nameFixups:[NSDictionary dictionaryWithObjectsAndKeys:nil]
                                      dataFixups:[NSDictionary dictionaryWithObjectsAndKeys:nil]];
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
                                       nameFixups:(NSDictionary *)fixups
{
    
    return [ARLUtils ManagedObjectFromDictionary:dict
                                      entityName:entity
                                      nameFixups:fixups
                                      dataFixups:[NSDictionary dictionaryWithObjectsAndKeys:nil]];
}

/*!
 *  Creates a NSManagedObject for a certain Entity and fills it with date from a NSDictionary.
 *
 *  See http://stackoverflow.com/questions/2563984/json-to-persistent-data-store-coredata-etc
 *
 *  @param dict   The Dictionary containing the values
 *  @param entity The Entity name to create.
 *  @param fixups List of mismatches between dict and NSManagerObject fields. Keys are CoreData names, Values are dict key names.
 *  @param data   List of mismatches between dict and NSManagerObject fields. Keys are CoreData names, Values are dict key names.
 *
 *  @return The NSManagedObject that has been created and inserted into Core Data.
 */
+ (NSManagedObject *) ManagedObjectFromDictionary:(NSDictionary *)dict
                                       entityName:(NSString *)entity
                                       nameFixups:(NSDictionary *)fixups
                                       dataFixups:(NSDictionary *)data {
    
    // 1) Make sure we can modify object inside the MagicalRecord block.
    __block NSManagedObject *object;

    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        
        // 2) Create a NSManagedObject by Name.
        object = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:localContext];
        
        // 3) Get its Attributes
        NSDictionary *attributes = [[NSEntityDescription
                                     entityForName:entity
                                     inManagedObjectContext:localContext]  attributesByName /*propertiesByName*/];
        
        // propertiesByName also returns relations but they proof hard to do here as contexts are mixed, so do them at the caller.

        // 4) Enumerate over Attributes
        for (NSString *attr in attributes) {
            if ([data valueForKey:attr]) {
                // 4a) Foreign Data (must come first).
                [object setValue:[data valueForKey:attr] forKey:attr];
            } else if ([fixups valueForKey:attr]) {
                // 4b) Name Mapping.
                [object setValue:[dict valueForKey:[fixups valueForKey:attr]] forKey:attr];
            } else {
                // 4c) 1:1 Mapping & Data.
                [object setValue:[dict valueForKey:attr] forKey:attr];
            }
        }
    }];

    // 5) Return the result (in the correct context, or we cannot modify/save it anymore !!! ). See http://stackoverflow.com/questions/24755734/nsmanagedobject-wont-be-updated-after-saving-with-magical-record
    return [object MR_inContext:[NSManagedObjectContext MR_defaultContext]];
}

/*!
 *  Updates a NSManagedObject with date from a NSDictionary.
 *
 *  See http://stackoverflow.com/questions/2563984/json-to-persistent-data-store-coredata-etc
 *
 *  @param dict          The Dictionary containing the values
 *  @param managedobject The NSManagedObject to updated.
 *  @param fixups        List of mismatches between dict and NSManagerObject fields. Keys are CoreData names, Values are dict key names.
 *  @param data          List of fields and their data to populate with non dict data.
 *
 *  @return The NSManagedObject that has been updated in Core Data.
 */
+ (NSManagedObject *) UpdateManagedObjectFromDictionary:(NSDictionary *)dict
                                          managedobject:(NSManagedObject *)managedobject
                                             nameFixups:(NSDictionary *)fixups
                                             dataFixups:(NSDictionary *)data {
    
    
    //    // 1) Make sure we can modify object inside the MagicalRecord block.
    __block NSManagedObject *object;
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        
        // 2) Create a NSManagedObject by Name.
        object = [managedobject MR_inContext:localContext];
        
        // 3) Get its Attributes
        NSDictionary *attributes = [[NSEntityDescription
                                     entityForName:[[object entity] name]
                                     inManagedObjectContext:localContext] attributesByName /*propertiesByName*/];

        // propertiesByName also returns relations but they proof hard to do here as contexts are mixed, so do them at the caller.
        
        //TODO: Add Key <-> Property Name Lookup.
        
        // 4) Enumerate over Attributes
        for (NSString *attr in attributes) {
            if ([data valueForKey:attr]) {
                // 4a) Foreign Data (must come first).
                [object setValue:[data valueForKey:attr] forKey:attr];
            } else if ([fixups valueForKey:attr]) {
                // 4b) Name Mapping.
                [object setValue:[dict valueForKey:[fixups valueForKey:attr]] forKey:attr];
            } else {
                // 4c) 1:1 Mapping & Data.
                [object setValue:[dict valueForKey:attr] forKey:attr];
            }
        }
    }];
    
    // 5) Return the result (in the correct context, or we cannot modify/save it anymore !!! ). See http://stackoverflow.com/questions/24755734/nsmanagedobject-wont-be-updated-after-saving-with-magical-record
    return [object MR_inContext:[NSManagedObjectContext MR_defaultContext]];
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
                } else {
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
    @synchronized(_theAbortLock)
    {
        if(!_theAbortLock){
            _theAbortLock = [[NSCondition alloc] init];
            //[_theAbortLock setName:@"Show Abort Condition"];
        }
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

/*!
 *  Pretty Print json data to the log.
 *
 *  @param jsonData json as NSData
 *  @param url      the json url used.
 */
+(void)LogJsonData: (NSData *) jsonData
               url: (NSString *) url {
    //http://stackoverflow.com/questions/12603047/how-to-convert-nsdata-to-nsdictionary
    //http://stackoverflow.com/questions/7097842/xcode-how-to-nslog-a-json
    
    if (jsonData) {
        NSError *error = nil;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:jsonData
                              options:kNilOptions
                              error:&error];
        Log(@"[JSON]");
        if (url) {
            Log(@"URL: %@", url);
        }
        if (error==nil && json!=nil) {
            Log(@"JSON:\r%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        } else {
            NSString *errorString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            Log(@"ERROR: %@", errorString);
        }
    }
}

/*!
 *  Pretty Print json data to the log.
 *
 *  @param jsonDictionary json as NSDictionary
 *  @param url            the json url used.
 */
+(void)LogJsonDictionary: (NSDictionary *) jsonDictionary
                     url: (NSString *) url {
    //http://stackoverflow.com/questions/12603047/how-to-convert-nsdata-to-nsdictionary
    //http://stackoverflow.com/questions/7097842/xcode-how-to-nslog-a-json
    
    if (jsonDictionary) {
        Log(@"[JSON]");
        if (url) {
            Log(@"URL: %@", url);
        }
        // Log(@"JSON:\r%@", jsonDictionary);
        
        NSError *error = nil;
        NSData* jsonData = [NSJSONSerialization
                            dataWithJSONObject:jsonDictionary
                            options:kNilOptions
                            error:&error];
        
        if (error==nil) {
            Log(@"JSON:\r%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        } else {
            Log(@"ERROR:\r%@", jsonDictionary);
        }
    }
}

/*!
 *
 *  Download a GameFile.
 *
 *  See http://stackoverflow.com/questions/5323427/how-do-i-download-and-save-a-file-locally-on-ios-using-objective-c
 *  See http://stackoverflow.com/questions/1567134/how-can-i-get-a-writable-path-on-the-iphone
 *  See http://stackoverflow.com/questions/5903157/ios-parse-a-url-into-segments
 *
 *
 *  http://streetlearn.appspot.com/game/<gameid>/<gamefilepath>
 *
 *  Example:
 *
 *  http://streetlearn.appspot.com/game/13876002/gameSplashScreen
 *
 *  @param gameId   The GameId
 *  @param gameFile The GameFile description as NSDictionary.
 *
 *  @return The Local Path to the File.
 */
+(NSString *) DownloadResource:(NSNumber *)gameId
                      gameFile:(NSDictionary *)gameFile {
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Note: NSCachesDirectory needs to be re-created when accessed (to be safe).
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], gameId];
    
    {
        BOOL isDir = NO;
        NSError *error;
        if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
            [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
            
            ELog(error);
        }
    }
    
    // NSString *fileName = [[url pathComponents] lastObject];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", cachePath, [gameFile objectForKey:@"id"]];
    NSString *path = [gameFile objectForKey:@"path"];
    
    if ([[NSFileManager defaultManager] isReadableFileAtPath:filePath]) {
        
        NSError *error;
        
        unsigned long long remoteSize = [[gameFile objectForKey:@"size"] longLongValue];
        unsigned long long localSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error] fileSize];
        
        ELog(error);

        if (remoteSize == localSize) {
            
            NSString *localMD5 = [NSData MD5:filePath];
            NSString *remoteMD5 = [gameFile objectForKey:@"md5Hash"];
            
            if ([remoteMD5 isEqualToString:localMD5]) {
                DLog(@"MD5Hash Match, Skipping Download of GameFile: %@", path);
                
                return filePath;
            } else {
                DLog(@"MD5Hash Mismatch, Re-downloading GameFile: %@", path);
            }
        } else {
            DLog(@"FileSize Mismatch, Re-downloading GameFile: %@", path);
        }
    } else {
        DLog(@"Downloading GameFile: %@", path);
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://streetlearn.appspot.com/game/%@%@", gameId, path]];
    
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    if (urlData)
    {
        [urlData writeToFile:filePath atomically:YES];
    }
    
    return filePath;
}

/*!
 *  Convert bytes to a readable string.
 *
 *  See http://stackoverflow.com/questions/7846495/how-to-get-file-size-properly-and-convert-it-to-mb-gb-in-cocoa
 *
 *  @param value <#value description#>
 *
 *  @return <#return value description#>
 */
+ (NSString *)bytestoString:(NSNumber *) value
{
    return [NSByteCountFormatter stringFromByteCount:[value longLongValue] countStyle:NSByteCountFormatterCountStyleFile];
    
    //    double convertedValue = [value doubleValue];
    //    int multiplyFactor = 0;
    //
    //    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",nil];
    //
    //    while (convertedValue > 1024) {
    //        convertedValue /= 1024;
    //        multiplyFactor++;
    //    }
    //
    //    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

/*!
 *  Transform the image in grayscale, while keeping its transparency.
 *
 *  See http://stackoverflow.com/questions/1298867/convert-image-to-grayscale
 *
 *  @param inputImage The Image to be grayed.
 *
 *  @return The GrayScale Image.
 */
+ (UIImage *)grayishImage:(UIImage *)inputImage {
    UIGraphicsBeginImageContextWithOptions(inputImage.size, NO, inputImage.scale);
    
    @autoreleasepool {
        CGRect imageRect = CGRectMake(0.0f, 0.0f, inputImage.size.width, inputImage.size.height);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        // Draw a white background
        CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 1.0f);
        CGContextFillRect(ctx, imageRect);
        
        // Draw the luminosity on top of the white background to get grayscale
        [inputImage drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0f];
        
        // Apply the source image's alpha
        [inputImage drawInRect:imageRect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
        
    }
    
    UIImage* grayscaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return grayscaleImage;
}

@end
