//
//  WLLoginViewController.h
//  WavyLeafProject
//
//  Created by Eric Forbes on 3/19/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
@interface WLTripViewController : UIViewController
{

    __weak IBOutlet UISwitch *tripSwitch;
    __weak IBOutlet UIStepper *timeStepper;
    
    
    __weak IBOutlet UITableViewCell *setTimerView;
    __weak IBOutlet UIView *currentStatsView;
    
    
    __weak IBOutlet UILabel *alertMeLabel;

    __weak IBOutlet UILabel *setTimeLabel;

}

@property (nonatomic) double time;
@property (nonatomic, strong) UINavigationController *navigationController;
- (IBAction)timeStepperDidChange:(id)sender;
- (IBAction)tripSwitchDidChange:(id)sender;//Called when trip switch On/Off
- (IBAction)aboutBarButtonDidClick:(id)sender;
- (IBAction)helpBarButtonDidClick:(id)sender;


@end
