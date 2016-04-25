//
//  WLAccountExtendedVC.h
//  WavyLeafProject
//
//  Created by Eric Forbes on 6/23/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLNewRecordViewController.h"
#import "WLTripViewController.h"
#import "WLAppDelegate.h"

@interface WLAccountExtendedVC : UIViewController <UIPickerViewDelegate, WLDataStorageDelegate>
{
    //Education Instance Variables
    __weak IBOutlet UIButton *eduButton;//Education Button
    NSArray *eduSelectionTitles;//Education Titles Array
    NSInteger eduCurrentSelection;//Current Selection of Education
    
    //Experience Instance Variables
    __weak IBOutlet UIButton *experienceButton;//Experience button
    NSArray *experienceSelectionTitles;//Experience titles array
    NSInteger experienceCurrentSelection;//Current select of experience
    
    //Plant Confidence Instance Variables
    __weak IBOutlet UIButton *plantConfButton;//Plant confidence button
    NSArray *plantSelectionTitles;//Plant confidence titles array
    NSInteger plantCurrentSelection;//Current index of plant confidence
    
    //WavyLeaf Confidence Instance Variables
    __weak IBOutlet UIButton *wavyConfButton;//Wavlyeaf confidence button
    NSInteger wavyCurrentSelection;//Current index of wavyleaf confidence
    
    __weak IBOutlet UIScrollView *scrollView;
    NSString *birthyear;
    NSString *username;
    NSString *emailaddress;
    UIActivityIndicatorView *activityIndicator;
}

//Constructors
- (id)initWithName:(NSString *)userName birthYear:(NSString *)birthYear emailAddress:(NSString *)emailAddress;




//Set button title defaults
- (void)setDefaults;

//NavigationBar 'Save' button action
- (void)didClickSaveButton;


- (IBAction)didClickEducation:(id)sender; //Education Button Clicked (show picker)
- (void)educationWasSelected:(NSNumber *)selectedIndex;//Education Picker Selected 
- (IBAction)didClickExperience:(id)sender;
- (void)experienceWasSelected:(NSNumber *)selectedIndex;
- (IBAction)didClickPlantID:(id)sender;
- (void)plantIDWasSelected:(NSNumber *)selectedIndex;
- (IBAction)didClickWavyID:(id)sender;
- (void)wavyIDWasSelected:(NSNumber *)selectedIndex;

@end
