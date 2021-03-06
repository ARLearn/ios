//
//  ARLUtils.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/9/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

@interface ARLUtils : NSObject <UIAlertViewDelegate>

// See http://stackoverflow.com/questions/8755506/put-checkmark-in-the-left-side-of-uitableviewcell

#define emptySpace                  @"\u2001"
#define checkBoxDisabledChecked     @"\u2611"
#define checkBoxUnchecked           @"\u2B1C"
#define checkBoxEnabledChecked      @"\u2705"
#define radioButtonChecked          @"\u26AB"
#define radioButtonUnchecked        @"\u26AA"
#define checkMarkLight              @"\u2713",
#define checkMarkBold               @"\u2714",
#define thumbsUp                    @"\U0001F44D"
#define thumbsDown                  @"\U0001F44E"
#define lockLocked                  @"\U0001F512"
#define lockUnlocked                @"\U0001F513"
#define stripesOne                  @"\u268A"
#define stripesTwo                  @"\u268C"
#define stripesThree                @"\u2630"
#define backArrow                   @"\U000025C0\U0000FE0E"

#define TrimString( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]

#define TrimmedStringLength( object ) [[object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ] length]

typedef NS_ENUM (NSInteger, ResponseTypes) {
    UNKNOWN = 0,
    PHOTO   = 1,
    VIDEO   = 2,
    AUDIO   = 3,
    TEXT    = 4,
    NUMBER  = 5
};

#define ARL_SYNCREADY    @"ARL_syncReady"
#define ARL_SYNCPROGRESS @"ARL_syncProgress"
#define ARL_GOTAPN       @"ARL_GotAPN"
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
                                       entityName:(NSString *)entity
                                   managedContext:(NSManagedObjectContext *)ctx;

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
                                       nameFixups:(NSDictionary *)fixups
                                   managedContext:(NSManagedObjectContext *)ctx;

/*!
 *  Creates a NSManagedObject for a certain Entity and fills it with date from a NSDictionary.
 *
 *  See http://stackoverflow.com/questions/2563984/json-to-persistent-data-store-coredata-etc
 *
 *  @param dict   The Dictionary containing the values
 *  @param entity The Entity name to create.
 *  @param fixups List of mismatches between dict and NSManagerObject fields.
 *  @param data   List of fields and their data to populate with non dict data.
 *
 *  @return The NSManagedObject that has been created and inserted into Core Data
 */

+ (NSManagedObject *) ManagedObjectFromDictionary:(NSDictionary *)dict
                                       entityName:(NSString *)entity
                                       nameFixups:(NSDictionary *)fixups
                                       dataFixups:(NSDictionary *)data
                                   managedContext:(NSManagedObjectContext *)ctx;

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
 *  @return The NSManagedObject that has been updayed in Core Data.
 */
+ (NSManagedObject *) UpdateManagedObjectFromDictionary:(NSDictionary *)dict
                                          managedobject:(NSManagedObject *)managedobject
                                             nameFixups:(NSDictionary *)fixups
                                             dataFixups:(NSDictionary *)data
                                         managedContext:(NSManagedObjectContext *)ctx;

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

/*!
 *  Pretty Print json data to the log.
 *
 *  @param jsonData json as NSData
 *  @param url      the json url used.
 */
+(void) LogJsonData: (NSData *)jsonData
                 url: (NSString *)url;

/*!
 *  Pretty Print json data to the log.
 *
 *  @param jsonDictionary json as NSDictionary
 *  @param url            the json url used.
 */
+(void)LogJsonDictionary: (NSDictionary *) jsonDictionary
                     url: (NSString *) url;

/*!
 *  Fetch and recreate (if neccesary) the applications temp drectory.
 *
 *  @return <#return value description#>
 */
+(NSString *) GenerateTempDirectory;

/*!
 *  Generate, and recreate it's containing directory (if neccesary), the resource filename.
 *
 *  @param gameId The GameID
 *  @param path   The Partial url path found in teh GameFiles (starts with 'generalItems/').
 *
 *  @return <#return value description#>
 */
+(NSString *) GenerateResourceFileName:(NSNumber *)gameId path:(NSString *)path;

/*!
 *  Checks if the base cache directory exists.
 *
 *  @param gameId The GameID
 *
 *  @return TRUE if the directory exists
 */
+(BOOL) GameHasCache:(NSNumber *)gameId;

/*!
 *  Download a GameFile.
 *
 *  @param gameId   The GameId
 *  @param gameFile The GameFile description as NSDictionary.
 *
 *  @return The Local Path to the File.
 */
+(NSString *) DownloadResource:(NSNumber *)gameId gameFile:(NSDictionary *)gameFile;

/*!
 *  Check extistance and MD5 of a GameFile.
 *
 *  @param gameId   The GameId
 *  @param gameFile The GameFile description as NSDictionary.
 *
 *  @return The Local Path to the File.
 */
+(BOOL) CheckResource:(NSNumber *)gameId
             gameFile:(NSDictionary *)gameFile;
    
/*!
 *  Convert bytes to a readable string.
 *
 *  @param value <#value description#>
 *
 *  @return <#return value description#>
 */
+ (NSString *)bytestoString:(NSNumber *)value;

/*!
 *  Transform the image in grayscale, while keeping its transparency.
 *
 *  See http://stackoverflow.com/questions/1298867/convert-image-to-grayscale
 *
 *  @param inputImage The Image to be grayed.
 *
 *  @return The GrayScale Image.
 */
+ (UIImage *)grayishImage:(UIImage *)inputImage;

/*!
 *  Return the current time as a timestamp.
 *
 *  @return <#return value description#>
 */
+(long long int) Now;

/*!
 *  Format a double as a Date/Time.
 *
 *  @param withUnixTime <#withUnixTime description#>
 *  @param stamp        <#stamp description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)formatDateTime:(NSString *)format withUnixTime:(NSString *)stamp;

/*!
 *  Format a double as a Date/Time.
 *
 *  @param stamp        <#stamp description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)formatDate:(NSString *)stamp;

/*!
 *  Format a double as a Date/Time.
 *
 *  @param stamp        <#stamp description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)formatDateTime:(NSString *)stamp;

/*!
 *  Convert html to an Attributed String.
 *
 *  @param theHtml <#theHtml description#>
 *
 *  @return <#return value description#>
 */
+ (NSAttributedString *)htmlToAttributedString:(NSString *)theHtml;

/*!
 *  Pop the UIViewControllers up to a specified UIViewController Class.
 */
+ (void)popToViewControllerOnNavigationController:(Class)viewControllerClass
                             navigationController:(UINavigationController *)navigationController
                                         animated:(BOOL)animated;

+ (void)setBackButton:(UIViewController *)viewController
               action:(SEL)action;

+ (NSString *)base64forData:(NSData*)theData;

+ (NSString *)cleanHtml:(NSString *)theHtml;

+ (NSString *)jsonString:(NSDictionary *) jsonDictionary;

+ (BOOL *)boolToBoolPointer:(BOOL) value;

+ (UIColor *)ColorToGrayScale:(UIColor *)color;

+ (UIColor *)ColorOrGrayScale:(UIColor *)color
                   isEnabled:(BOOL)isEnabled;

/*!
 *  Create a gradient UIImage.
 *
 *  See http://stackoverflow.com/questions/16788305/how-to-create-uiimage-with-vertical-gradient-using-from-color-and-to-color
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
                              height:(int)height;
/*!
 *  Get the screen width corrected for the current device orientation.
 *
 *  @return <#return value description#>
 */
+ (CGFloat)ScreenWidthForCurrentOrientation;

/*!
 *  Get the screen width corrected for a device orientation.
 *
 *  @param orientation <#orientation description#>
 *
 *  @return <#return value description#>
 */
+ (CGFloat)ScreenWidthForOrientation:(UIInterfaceOrientation)orientation;

/*!
 *  Make UIColor transparent by replacing the alpha value.
 *
 *  @param color <#color description#>
 *  @param alpha <#alpha description#>
 *
 *  @return <#return value description#>
 */
+ (UIColor *)MakeColorTransparent:(UIColor *)color
                            alpha:(CGFloat)alpha;

#define kRWSearchCaseSensitiveKey @"kRWSearchCaseSensitiveKey"
#define kRWSearchWholeWordsKey @"kRWSearchWholeWordsKey"

+ (NSRegularExpression *)regularExpressionWithString:(NSString *)string
                                             options:(NSDictionary *)options;

+ (NSURL *)convertStringUrl:(NSString *)fileName
                    fileExt:(NSString *)fileExt
                     gameId:(NSNumber *)gameId;

+ (NSString *)replaceLocalUrlsinHtml:(NSString *)html;

// Block Parameter for Completion Signalling.
typedef void(^ARLCompletion)(BOOL);

@end
