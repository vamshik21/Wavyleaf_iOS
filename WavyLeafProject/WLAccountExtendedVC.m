//
//  WLAccountExtendedVC.m
//  WavyLeafProject
//
//  Created by Eric Forbes on 6/23/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import "WLAccountExtendedVC.h"
#import "ActionSheetStringPicker.h"
#import "WLDataStorage.h"
#import "WLline.h"

@interface WLAccountExtendedVC ()

@end

@implementation WLAccountExtendedVC


- (id)initWithName:(NSString *)userName birthYear:(NSString *)birthYear emailAddress:(NSString *)emailAddress
{
    self = [super init];
    if (self){
        
        //Set iVars of passed parameters
        birthyear = birthYear;
        emailaddress = emailAddress;
        username = userName;
        
        //UINavigationController settings
        [self.navigationItem setTitle:@"Additional"];
        //UINavigationController bar button item
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(didClickSaveButton)];
        [self.navigationItem setRightBarButtonItem:bbi];
        
        
        //Assign Education selection titles
        eduSelectionTitles = [[NSArray alloc] initWithObjects:@"High School / GED", @"Some College", @"College - A.S.", @"College - B.S.", @"College - Masters", @"College - PhD", nil];
        //Assign Experience selection titles
        experienceSelectionTitles = [[NSArray alloc] initWithObjects:@"Less than a month", @"Once a month", @"Once a week", @"Multiple times a week", nil];
        //Assign plant confidence titles
        plantSelectionTitles = [NSArray arrayWithObjects:@"Not confident", @"Somewhat confident", @"Fairly confident", @"Expert", nil];
    
        
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        activityIndicator.center = CGPointMake(250.0, 24.0);
        [self.view addSubview:activityIndicator];
        [activityIndicator setHidden:YES];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Set the defaults
    [self setDefaults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    WLline *myLine = [[WLline alloc] initWithFrame:CGRectMake(20, 75, 280, 2.2)];
    [scrollView addSubview:myLine];
}



- (void)setDefaults
{
    //Set starting title of Education Button
    [eduButton setTitle:[eduSelectionTitles objectAtIndex:eduCurrentSelection] forState:UIControlStateNormal];
    
    //Set starting title of Experience Button
    [experienceButton setTitle:[experienceSelectionTitles objectAtIndex:experienceCurrentSelection] forState:UIControlStateNormal];
    
    //Set starting title of Plant Button
    [plantConfButton setTitle:[plantSelectionTitles objectAtIndex:plantCurrentSelection] forState:UIControlStateNormal];
    
    //Set starting title of WavyLeaf button
    [wavyConfButton setTitle:[plantSelectionTitles objectAtIndex:wavyCurrentSelection] forState:UIControlStateNormal];
}



- (IBAction)didClickEducation:(id)sender
{
    [ActionSheetStringPicker showPickerWithTitle:@"Select Education" rows:eduSelectionTitles initialSelection:eduCurrentSelection target:self successAction:@selector(educationWasSelected:) cancelAction:nil origin:sender];
   
    
}
- (void)educationWasSelected:(NSNumber *)selectedIndex
{
    //Set the current index pointer
    eduCurrentSelection = selectedIndex.integerValue;
    
    //Change title of button
    [eduButton setTitle:[eduSelectionTitles objectAtIndex:eduCurrentSelection] forState:UIControlStateNormal];
}

- (IBAction)didClickExperience:(id)sender
{
    [ActionSheetStringPicker showPickerWithTitle:@"Select Experience" rows:experienceSelectionTitles initialSelection:experienceCurrentSelection target:self successAction:@selector(experienceWasSelected:) cancelAction:nil origin:sender];
}
- (void)experienceWasSelected:(NSNumber *)selectedIndex
{
    //Set the index
    experienceCurrentSelection = selectedIndex.integerValue;
    
    //Change title of button
    [experienceButton setTitle:[experienceSelectionTitles objectAtIndex:experienceCurrentSelection] forState:UIControlStateNormal];
}

- (IBAction)didClickPlantID:(id)sender
{
    [ActionSheetStringPicker showPickerWithTitle:@"Select General Plant ID Confidence" rows:plantSelectionTitles initialSelection:plantCurrentSelection target:self successAction:@selector(plantIDWasSelected:) cancelAction:nil origin:sender];
}
- (void)plantIDWasSelected:(NSNumber *)selectedIndex
{
    //Set the index
    plantCurrentSelection = selectedIndex.integerValue;
    
    //Change title of button
    [plantConfButton setTitle:[plantSelectionTitles objectAtIndex:plantCurrentSelection] forState:UIControlStateNormal];
}

- (IBAction)didClickWavyID:(id)sender
{
    [ActionSheetStringPicker showPickerWithTitle:@"Select WavyLeaf Plant ID Confidence" rows:plantSelectionTitles initialSelection:wavyCurrentSelection target:self successAction:@selector(wavyIDWasSelected:) cancelAction:nil origin:sender];
}
- (void)wavyIDWasSelected:(NSNumber *)selectedIndex
{
    //Set the index
    wavyCurrentSelection = selectedIndex.integerValue;
    
    //Change title of button
    [wavyConfButton setTitle:[plantSelectionTitles objectAtIndex:wavyCurrentSelection] forState:UIControlStateNormal];
}

- (void)didClickSaveButton
{
    //Before proceeding, check for internet
    if (![WLDataStorage checkInternet]){
        
        //Display error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This app requires an active Internet connection" message:@"Please enable in your phone's Settings" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    
    WLDataStorage *storage = [[WLDataStorage alloc] initWithName:username BirthYear:birthyear Email:emailaddress Education:[eduSelectionTitles objectAtIndex:eduCurrentSelection] OutdoorExp:[experienceSelectionTitles objectAtIndex:experienceCurrentSelection] GeneralPlantID:[plantSelectionTitles objectAtIndex:plantCurrentSelection] WavyLeafID:[plantSelectionTitles objectAtIndex:wavyCurrentSelection]];
    storage.delegate = self;
    
    //Spin activity indicator
    [activityIndicator startAnimating];
    [activityIndicator setHidden:NO];
    
    //Store attributes on phone
    [storage serializeAndStoreLog];
    
 
    
}


#pragma mark - WLDataStorage delegate
-(void)processSucceeded
{
    //Generate a success popup
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your account has been successfully saved!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];*/
    
    [activityIndicator stopAnimating];
    [activityIndicator setHidden:YES];
    
    
    [self.navigationController.view removeFromSuperview];
    
    
    //Create tab bar views
    WLNewRecordViewController *w = [[WLNewRecordViewController alloc]init];
    WLTripViewController *loginController = [[WLTripViewController alloc] init];
    //Create UITabBarController
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    //Create array to hold view controllers
    NSArray *viewControllerArray = [NSArray arrayWithObjects:loginController, w, nil];
    //Assign view controller array to UITabBarController
    [tabBarController setViewControllers:viewControllerArray];
    
    
    
    //[viewControllers replaceObjectAtIndex:0 withObject:tabBarController];
    //[self.navigationController setViewControllers:];
    WLAppDelegate *appDelegate = (WLAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window setRootViewController:tabBarController];
    
}

-(void)processFailed
{
    //Generate a success popup
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR: Could not create account" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    
    [activityIndicator stopAnimating];
    [activityIndicator setHidden:YES];
}


@end
