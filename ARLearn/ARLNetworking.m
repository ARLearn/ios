//
//  ARLNetworking.m
//  ARLearn
//
//  Created by Wim van der Vegt on 7/16/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLNetworking.h"

@implementation ARLNetworking

/*!
 *  See http://hayageek.com/ios-nsurlsession-example/
 */
+(void) sendHTTPGetWithDelegate:(id <NSURLSessionDelegate>)delegate withService:(NSString *)service
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject
                                                                 delegate: delegate
                                                            delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://streetlearn.appspot.com/rest/%@", service]];
    
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    // Setup Authorization Token (should not be neccesary for search, but it is!)
    [urlRequest addValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", authtoken] forHTTPHeaderField:@"Authorization"];
    
    // Setup Headers
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // Setup Method
    [urlRequest setHTTPMethod:@"GET"];
    
    // Setup Parameters (plain text or parameters like =@"name=Ravi&loc=India&age=31&submit=true") + Content encoding
    // Android: Content-Type: text/plain; charset=ISO-8859-1
    //[urlRequest setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest];
    [dataTask resume];
    
    	//if (token != null) request.setHeader("Authorization", "GoogleLogin auth=" + token); d324aa9b75782d9b7b76372a1f9439bd
//    request.setHeader("Accept", accept);application/json
//    equest.setHeader("Content-Type", contentType);application/json
//    //Content-Type: text/plain; charset=ISO-8859-1
//    'game' as query (seem,s hardcoded.
    
    
//    
//    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithURL:url
//                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                                                       if(error == nil)
//                                                       {
//                                                           NSString * text = [[NSString alloc] initWithData: data
//                                                                                                   encoding: NSUTF8StringEncoding];
//                                                           NSLog(@"Data = %@",text);
//                                                       }
//                                                       
//                                                   }];
    
//    [dataTask resume];
    
}

+(void) sendHTTPPostWithDelegate:(id <NSURLSessionDelegate>)delegate withService:(NSString *)service withBody:(NSString *)body
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:delegate
                                                            delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://streetlearn.appspot.com/rest/%@", service]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
  
    // Setup Authorization Token (should not be neccesary for search, but it is!)
    [urlRequest addValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", authtoken] forHTTPHeaderField:@"Authorization"];
    
    // Setup Headers
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    // Setup Method
    [urlRequest setHTTPMethod:@"POST"];

    // Setup Parameters (plain text or parameters like =@"name=Ravi&loc=India&age=31&submit=true") + Content encoding
    // Android: Content-Type: text/plain; charset=ISO-8859-1
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest];
    [dataTask resume];
}
//{
// "type": "org.celstec.arlearn2.beans.game.GamesList",
// "games": [
//           {
//               "type": "org.celstec.arlearn2.beans.game.Game",
//               "gameId": 27766001,
//               "title": "Heerlen game met Mark",
//               "config": {
//                   "type": "org.celstec.arlearn2.beans.game.Config",
//                   "mapAvailable": false,
//                   "manualItems": [],
//                   "locationUpdates": []
//               },
//               "lng": 5.958768,
//               "lat": 50.878495,
//               "language": "en"
//           },
//           {
//               "type": "org.celstec.arlearn2.beans.game.Game",
//               "gameId": 3749015,
//               "title": "Heerlen digitale dagen game",
//               "config": {
//                   "type": "org.celstec.arlearn2.beans.game.Config",
//                   "mapAvailable": false,
//                   "manualItems": [],
//                   "locationUpdates": []
//               },
//               "lng": 5.958768,
//               "lat": 50.878495,
//               "language": "en"
//           },
//           ]
//}
@end
