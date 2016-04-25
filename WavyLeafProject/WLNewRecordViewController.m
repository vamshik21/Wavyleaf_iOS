






//
//  WLNewRecordViewController.m
//  WavyLeafProject
//
//  Created by Eric Forbes on 3/16/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import "WLNewRecordViewController.h"

#import "WLEditMapViewController.h" //Edit map class
#import "ActionSheetStringPicker.h" //Action&Picker class to display 'Square Selections'
#import "WLDataStorage.h" //D
#import "Base64.h"



@interface WLNewRecordViewController ()

@end

@implementation WLNewRecordViewController

@synthesize coordinates, percentage, didAppearFromEditingScreen, areaSelectionTitles, areaSelectionIndex, areaSelectionValues, treatmentSelectionTitles, treatmentSelectionIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [areaInfestedTextView setDelegate:self];
        
        
        //Set tab bar title and image of this view controller
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"New Sighting"];
        [tbi setImage:[UIImage imageNamed:@"plus.png"]];
        
    
        
        
        //Create a toolbar above the keyboard with a button that dismisses the keyboard
        keyboardToolbar = [[UIToolbar alloc] init];
        UIBarButtonItem *bbii = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditingText)];
        NSArray *array = [NSArray arrayWithObject:bbii];
        [keyboardToolbar setItems:array];
        [keyboardToolbar setBarStyle:UIBarStyleDefault];
        [keyboardToolbar sizeToFit];
        
        //Set toolbar below the screen
        CGRect frame = keyboardToolbar.frame;
        //frame.origin.y = self.view.frame.size.height;
        frame.origin.y = self.view.frame.size.height;
        keyboardToolbar.frame = frame;
        [keyboardToolbar setHidden:YES];
        [self.view addSubview:keyboardToolbar];
        
        //Create starting note placeholder text
        placeholderNoteText = @"Enter Notes Here...";
        
        //Create stock image identifier text
        stockImage = @"stockImage";
        
        //Create array of VALUES for the percent segment to use
        percetangeValueArray = [NSArray arrayWithObjects:@"0", @"1-10", @"10-25", @"25-50", @"50-75", @"75-100", nil];
        
        
        //Create array of Square Selections to display in the ActionSheetStringPicker
        self.areaSelectionTitles = [NSArray arrayWithObjects:@"Square Feet", @"Square Meters", @"Acres", @"Hectares", nil];
        //Create array of the actual values
        self.areaSelectionValues = [NSArray arrayWithObjects:@"SF", @"SM", @"A", @"H", nil];
        self.treatmentSelectionTitles = [NSArray arrayWithObjects:@"None", @"Herbicide", @"Hand-pull", @"Other", nil];
        
        
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        activityIndicator.center = CGPointMake(250.0, 44.0);
        [self.view addSubview:activityIndicator];
        [activityIndicator setHidden:YES];
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    //ENABLE THIS
    //[scrollView setContentOffset:CGPointZero];
    
    
    //Add the notifications that will respond to the keyboard opening/closing
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)viewDidLayoutSubviews
{
    //Moves navigation bar and EVERYTHING down
    
   /* CGRect viewBounds = self.view.bounds;
    CGFloat topBarOffset = self.topLayoutGuide.length;
    viewBounds.origin.y = topBarOffset * -.5;
    self.view.bounds = viewBounds;
    */
    // Check if we are running on ios7

}

- (void)viewDidLoad //Happens only one
{
    [super viewDidLoad];
   
    
    [self.view layoutIfNeeded];
    
    //Set if the view before WLNewRecordViewController is the editing VC
    [self setDidAppearFromEditingScreen:false];
    
    //Change font of percent segment
    UIFont *font = [UIFont boldSystemFontOfSize:14.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [percentSegment setTitleTextAttributes:attributes forState:UIControlStateNormal];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //vamshi- to dismiss the poped up keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //Store variable for local notification
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"userIsOnRecordScreen"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Remove the notifications that respond to keyboard opening/closing
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    //Set this is false... it will get changed to true only if coming from another view
    [self setDidAppearFromEditingScreen:false];
    
    
    //Set the logical view of the scrollview
    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)animated:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated
{
    //Store variable for local notification
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"userIsOnRecordScreen"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //If previous view was not editing screen.. get new location
    if (!self.didAppearFromEditingScreen){
        [self refreshScreenWithNewDefaults];
    }
    else {//User came from edit map screen
        //update location with new coordinates
        [self updateMapUI];
    }
    
    //[scrollView setContentSize:CGSizeMake(320, 925)];
    //[scrollView setFrame:CGRectMake(0, 63, 520, 650)];
    //[scrollView setContentSize:CGSizeMake(320, 950)];
    //YES THIS IS IT
    [scrollView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 342.0, 0.0)];
}











//DELEGATES
//
//
//
//
//
//
//


//Method for KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"myLocation"] && [object isKindOfClass:[GMSMapView class]]){
        
        //Found new location
        if (mapView_.myLocation != NULL) {
            
            //Edit GPS coordinates to coordinate accessors
            NSLog(@"Coord: %f", mapView_.myLocation.coordinate.latitude);
            NSLog(@"Coord: %f", mapView_.myLocation.coordinate.longitude);

            [self setCoordinates:mapView_.myLocation.coordinate];
            
            //Udpdate map with new coordinates
            [self updateMapUI];
            
            //Remove observer because you just need to grab locations ONCE
            [mapView_ removeObserver:self forKeyPath:@"myLocation"];
            
            //Disable updating the users GPS location (all changes is done with WLEditMapViewController, including changing back to GPS
            mapView_.myLocationEnabled = FALSE;
            
            
        }
        
    }
}




//Method sent when a photo is select
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Get picked image from info dictionary
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //Put image onto screen
    [imageView setImage:image];
    
    //Don't set to defaults--newrecord screen did not come from tabbar, it came from imagepickerviewcontroller
    //You want the picture to stay on the screen!
    [self setDidAppearFromEditingScreen:true];
    
    //Take image picker off screen (required)
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}





//CUSTOM
//


- (void)refreshScreenWithNewDefaults
{
    //Refresh screen with new defaults
    //start spinning activity indicator and stop when location is found
    
    
    //GOOGLE MAPS LOADING
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.8683 longitude:151.2086 zoom:18];
    mapView_ = [GMSMapView mapWithFrame:mapViewOnScreen.bounds camera:camera];
    [mapViewOnScreen addSubview:mapView_];
    [mapViewOnScreen addSubview:editMapButton];//Add edit button or else it's hidden
    //Change maptype to satellite
    mapView_.mapType = kGMSTypeSatellite;
    mapView_.settings.scrollGestures = NO;//freeze the scroll
    mapView_.settings.zoomGestures = NO;//freeze the zoom
    //Start searching for user location and show dot
    mapView_.myLocationEnabled = YES;
    //Add an observer for MyLocation to the GoogleMaps instance in order to track user location
    [mapView_ addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:NULL];
    
    
    
    
    
    
    //Set verify coordinate switch to OFF
    [verifyCoordinateSwitch setOn:FALSE];
    
    
    //Set note text to show initial placeholdertext
    [userNoteTextView setText:placeholderNoteText];
    
    
    //Reset index and title of Treatment button
    self.treatmentSelectionIndex = 0;
    [treatmentSelectedButton setTitle:[[self treatmentSelectionTitles] objectAtIndex:treatmentSelectionIndex] forState:UIControlStateNormal];
    
    //Set current index of the area type selected array to 0
    self.areaSelectionIndex = 0;
    //Set the model attribute area type to default areatype (ex//"SF")
    [self setAreatype:[self.areaSelectionValues objectAtIndex:self.areaSelectionIndex]];
    //Use the model's index and set the title of the button from the array
    [areaInfestedButton setTitle:[[self areaSelectionTitles] objectAtIndex:self.areaSelectionIndex] forState:UIControlStateNormal];
    //Clear area text box
    [areaInfestedTextView setText:@""];
    
    
    
    
    //Set the image to default picture
    [imageView setImage:[UIImage imageNamed:@"ic_camera.png"]];
    //Set image identifier to that of @"stockImage" --> Detect if using stock image or not by looking at images identifier
    [[imageView image] setAccessibilityIdentifier:stockImage];
    
    
    
    
    //THIS percentSegment starts at 0 index, so set it's value
    NSLog(@"value: %@", [percetangeValueArray objectAtIndex:0]);
    NSLog(@"oldPercentage: %@", self.percentage);
    [self setPercentage:[percetangeValueArray objectAtIndex:0]];
    //Set default selected segement at index 0
    [percentSegment setSelectedSegmentIndex:0];
}





- (void)updateMapUI
{
    //Change text on coordinate labels
    [latitudeLabel setText:[NSString stringWithFormat:@"%f", [self coordinates].latitude]];
    [longitudeLabel setText:[NSString stringWithFormat:@"%f", [self coordinates].longitude]];
    
    //Clear the markers
    [mapView_ clear];
    
    //Change marker to current coordinates and add to screen
    GMSMarker *options = [[GMSMarker alloc] init];
    options.position = [self coordinates];
    options.map = mapView_;
    
    //Change camera on UI map
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self coordinates].latitude longitude:[self coordinates].longitude zoom:17];
    [mapView_ setCamera:camera];
    
    
}



















- (IBAction)editMapLocation:(id)sender {
    
    WLEditMapViewController *editMapController = [[WLEditMapViewController alloc] initWithCoordinate:[self coordinates] recordViewController:self];
    
    [self presentViewController:editMapController animated:YES completion:nil];
}






- (IBAction)takePicture:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    //If device has camera, take a picture, otherwise pick from library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    
    [imagePicker setDelegate:self];
    
    //Present view controller/image picker on screen
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    
}





//Method called when user selects Percent UISegmentedControl
- (IBAction)percentDidChange:(id)sender{
    
    
    
    for (int i = 0; i < [percetangeValueArray count]; i++){
        
        if (percentSegment.selectedSegmentIndex == i){
            
            [self setPercentage:[percetangeValueArray objectAtIndex:i]];
            
            return;
        }
    }
    
    
}

-(IBAction)saveReportingData:(id)sender
{
    
    NSLog(@"--Save Button Clicked\n");
    //Check if string is valid
    if ([areaInfestedTextView.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Area infested is missing" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //Verify the area infested digit is 4 or under
    if (areaInfestedTextView.text.length > 4){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Area infested has a max digit of 4" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    
    //Check if user verfied coordinates (switch)
    if (![verifyCoordinateSwitch isOn]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must verify the location coordinates" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    
    //Before proceeding, check for internet and GPS
    if (![self locationCheck]){
        return;
    }
    
    //String to hold Base64 encoded image
    __block NSString *b64EncString = @"";
    
    //Determine if using stock image or not
    if (![imageView.image.accessibilityIdentifier isEqualToString:stockImage]){
        
        dispatch_queue_t imageQueue = dispatch_queue_create("Image Queue", NULL);
        dispatch_async(imageQueue, ^{
            NSData *dataObj = UIImageJPEGRepresentation(imageView.image, 0.1f);
            [Base64 initialize];
            b64EncString = [Base64 encode:dataObj];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createDataStorageObject:b64EncString];
            });
        });
        
        
    } else {
        
        [self createDataStorageObject:b64EncString];
    }
    
    
}

- (void)createDataStorageObject:(NSString *)b64EncString
{
    NSLog(@"--Creating data storage object\n");
    //Create datetime
    NSDate *now = [NSDate date];
    
    //Grab user id
    NSString *udid = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"];
    
    //Don't send placeholder next
    NSLog(@"NRVC placeholder--> %@", placeholderNoteText);
    //Add attributes to storage object
    WLDataStorage *storage = [[WLDataStorage alloc] initWithUDID:udid PercentSeen:self.percentage DateTime:now latitude:self.coordinates.latitude longitude:self.coordinates.longitude areaValue:areaInfestedTextView.text areaType:[areaSelectionValues objectAtIndex:self.areaSelectionIndex] notes:userNoteTextView.text notesPlaceHolderText:placeholderNoteText base64Image:b64EncString treatment:[treatmentSelectedButton currentTitle]];
    storage.delegate = self;
    
    //Spin activity indicator
    [activityIndicator startAnimating];
    [activityIndicator setHidden:NO];
    
    [saveButton setEnabled:NO];
    
    //Store attributes on phone
    [storage serializeAndStoreLog];
}




- (IBAction)treatmentHelpButtonOnClick:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"What treatment, if any, was conducted?" message:nil delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)percentHelpButtonOnClick:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"How much of the area you see is covered by Wavyleaf?" message:nil delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}



- (void)doneEditingText //THIS IS CALLED FOR DONE EDITING TEXT OF NOTE AND INFESTED AREA!! (SPLIT THIS IN HALF!!!
{
    //Add placeholder text back
    // only if user did not enter anything
    if ([areaInfestedTextView isFirstResponder]){
        
        [areaInfestedTextView resignFirstResponder];
        
    } else if ([userNoteTextView isFirstResponder]){
        
        if ([[userNoteTextView text] isEqualToString:@""]){
            
            [userNoteTextView setText:placeholderNoteText];
        }
        
        //take away keyboard screen
        [userNoteTextView resignFirstResponder];
    }
}





- (void)keyboardWillHide:(NSNotification *)notification
{
    //Move view down back to default
    [self moveTextFieldsUp:false];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    
    /*
     CGRect frame = keyboardToolbar.frame;
     frame.origin.y = self.view.frame.size.height;
     keyboardToolbar.frame = frame;
     */
    keyboardToolbar.hidden = YES;
    
    [UIView commitAnimations];
    
    //Add placeholder text
    if ([[userNoteTextView text] isEqualToString:@""]){
        [userNoteTextView setText:placeholderNoteText];
    }
    
    //Show the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}
- (void)keyboardWillShow:(NSNotification *)notification
{
    //Hide the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    //Move view up in order to see text fields properly
    [self moveTextFieldsUp:true];
    [UIView beginAnimations:nil context:NULL]; //START ANIMATION
    [UIView setAnimationDuration:0.3];
    
    //Add toolbar above keyboard
    CGRect frame = [keyboardToolbar frame];
    //260 is the height of the keyboard.. so minus it
    frame.origin.y = self.view.frame.size.height - 40;
    keyboardToolbar.frame = frame;
    [keyboardToolbar setHidden:NO];
    

    [UIView commitAnimations]; //END ANIMATION
    
    
    
    
    
    //Remove placeholder text
    if ([[userNoteTextView text] isEqualToString:placeholderNoteText]){
        [userNoteTextView setText:@""];
    }
    
    
}




- (IBAction)treatmentButtonOnClick:(id)sender {
    NSLog(@"Treatment Button CLICKED");
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select the Treatment Given" rows:self.treatmentSelectionTitles initialSelection:self.treatmentSelectionIndex target:self successAction:(@selector(treatmentButtonWasSelected:element:)) cancelAction:nil origin:sender];
}

- (IBAction)areaInfestedButtonOnClick:(id)sender {
    NSLog(@"Area Infested CLICKED");
    [ActionSheetStringPicker showPickerWithTitle:@"Select the Area" rows:[self areaSelectionTitles] initialSelection:[self areaSelectionIndex] target:self successAction:(@selector(areaInfestedWasSelected:element:)) cancelAction:nil origin:sender];
}
- (void)areaInfestedWasSelected:(NSNumber *)selectedIndex element:(id)element
{
    //Grab the index and set the model's index of the selected item
    self.areaSelectionIndex = [selectedIndex intValue];
    
    
    //Use the model's index and set the title of the button from the array
    [areaInfestedButton setTitle:[[self areaSelectionTitles] objectAtIndex:self.areaSelectionIndex] forState:UIControlStateNormal];
    
    //Set the actual value for the title
    [self setAreatype:[[self areaSelectionValues] objectAtIndex:[self areaSelectionIndex]]];
}
-(void)treatmentButtonWasSelected:(NSNumber *)selectedIndex element:(id)element
{
    //Grab index
    self.treatmentSelectionIndex = [selectedIndex intValue];
    
    //Set title
    [treatmentSelectedButton setTitle:[[self treatmentSelectionTitles] objectAtIndex:self.treatmentSelectionIndex] forState:UIControlStateNormal];
    
    NSLog(@"Selection: %@", [treatmentSelectionTitles objectAtIndex:self.treatmentSelectionIndex]);
}


- (void)moveTextFieldsUp:(BOOL)up
{
    //CGRect newframe = self.view.frame;
    CGRect newframe = self.view.frame;
    
    if (up){
        newframe.origin.y -= 170;
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = newframe;
        }];
        
    } else {
        newframe.origin.y += 170;
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = newframe;
        }];
    }
}

-(BOOL)internetCheck
{
    //Before proceeding, check for internet
    if (![WLDataStorage checkInternet]){
        
        //Display error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This action requires an active Internet connection" message:nil delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil];
        [alert show];
        
        return false;
    }
    
    return true;
}

-(BOOL)locationCheck
{
    //Before proceeding, check for GPS
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This action requires you to enable Location Services" message:@"Settings -> Privacy -> Location" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil];
        [alert show];
        
        return false;
    }
    
    return true;
}



#pragma mark - WLDataStorage delegate
-(void)processSucceeded
{
    [saveButton setEnabled:YES];
    
    //Generate a success popup
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your log has been successfully saved!" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    
    [activityIndicator stopAnimating];
    [activityIndicator setHidden:YES];
    [self refreshScreenWithNewDefaults];
}

-(void)processFailed
{
    [saveButton setEnabled:YES];
    
    //Generate a success popup
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR: Could not save log" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    
    [activityIndicator stopAnimating];
    [activityIndicator setHidden:YES];
}

-(void)processSaved
{
    [saveButton setEnabled:YES];
    
    //Generate a success popup
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your log has been saved locally!" message:@"You must enable Internet Connectivity in Settings!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    
    [activityIndicator stopAnimating];
    [activityIndicator setHidden:YES];
    [self refreshScreenWithNewDefaults];
}

//vamshi - Dissmiss the keyboard when the user touches on the other area of the screen
-(void)dismissKeyboard {
    [userNoteTextView resignFirstResponder];
}


@end
