//
//  WLAppDelegate.h
//  WavyLeafProject
//
//  Created by Eric Forbes on 3/16/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>//Framework provides functionality for grabbing GPS of iOS device

@interface WLAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

{
    
    bool fileLock;
}

@property (strong, nonatomic) UIWindow *window;//Don't delete this is required for App Delegate
@property (nonatomic, strong) CLLocationManager *myLocationManager;//added myself


@end
