//
//  ARLDefines.h
//  ARLearn
//
//  Created by Wim van der Vegt on 7/9/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#ifndef ARLearn_ARLDefines_h

    #define ARLearn_ARLDefines_h

    /*!
     *  Key for User Preferences.
     */
    #define ENABLE_LOGGING      @"enable_logging"

    /*!
     *  Key for Showing the Git Hash in Preferences.
     */
    #define GIT_HASH            @"git_hash"

    /*!
     *  Key for Showing the App Version in Preferences.
     */
    #define APP_VERSION         @"app_version"

    #define TILE                1234

    #define CACHINGTIME         60.0

    #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                                                     green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
                                                      blue:((float)(rgbValue & 0xFF))/255.0 \
                                                    alpha:1.0]
#endif
