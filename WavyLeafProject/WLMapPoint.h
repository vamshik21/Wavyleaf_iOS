//
//  WLMapPoint.h
//  WavyLeafProject
//
//  Created by Eric Forbes on 4/1/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface WLMapPoint : NSObject <MKAnnotation>
{
    
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t subtitle:(NSString *)st;
-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
