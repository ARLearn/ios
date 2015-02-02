//
//  ARLGeneralItemViewController.h
//  ARLearn
//
//  Created by G.W. van der Vegt on 01/02/15.
//  Copyright (c) 2015 Open University of the Netherlands. All rights reserved.
//

#import "ARLUtils.h"
#import "ARLBeanNames.h"

#import "GeneralItem.h"

@interface ARLGeneralItemViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) GeneralItem *activeItem;

@end
