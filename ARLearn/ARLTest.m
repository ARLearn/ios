//
//  ARLTest.m
//  ARLearn
//
//  Created by G.W. van der Vegt on 04/03/16.
//  Copyright © 2016 Open University of the Netherlands. All rights reserved.
//

#import "ARLTest.h"

@implementation ARLTest

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // init code
        [[NSBundle mainBundle] loadNibNamed:@"ARLTest" owner:self options:nil];
        
              self.bounds = self.view.bounds;
        //
        [self addSubview:self.view];
        //
        //        [self applyConstraints];
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder   {
    if (self = [super initWithCoder:aDecoder]) {
        // init code
        [[NSBundle mainBundle] loadNibNamed:@"ARLTest" owner:self options:nil];
        
        self.bounds = self.view.bounds;
        
        //[self applyConstraints];
        
        [self addSubview:self.view];
    }
    
    return self;
}

- (IBAction)tesButton:(id)sender {
    self.view.backgroundColor = [UIColor yellowColor];
}

@end
