//
//  WLline.m
//  WavyLeafProject
//
//  Created by Eric Forbes on 6/12/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import "WLline.h"

@implementation WLline

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIColor *color = [[UIColor alloc] initWithRed:0.58 green:0.72 blue:0.44 alpha:1.0];
        [self setBackgroundColor:color];
    }
    return self;
}

@end
