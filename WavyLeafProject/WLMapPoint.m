//
//  WLMapPoint.m
//  WavyLeafProject
//
//  Created by Eric Forbes on 4/1/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import "WLMapPoint.h"

@implementation WLMapPoint

@synthesize title, coordinate;

-(id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t subtitle:(NSString *)st
{
    self = [super init];
    if (self){
        coordinate = c;
        title = t;
        _subtitle = st;
    }
    
    return self;
}
-(id)init
{
    return [self initWithCoordinate:CLLocationCoordinate2DMake(43.07, -89.32) title:@"Select and Drag Marker" subtitle:@"for new location"];
}




-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    coordinate = newCoordinate;
}

@end
