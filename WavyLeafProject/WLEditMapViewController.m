//
//  WLEditMapViewController.m
//  WavyLeafProject
//
//  Created by Eric Forbes on 3/31/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import "WLEditMapViewController.h"
#import "WLMapPoint.h"
#import "WLNewRecordViewController.h"

@interface WLEditMapViewController ()

@end

@implementation WLEditMapViewController

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinates recordViewController:(WLNewRecordViewController *)nrvc
{
    self = [super init];
    if (self){
        //Set instance variables
        mapCoordinates = coordinates;
        newRecordVC = nrvc; //Pass in the view controller in order to setCoordinates of that VC
        
        //Create location manager object
        locationManager = [[CLLocationManager alloc] init];
        //Set as accurate as possible, regardless of time it takes
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [locationManager setDelegate:self];

    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Hide the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    //Set the map type (only need to do this once)
    [mapView setMapType:MKMapTypeSatellite];
    
    //Set delegate
    [mapView setDelegate:self];
    
    //Update the UI
    [self updateUI];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    //Show the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [mapView setDelegate:nil];
    [locationManager setDelegate:nil];
    
    //Remove KVOs and any observers?
}


//
//
//
// DELEGATES
//
//
//

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //Stop the updating of user location
    [locationManager stopUpdatingLocation];
    
    //Set the new coordinates and update the UI
    CLLocation *location = [locations objectAtIndex:0];
    mapCoordinates = location.coordinate;
    

    
    [self updateUI];
}


-(MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    //Check for reusable pin
    MKPinAnnotationView *pin = (MKPinAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:@"MyLocation"];

    
    //If no reusable pin of this type, create a new one
    if (!pin){
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyLocation"];
    } else {
        pin.annotation = annotation;
    }
    

    [pin setDraggable:YES];
    [pin setCanShowCallout:YES];
    [pin setEnabled:YES];
    [pin setSelected:YES];

    
    return pin;
}
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (oldState == MKAnnotationViewDragStateEnding){
        
        //Set the coordinates and update the UI
        mapCoordinates = [[view annotation] coordinate];
        [self updateUI];
        
    }
    
}











- (IBAction)doneEditingLocation:(id)sender {
    //Set coordinates in the new record VC
    [newRecordVC setCoordinates:mapCoordinates];
    
    //Set if viewWillAppear method correctly in new record VC
    [newRecordVC setDidAppearFromEditingScreen:true];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    newRecordVC = nil;
    
}

- (IBAction)getCurrentLocation:(id)sender {
    [locationManager startUpdatingLocation];
    //Activity spinner?
    //Disable the refresh button?
}




-(void)updateUI {
    
    //Set current coordinates to UI
    [latitudeLabel setText:[NSString stringWithFormat:@"%f", mapCoordinates.latitude]];
    [longitudeLabel setText:[NSString stringWithFormat:@"%f", mapCoordinates.longitude]];
    
    
    //Set zoom level and coordinate zone
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapCoordinates, 300, 300);
    [mapView setRegion:region animated:YES];
    
    
    //See if mapPoint even exists
    if (mapPoint){
        
        //Remove the Annotation Pin
        [mapView removeAnnotation:mapPoint];
    }
    
    //Add the new annotation pin with the location
    mapPoint = [[WLMapPoint alloc] initWithCoordinate:mapCoordinates title:@"Hold and Drag Marker" subtitle:@"for new location"];
    
    [mapView addAnnotation:mapPoint];
    [mapView selectAnnotation:mapPoint animated:YES];
    
    
}





@end
