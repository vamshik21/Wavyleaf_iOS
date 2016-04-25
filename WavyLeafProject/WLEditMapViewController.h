//
//  WLEditMapViewController.h
//  WavyLeafProject
//
//  Created by Eric Forbes on 3/31/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h> //MapKit Framework for displaying the map
#import <CoreLocation/CoreLocation.h> //Contains classes to determine device's geographical location


@class WLNewRecordViewController; //Able to pass data between controllers
@class WLMapPoint; //Pointer for object conforming to annotation protocol for removing annotations


@interface WLEditMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{

    IBOutlet MKMapView *mapView; //Displays map and labels
    
    CLLocationCoordinate2D mapCoordinates; //Holds the current map coordinates
    CLLocationManager *locationManager; //Interfaces with location hardware of device
    
    WLNewRecordViewController *newRecordVC;
    

    __weak IBOutlet UILabel *latitudeLabel;
    __weak IBOutlet UILabel *longitudeLabel;
    
    WLMapPoint *mapPoint;
}


-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinates recordViewController:(WLNewRecordViewController *)nrvc;


- (IBAction)doneEditingLocation:(id)sender;
- (IBAction)getCurrentLocation:(id)sender;

-(void)updateUI;



@end
