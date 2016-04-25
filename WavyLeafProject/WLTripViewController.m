//
//  WLLoginViewController.m
//  WavyLeafProject
//
//  Created by Eric Forbes on 3/19/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import "WLTripViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "WLCreateAccountVC.h"
#import "UIViewController+MJPopupViewController.h"
#import "WLPopupView.h"

@interface WLTripViewController ()

@end

@implementation WLTripViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //Set tab bar title and image of this view controller
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"My Trip"];
        [tbi setImage:[UIImage imageNamed:@"play.png"]];
        
        //Set the Global Alarm Time to default 1
        //[self setTime:5];
        //[self setTime:[timeStepper value]];
        //[setTimeLabel setText:[NSString stringWithFormat:@"%.0f", [self time]]];
        //Display the default time on the display
        
        //Set to NO + to create the variable if the user NEVER goes to New Record screen
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"userIsOnRecordScreen"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}
- (void)viewWillAppear:(BOOL)animated
{
    //[self tripSwitchDidChange:nil];
    //[self timeStepperDidChange:nil];
    [self setTime:[timeStepper value]];
    [setTimeLabel setText:[NSString stringWithFormat:@"%.0f", [self time]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)timeStepperDidChange:(id)sender {
    [self setTime:[timeStepper value]];
    [setTimeLabel setText:[NSString stringWithFormat:@"%.0f", [self time]]];
}


//Called when trip switch On/Off
- (IBAction)tripSwitchDidChange:(id)sender
{
    
    //DO THIS OVER AGAIN
    // TRIP SWITCH GETS CALLED WHENAPPEAR, SO THE VIEW IS MOVED TO THE SAME SPOT OVER AND OVER AGAIN
    //BAD CODING!!
    
    if (tripSwitch.on){
        //Move the SetTimerView above the screen to hide it
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.75];
        
        //Hide "Set Minute Alerts"
        CGRect rect = CGRectMake(0.0, 45, 320.0, 86.0);
        [setTimerView setFrame:rect];
        
        //Move "Current Stats" up
        rect = CGRectMake(0.0, 170.0, 320.0, 236.0);
        [currentStatsView setFrame:rect];
        
        [UIView commitAnimations];
        
        //Set labels to starting values
        [alertMeLabel setText:[NSString stringWithFormat:@"%.0f minutes", [self time]]];
        
        
        //Set up recurring local notification to happen every X seconds (minutes * 60sec)
        int totalNotifications = (60 / self.time);//  1 hour / alert interval minutes = how many total notifications to schedule
        int repeatInSeconds = (60 * self.time);//  Convert the alert interval minutes to seconds
        int fireDate = repeatInSeconds;
        
        for (int i = 0; i < totalNotifications; i++){
            UILocalNotification *notifyAlarm = [[UILocalNotification alloc] init];
            [notifyAlarm setFireDate:[[NSDate date] dateByAddingTimeInterval:fireDate] ];
            [notifyAlarm setRepeatInterval:NSHourCalendarUnit];
            [notifyAlarm setAlertBody:@"Alert Reminder: Submit a Log!"];
            NSDictionary *userDict = [NSDictionary dictionaryWithObject:@"tripReminder" forKey:@"uid"];
            notifyAlarm.userInfo = userDict;
            
            //Set the new fireDate by adding the amount of seconds
            fireDate = fireDate + repeatInSeconds;
            
            //Add notification to iPhone
            [[UIApplication sharedApplication] scheduleLocalNotification:notifyAlarm];
       }
        
    //Set default values for logs and alerts '-'
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.75];
        
        //Show "Set Minute Alerts"
        CGRect rect = CGRectMake(0.0, 131.0, 320.0, 86.0);
        [setTimerView setFrame:rect];
        
        //Move "Current Stats" down
        rect = CGRectMake(0.0, 256.0, 320.0, 236.0);
        [currentStatsView setFrame:rect];
        
        [UIView commitAnimations];
        
        //Set labels to default values
        [alertMeLabel setText:@"-"];
        
        
        
        //Remove all Local Notifications that have uid of tripReminder
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *array = [app scheduledLocalNotifications];
        
        for (int i = 0; i < [array count]; i++){
            UILocalNotification *notifcation = [array objectAtIndex:i];
            NSDictionary *userDict = [notifcation userInfo];
            if ([[userDict objectForKey:@"uid"] isEqualToString:@"tripReminder"]){
                [app cancelLocalNotification:notifcation];
            }
        }
    
    
    }
}


- (IBAction)aboutBarButtonDidClick:(id)sender {
    WLPopupView *popup = [[WLPopupView alloc] init];
    [self presentPopupViewController:popup animationType:MJPopupViewAnimationSlideTopBottom animatedBlock:popup._wavyLabel];
}

- (IBAction)helpBarButtonDidClick:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://skappsrv.towson.edu/wavyleaf/website"];
    [[UIApplication sharedApplication] openURL:url];
}
@end
