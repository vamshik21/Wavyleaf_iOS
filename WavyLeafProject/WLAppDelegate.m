//
//  WLAppDelegate.m
//  WavyLeafProject
//
//  Created by Eric Forbes on 3/16/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import "WLAppDelegate.h"

#import "WLNewRecordViewController.h" // New Record Class
#import "WLTripViewController.h"
#import "WLCreateAccountVC.h"//Login Screen
#import <GoogleMaps/GoogleMaps.h> // Google Maps Class Header file
#import "WLNewTripSightViewController.h"










@implementation WLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    //Google Maps API Key
    [GMSServices provideAPIKey:@"AIzaSyCQdkAGYzYNBAMFOnxCqJXybr0-s_JVqpY"];
    
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    //Set up recurring 6 hour local notifications
    /*
    int totalNotifications = (24 / 6);
    int repeatInSeconds = (3600 * 6);
    int fireDate = 180;
    for (int i = 0; i < totalNotifications; i++){
        NSLog(@"Local->Server Notification in %d", fireDate);
        UILocalNotification *notifyAlarm = [[UILocalNotification alloc] init];
        [notifyAlarm setFireDate:[[NSDate date] dateByAddingTimeInterval:fireDate]];
        [notifyAlarm setRepeatInterval:NSDayCalendarUnit];
        [notifyAlarm setAlertBody:@"Click to Send Saved Logs to Server"];
        NSDictionary *userDict = [NSDictionary dictionaryWithObject:@"uploadReminder" forKey:@"uid"];
        notifyAlarm.userInfo = userDict;
        fireDate = fireDate + repeatInSeconds;
        [[UIApplication sharedApplication] scheduleLocalNotification:notifyAlarm];
    }*/
    
    
    //Set up a six hour notification the first time the app session is opened
    int sixHours = (3600 * 6);
    NSLog(@"Local->Server Notification in %d", sixHours);
    UILocalNotification *notifyAlarm = [[UILocalNotification alloc] init];
    [notifyAlarm setFireDate:[[NSDate date] dateByAddingTimeInterval:sixHours]];
    [notifyAlarm setAlertBody:@"Click to Send Saved Logs to Server"];
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:@"uploadReminder" forKey:@"uid"];
    notifyAlarm.userInfo = userDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:notifyAlarm];
    
    
    //Starting point for application
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"]) {
        //App Launching
        //Create tab bar views
        WLNewRecordViewController *w = [[WLNewRecordViewController alloc]init];
        WLTripViewController *loginController = [[WLTripViewController alloc] init];
        //Create UITabBarController
        UITabBarController *tabBarController = [[UITabBarController alloc] init];
        //Create array to hold view controllers
        NSArray *viewControllerArray = [NSArray arrayWithObjects:loginController, w, nil];
        //Assign view controller array to UITabBarController
        [tabBarController setViewControllers:viewControllerArray];
        
        //Set the view
        [[self window]setRootViewController:tabBarController];
        
    } else {
        
        //Record and store that the user has opened the app for the first time
        //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"userAccountCreated"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        
        WLCreateAccountVC *accVC = [[WLCreateAccountVC alloc] init];
        UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:accVC];
        [[self window] setRootViewController:navCon];
    }
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [WLDataStorage sendLocalDataToServer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    
    //Remove all Local Notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}


//Anytime your app has received a notification (BG or FG), when app is in FG this method gets called
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{

    //Parse notification
    NSDictionary *userDict = [notification userInfo];
    if ([[userDict objectForKey:@"uid"] isEqualToString:@"tripReminder"]) {
        NSLog(@"tripReminder - didReceiveLocalNotification");
        
        //Check if user is already on the new record screen
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"userIsOnRecordScreen"]){
            return;
        }
        
        //Before proceeding, check for internet and GPS
        if (![self internetAndLocationCheck]){
            return;
        }
        
        self.myLocationManager = [[CLLocationManager alloc] init];
        self.myLocationManager.delegate = self;
        
        [self.myLocationManager startUpdatingLocation];
    } else {
        NSLog(@"saveReminder - didReceiveLocalNotification");
    }
    
    
    
    
}



-(BOOL)internetAndLocationCheck
{
    //Before proceeding, check for internet
    if (![WLDataStorage checkInternet]){
        
        //Display error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This action requires an active Internet connection" message:nil delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil];
        [alert show];
        
        return false;
    }
    
    
    
    //Before proceeding, check for GPS
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This action requires you to enable Location Services" message:@"Settings -> Privacy -> Location" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil];
        [alert show];
        
        return false;
    }
    
    return true;
}











- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Cancel clicked, not doing anything right now
    if (buttonIndex == 0){
        return;
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //We received a new location
    //Grab location and open New Trip Sighting viewController
    CLLocation *newLocation = [locations objectAtIndex:0];
    
    WLNewTripSightViewController *newTripSighting = [[WLNewTripSightViewController alloc]initWithLocationCoordinate:newLocation.coordinate];
    [newTripSighting setModalTransitionStyle:UIModalTransitionStyleCoverVertical];//Set modal
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    
    //Stop updating location
    [self.myLocationManager stopUpdatingLocation];
    self.myLocationManager = nil; //Destroy object because we don't need it
    
    NSLog(@"Notification.. showing u POPOVER controller");
    //Display the New Trip Sighting view controller to screen
    [vc presentViewController:newTripSighting animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
    [self.myLocationManager stopUpdatingLocation];
    self.myLocationManager = nil; //Set the object to NOTHING, because we don't need it anymore
    
    //Show error message to user
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"My Trip Alert" message:@"ERROR: Unable to detect your location! Cannot create a log!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


@end
