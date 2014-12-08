//
//  ARLDownloadViewController.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 05/12/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import "ARLDownloadViewController.h"

@interface ARLDownloadViewController ()

@end

@implementation ARLDownloadViewController

#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    [self DownloadGameFiles];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Properties

#pragma mark - Methods

-(void) DownloadGameFiles {

        //        {
        //            gameFiles =     (
        //                             {
        //                                 id = 5303563274158080;
        //                                 md5Hash = 03e55e8459740f42b6e82da62f8a738c;
        //                                 path = "/generalItems/17136036/audio";
        //                                 size = 139264;
        //                                 type = "org.celstec.arlearn2.beans.game.GameFile";
        //                             },
        //                             {
        //                                 id = 5333701143560192;
        //                                 md5Hash = 4afa6d39e6ad4428745e2dc8e5106903;
        //                                 path = "/generalItems/5778960537354240/audio";
        //                                 size = 64846;
        //                                 type = "org.celstec.arlearn2.beans.game.GameFile";
        //                             },
        //                             {
        //                                 id = 5891503092137984;
        //                                 md5Hash = 03e55e8459740f42b6e82da62f8a738c;
        //                                 path = "/generalItems/17186025/icon";
        //                                 size = 139264;
        //                                 type = "org.celstec.arlearn2.beans.game.GameFile";
        //                             },
        //                             {
        //                                 id = 5907919396667392;
        //                                 md5Hash = 3362069b7b43a2b44bd52a099ce0bb4f;
        //                                 path = "/generalItems/17186025/audio";
        //                                 size = 1281;
        //                                 type = "org.celstec.arlearn2.beans.game.GameFile";
        //                             },
        //                             {
        //                                 id = 6234711781277696;
        //                                 md5Hash = 7fcc4f2dbda00c5172f276e5fbf0ce37;
        //                                 path = "/gameSplashScreen";
        //                                 size = 745115;
        //                                 type = "org.celstec.arlearn2.beans.game.GameFile";
        //                             },
        //                             {
        //                                 id = 6337973398274048;
        //                                 md5Hash = 03b72d26392b1d0f8b59905e31c7851f;
        //                                 path = "/generalItems/13946007/audio";
        //                                 size = 4423;
        //                                 type = "org.celstec.arlearn2.beans.game.GameFile";
        //                             },
        //                             {
        //                                 id = 6389743323447296;
        //                                 md5Hash = 221f555a84368d83bafb501ed60f8f26;
        //                                 path = "/gameThumbnail";
        //                                 size = 139262;
        //                                 type = "org.celstec.arlearn2.beans.game.GameFile";
        //                             }
        //                             );
        //            type = "org.celstec.arlearn2.beans.game.GameFileList";
        //        }
    
    for (NSDictionary *gameFile in self.gameFiles) {
        /* NSString *MD5 =*/ [ARLUtils DownloadResource:self.gameId gameFile:gameFile];
    }
}

@end
