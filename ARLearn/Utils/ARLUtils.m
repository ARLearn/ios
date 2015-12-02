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
                                       entityName:(NSString *)entity
                                   managedContext:(NSManagedObjectContext *)ctx;
{
    
    return [ARLUtils ManagedObjectFromDictionary:dict
                                      entityName:entity
                                      nameFixups:[NSDictionary dictionary]
                                      dataFixups:[NSDictionary dictionary]
                                  managedContext:ctx];
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
                                   managedContext:(NSManagedObjectContext *)ctx;
{
    
    return [ARLUtils ManagedObjectFromDictionary:dict
                                      entityName:entity
                                      nameFixups:fixups
                                      dataFixups:[NSDictionary dictionary]
                                  managedContext:ctx];
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
                                       dataFixups:(NSDictionary *)data
                                   managedContext:(NSManagedObjectContext *)ctx
{
    
    // warning Recoded without MagicalRecord saveWithBlockAndWait:.
    
    // 1) Make sure we can modify object inside the MagicalRecord block.
    //__block NSManagedObject *object;
    
    //[MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
    
    // 2) Create a NSManagedObject by Name.
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entity
                                                            inManagedObjectContext:ctx];
    
    // 3) Get its Attributes
    NSDictionary *attributes = [[NSEntityDescription
                                 entityForName:entity
                                 inManagedObjectContext:ctx]  attributesByName /*propertiesByName*/];
    
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
    
    // new
    //[ctx MR_saveToPersistentStoreAndWait];
    [ctx MR_saveWithOptions:MRSaveParentContexts|MRSaveSynchronously completion:nil];
    
    //}];

    // 5) Return the result (in the correct context, or we cannot modify/save it anymore !!! ). See http://stackoverflow.com/questions/24755734/nsmanagedobject-wont-be-updated-after-saving-with-magical-record
    return [object MR_inContext:ctx];
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
                                             dataFixups:(NSDictionary *)data
                                         managedContext:(NSManagedObjectContext *)ctx
{
    
    // warning Recoded without MagicalRecord saveWithBlockAndWait:.

    //    // 1) Make sure we can modify object inside the MagicalRecord block.
    // __block NSManagedObject *object;
    
    // [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
    
    // 2) Create a NSManagedObject by Name.
    NSManagedObject *object = [managedobject MR_inContext:ctx];
    
    // 3) Get its Attributes
    NSDictionary *attributes = [[NSEntityDescription
                                 entityForName:[[object entity] name]
                                 inManagedObjectContext:ctx] attributesByName /*propertiesByName*/];
    
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
    // }];
    
    // new
    //[ctx MR_saveToPersistentStoreAndWait];
    [ctx MR_saveWithOptions:MRSaveParentContexts|MRSaveSynchronously completion:nil];

    // 5) Return the result (in the correct context, or we cannot modify/save it anymore !!! ). See http://stackoverflow.com/questions/24755734/nsmanagedobject-wont-be-updated-after-saving-with-magical-record
    return [object MR_inContext:ctx];
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
                                      nameFixups:[NSDictionary dictionary]];
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
    
    NSString *msg = [NSString stringWithFormat:@"%@\n\nUnresolved error code %ld,\n\n%@", func, (long)[error code], [error localizedDescription]];
    
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
            DLog(@"You successfully saved your context.");
        } else if (error) {
            DLog(@"Error saving context: %@", error.description);
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
        DLog(@"[JSON]");
        if (url) {
            DLog(@"URL: %@", url);
        }
        if (error==nil && json!=nil) {
            DLog(@"JSON:\r%@", json);
            // DLog(@"JSON:\r%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        } else {
            NSString *errorString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            DLog(@"ERROR: %@", errorString);
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
        DLog(@"[JSON]");
        if (url) {
            DLog(@"URL: %@", url);
        }
        // Log(@"JSON:\r%@", jsonDictionary);
        
        NSError *error = nil;
//        NSData* jsonData = [NSJSONSerialization
//                            dataWithJSONObject:jsonDictionary
//                            options:kNilOptions
//                            error:&error];

        if (error==nil) {
            DLog(@"JSON:\r%@", jsonDictionary);
            // Log(@"JSON:\r%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        } else {
            DLog(@"ERROR:\r%@", jsonDictionary);
        }
    }
}

/*!
 *  Fetch and recreate (if neccesary) the applications temp drectory.
 *
 *  @return <#return value description#>
 */
+(NSString *) GenerateTempDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *cachePath = [paths objectAtIndex:0];
    {
        BOOL isDir = NO;
        NSError *error;
        if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
            [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
            
            ELog(error);
        }
    }
    
    return cachePath;
}

/*!
 *  Generate, and recreate it's containing directory (if neccesary), the resource filename.
 *
 *  @param gameId The GameID
 *  @param path   The Partial url path found in teh GameFiles (starts with 'generalItems/').
 *
 *  @return <#return value description#>
 */
+(NSString *) GenerateResourceFileName:(NSNumber *)gameId path:(NSString *)path {
    // Note: NSCachesDirectory needs to be re-created when accessed (to be safe).
    // Split Path in Path and FileName.
    NSRange last = [path rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *filename = [path substringFromIndex:last.location];
    NSString *localpath = [path substringToIndex:last.location];
    
    // Unique FileName Format is <tmp>/<gameId>/<path>/<filemname>
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@%@", [ARLUtils GenerateTempDirectory], gameId, localpath];
    {
        BOOL isDir = NO;
        NSError *error;
        if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
            [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
            
            ELog(error);
        }
    }
    
    if ([filename isEqualToString:@"/audio"]) {
        filename = [filename stringByAppendingString:@".mp3"];
    }
    if ([filename isEqualToString:@"/video"]) {
        filename = [filename stringByAppendingString:@".mov"];
    }
    NSString *filePath = [NSString stringWithFormat:@"%@%@", cachePath, filename];
    
    Log(@"Resource=%@", filePath);
    
    return filePath;
}

+(BOOL) GameHasCache:(NSNumber *)gameId {
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@", [ARLUtils GenerateTempDirectory], gameId];
    
    BOOL isDir = YES;
    
    return [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir];
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
 
    NSString *gameFilePath = [gameFile objectForKey:@"path"];

    NSString *filePath = [ARLUtils GenerateResourceFileName:gameId path:gameFilePath];
    
    DLog(@"DownloadResource: %@",filePath);
    
    if ([[NSFileManager defaultManager] isReadableFileAtPath:filePath]) {
        NSError *error;
        
        unsigned long long remoteSize = [[gameFile objectForKey:@"size"] longLongValue];
        unsigned long long localSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error] fileSize];
        
        ELog(error);

        if (remoteSize == localSize) {
            
            NSString *localMD5 = [NSData MD5:filePath];
            NSString *remoteMD5 = [gameFile objectForKey:@"md5Hash"];
            
            if ([remoteMD5 isEqualToString:localMD5]) {
                DLog(@"MD5Hash Match, Skipping Download of GameFile: %@", gameFilePath);
                
                return filePath;
            } else {
                DLog(@"MD5Hash Mismatch, Re-downloading GameFile: %@", gameFilePath);
            }
        } else {
            DLog(@"FileSize Mismatch, Re-downloading GameFile: %@", gameFilePath);
        }
    } else {
        DLog(@"Downloading GameFile: %@", gameFilePath);
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/game/%@%@", serverUrl, gameId, gameFilePath]];
    
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    if (urlData)
    {
        [urlData writeToFile:filePath atomically:YES];
    }
    
    return filePath;
}

/*!
 *  Check extistance and MD5 of a GameFile.
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
+(BOOL) CheckResource:(NSNumber *)gameId
                      gameFile:(NSDictionary *)gameFile {
    
    NSString *gameFilePath = [gameFile objectForKey:@"path"];
    
    NSString *filePath = [ARLUtils GenerateResourceFileName:gameId path:gameFilePath];
    
    if ([[NSFileManager defaultManager] isReadableFileAtPath:filePath]) {
        NSError *error;
        
        unsigned long long remoteSize = [[gameFile objectForKey:@"size"] longLongValue];
        unsigned long long localSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error] fileSize];
        
        ELog(error);
        
        if (remoteSize == localSize) {
            
            NSString *localMD5 = [NSData MD5:filePath];
            NSString *remoteMD5 = [gameFile objectForKey:@"md5Hash"];
            
            if ([remoteMD5 isEqualToString:localMD5]) {
                DLog(@"MD5Hash Match, Skipping Download of GameFile: %@", gameFilePath);
                
                return YES;
            } else {
                DLog(@"MD5Hash Mismatch, Re-downloading GameFile: %@", gameFilePath);
            }
        } else {
            DLog(@"FileSize Mismatch, Re-downloading GameFile: %@", gameFilePath);
        }
    } else {
        DLog(@"Downloading GameFile: %@", gameFilePath);
    }
    
    return NO;
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

/*!
 *  Return the current time as a timestamp.
 *
 *  @return <#return value description#>
 */
+(long long int) Now {
    return (long long int)[[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000] longLongValue];
}

/*!
 *  Format a double as a Date/Time.
 *
 *  @param withUnixTime <#withUnixTime description#>
 *  @param stamp        <#stamp description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)formatDateTime:(NSString *)format withUnixTime:(NSString *)stamp {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:[stamp doubleValue]/1000.0f]];
}

/*!
 *  Format a double as a Date.
 *
 *  @param stamp        <#stamp description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)formatDate:(NSString *)stamp {
    return    [ARLUtils formatDateTime:@"dd-MMM-yyyy" withUnixTime:stamp];
}

/*!
 *  Format a double as a Date/Time.
 *
 *  @param stamp        <#stamp description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)formatDateTime:(NSString *)stamp {
    return    [ARLUtils formatDateTime:@"dd-MMM-yyyy HH:mm" withUnixTime:stamp];
}

///*!
// *  Format a double as a Date/Time.
// *
// *  @param withUnixTime <#withUnixTime description#>
// *  @param stamp        <#stamp description#>
// *
// *  @return <#return value description#>
// */
//+(NSString *)formatDateTime:(NSString *)format withUnixTime:(NSNumber *)stamp {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
//    return [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:[stamp doubleValue]/1000.0f]];
//}

/*!
 *  Convert html to an Attributed String.
 *
 *  @param theHtml <#theHtml description#>
 *
 *  @return <#return value description#>
 */
+ (NSAttributedString *)htmlToAttributedString:(NSString *)theHtml {
    return[[NSAttributedString alloc] initWithData:[theHtml dataUsingEncoding:NSUTF8StringEncoding]
                                           options:@{
                                                     NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                     NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)
                                                     }
                                documentAttributes:nil
                                             error:nil];
}


+ (void)popToViewControllerOnNavigationController:(Class)viewControllerClass
                             navigationController:(UINavigationController *)navigationController
                                         animated:(BOOL)animated {
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:viewControllerClass]) {
            [navigationController popToViewController:aViewController animated:animated];
        }
    }
}


+ (void)setBackButton:(UIViewController *)viewController
               action:(SEL)action
{
    NSString *backBtn = [[NSString stringWithFormat:@"%@ %@", backArrow, NSLocalizedString(@"Back", @"Back")]
                         stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(! viewController.navigationItem.leftBarButtonItem)
    {
        viewController.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:backBtn
                                         style:UIBarButtonItemStylePlain
                                        target:viewController
                                        action:action];
    }
    else
    {
      //  0x10302
        
        //U00002329
        viewController.navigationItem.leftBarButtonItem.title = backBtn;
        viewController.navigationItem.leftBarButtonItem.target = viewController;
        viewController.navigationItem.leftBarButtonItem.action = action;
    }
}

+ (NSString *)base64forData:(NSData*)theData
{
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

+ (NSString *)cleanHtml:(NSString *)theHtml {
    NSString *tmp = [[theHtml stringByReplacingOccurrencesOfString:@"<p>" withString:@"\r"]
                     stringByReplacingOccurrencesOfString:@"</p>" withString:@"\r"];
    
    // if ([theHtml rangeOfString:@"<p>"].location == 0) {
    //   theHtml = [theHtml substringFromIndex:3];
    // }
    
    // NSBigMutableString* x;
    
    //Remove Trailing </p>
    //    if ([theHtml rangeOfString:@"</p>"].location == theHtml.length-1-3) {
    //        theHtml = [theHtml substringToIndex:theHtml.length-1-3];
    //    }
    
    // The following call is slow!!
    if ([tmp rangeOfString:@"<"].location != NSNotFound && [tmp rangeOfString:@">"].location != NSNotFound) {
        tmp = [[ARLUtils htmlToAttributedString:tmp] string];
    }
    
    //Remove WhiteSpace (note U0000fffc is 'OBJECT REPLACEMENT CHARACTER' acording to unicode).
    return [tmp stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \r\n\t\U0000fffc"]];
    
    //return [theHtml stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/*!
 *  Convert NSDictionary to a JSON NSString.
 *
 *  @param jsonDictionary The NSDictionary to convert.
 *
 *  @return The resulting JSON NSString.
 */
+ (NSString *)jsonString:(NSDictionary *) jsonDictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:0
                                                         error:&error];
    
    return [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
}

static BOOL _YES_ = YES;
static BOOL _NO_ = NO;

+ (BOOL *)boolToBoolPointer:(BOOL) value {
    return value ? &_YES_:&_NO_;
}

+ (UIColor *)ColorToGrayScale:(UIColor *)color
{
    CGFloat red, green, blue, alpha;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    CGFloat y = ((red*77)+(green*151)+(blue*28)) / 256.0;

    // undo the scale by 256 and write to memory:
    return [UIColor colorWithRed:y green:y blue:y alpha:1.0];
}

+(UIColor *)ColorOrGrayScale:(UIColor *)color
                   isEnabled:(BOOL)isEnabled
{
    return isEnabled ? color : [ARLUtils ColorToGrayScale:color];
}

/*!
 *  Create a gradient UIImage.
 * 
 *  See http://stackoverflow.com/questions/16788305/how-to-create-uiimage-with-vertical-gradient-using-from-color-and-to-color
 *  And https://github.com/vilanovi/UIImage-Additions
 *
 *  @param topLeftColor     <#topLeftColor description#>
 *  @param bottomRightColor <#bottomRightColor description#>
 *  @param width            <#width description#>
 *  @param height           <#height description#>
 *
 *  @return <#return value description#>
 */
+ (UIImage *)GradientImageFromColors:(UIColor *)topLeftColor
                    bottomRightColor:(UIColor *)bottomRightColor
                               width:(int)width
                              height:(int)height {
    // Create a graphics context in the required size
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Create a colour space
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    // Create Gradient
    size_t gradientNumberOfLocations = 2;
    CGFloat gradientLocations[2] = { 0.0, 1.0 };
    
    CGFloat r0,g0,b0,a0;
    CGFloat r1,g1,b1,a1;
    
    [topLeftColor getRed:&r0 green:&g0 blue:&b0 alpha:&a0];
    [bottomRightColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    
    CGFloat gradientComponents[8] = {
        r0, g0, b0, a0,     // Start color
        r1, g1, b1, a1,     // End color
    };
    
    //    CGGradientRef gradient = CGGradientCreateWithColorComponents (colorspace, gradientComponents, gradientLocations, gradientNumberOfLocations);
    //
    // Fill the context with the gradient (vertical)
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace,
                                                                 gradientComponents,
                                                                 gradientLocations,
                                                                 gradientNumberOfLocations);
    
    CGContextDrawLinearGradient(context,
                                gradient,
                                CGPointMake(0,0),
                                CGPointMake(width, height),
                                kCGGradientDrawsAfterEndLocation);
    
    // Create an image from the context
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Release the gradient, colour space and context
    //CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    UIGraphicsEndImageContext();
    
    return [gradientImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
}

/*!
 *  See http://stackoverflow.com/questions/5677716/how-to-get-the-screen-width-and-height-in-ios
 *
 *  @param orientation <#orientation description#>
 *
 *  @return <#return value description#>
 */
+ (CGFloat)ScreenWidthForCurrentOrientation {
    return [ARLUtils ScreenWidthForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

+ (CGFloat)ScreenWidthForOrientation:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationLandscapeRight:
        case UIInterfaceOrientationLandscapeLeft:
            return [UIScreen mainScreen].bounds.size.height;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return [UIScreen mainScreen].bounds.size.width;
        case UIInterfaceOrientationUnknown:
            return [UIScreen mainScreen].bounds.size.width;
    }
}

/*!
 *  Make UIColor transparent by replacing the alpha value.
 *
 *  @param color <#color description#>
 *  @param alpha <#alpha description#>
 *
 *  @return <#return value description#>
 */
+ (UIColor *)MakeColorTransparent:(UIColor *)color
                            alpha:(CGFloat)alpha {
    CGFloat r,g,b,a;
    
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    return [UIColor colorWithRed:r
                           green:g
                            blue:b
                           alpha:alpha];
}

/*!
 *  Create a regular expression with given string and options.
 * 
 *  See http://www.raywenderlich.com/30288/nsregularexpression-tutorial-and-cheat-sheet
 */
+ (NSRegularExpression *)regularExpressionWithString:(NSString *)string options:(NSDictionary *)options
{
    // Create a regular expression
    BOOL isCaseSensitive = [[options objectForKey:kRWSearchCaseSensitiveKey] boolValue];
    BOOL isWholeWords = [[options objectForKey:kRWSearchWholeWordsKey] boolValue];
    
    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = isCaseSensitive ? 0 : NSRegularExpressionCaseInsensitive;
    
    NSString *placeholder = isWholeWords ? @"\\b%@\\b" : @"%@";
    NSString *pattern = [NSString stringWithFormat:placeholder, string];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&error];
    if (error)
    {
        NSLog(@"Couldn't create regex with given string and options");
    }
    
    return regex;
}

///*!
// *  Search for a searchString and replace it with the replacementString in the given text view with search options
// *
// *  @param searchString      <#searchString description#>
// *  @param replacementString <#replacementString description#>
// *  @param textView          <#textView description#>
// *  @param options           <#options description#>
// */
//- (void)searchAndReplaceText:(NSString *)searchString
//                    withText:(NSString *)replacementString
//                  inTextView:(UITextView *)textView
//                     options:(NSDictionary *)options
//{
//    // Text before replacement
//    NSString *beforeText = textView.text;
//    
//    // Create a range for it. We do the replacement on the whole
//    // range of the text view, not only a portion of it.
//    NSRange range = NSMakeRange(0, beforeText.length);
//    
//    // Call the convenient method to create a regex for us with the options we have
//    NSRegularExpression *regex = [ARLUtils regularExpressionWithString:searchString options:options];
//    
//    // Call the NSRegularExpression method to do the replacement for us
//    NSString *afterText = [regex stringByReplacingMatchesInString:beforeText options:0 range:range withTemplate:replacementString];
//    
//    // Update UI
//    textView.text = afterText;
//}

+ (NSURL *)convertStringUrl:(NSString *)fileName
                    fileExt:(NSString *)fileExt
                     gameId:(NSNumber *)gameId
{
    NSRange index = [fileName rangeOfString:[gameId stringValue]];
    
    //Distinguish between links from arlearn and external url's.
    //The ones from arlearn contain the gameId and are downloaded when the game downloads.
    //Thus we need to convert the url to a resource filename based one.
    
#pragma warn TODO Hide descriptiontext if not downloaded and internet is down (else hide player).
    
    if (index.length != 0) {
        //http://streetlearn.appspot.com/game/5794474118610944/generalItems/6464887106568192/audio
        
        NSString *path = [fileName substringFromIndex:index.location + index.length];
        path = [path stringByAppendingString:fileExt];
        
        NSString *resName = [ARLUtils GenerateResourceFileName:gameId
                                                 path:path];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:resName]) {
            return [[NSURL alloc] initFileURLWithPath:resName];
        } else {
            return [NSURL URLWithString:fileName];
        }
    } else {
        //https://dl.dropboxusercontent.com/u/20911418/ELENA%20pilot%20october%202013/Audio/Voice0001.aac
        return [NSURL URLWithString:fileName];
    }
}

+ (NSString *)replaceLocalUrlsinHtml:(NSString *)html
{
    NSString *pattern = @"<img src=\"game/";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSString *newImgTpl = [NSString stringWithFormat:@"<img src=\"file:///%@/", [ARLUtils GenerateTempDirectory]];
    
    return [regex stringByReplacingMatchesInString:html options:0
                                             range:NSMakeRange(0, [html length])
                                      withTemplate:newImgTpl];
}

@end
