//
//  WLNewTripSightViewController.m
//  WavyLeafProject
//
//  Created by Eric Forbes on 5/4/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import "WLNewTripSightViewController.h"
#import "WLDataStorage.h" //Data Storage
#import "ActionSheetStringPicker.h"
#import "Base64.h"

@interface WLNewTripSightViewController ()

@end

@implementation WLNewTripSightViewController

@synthesize coordinates, percentage, areatype, areaSelectionIndex, areaSelectionTitles, areaSelectionValues, didAppearFromImagePickerController, treatmentSelectionIndex, treatmentSelectionTitles;


- (id)initWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        [areaInfestedTextView setDelegate:self];
        
        //Set tab bar title and image of this view controller
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"New Sighting"];
        [tbi setImage:[UIImage imageNamed:@"plus.png"]];
        
        
        //Set coordinates of the New Sighting
        self.coordinates = locationCoordinate;
        
        
        //Create stock image identifier text
        stockImage = @"stockImage";
        
        //Create starting note placeholder text
        placeholderNoteText = @"Enter Notes Here...";
        
        
        //Create array of VALUES for the percent segment to use
        percetangeValueArray = [NSArray arrayWithObjects:@"0", @"1-10", @"10-25", @"25-50", @"50-75", @"75-100", nil];
        //THIS percentSegment starts at 0 index, so set it's value
        [self setPercentage:[percetangeValueArray objectAtIndex:0]];
        //Set default selected segement at index 0
        [percentSegment setSelectedSegmentIndex:0];
        
        self.treatmentSelectionTitles = [NSArray arrayWithObjects:@"None", @"Herbicide", @"Hand-pull", @"Other", nil];
        
        
        
        //Create array of Square Selections to display in the ActionSheetStringPicker
        self.areaSelectionTitles = [NSArray arrayWithObjects:@"Square Feet", @"Square Meters", @"Acres", @"Hectares", nil];
        //Create array of the actual values
        self.areaSelectionValues = [NSArray arrayWithObjects:@"SF", @"SM", @"A", @"H", nil];
        
        
        
        //Set current index of the area type selected array to 0
        self.areaSelectionIndex = 0;
        //Set the model attribute area type to default areatype (ex//"SF")
        [self setAreatype:[self.areaSelectionValues objectAtIndex:self.areaSelectionIndex]];
        
        //Reset index and title of Treatment button
        self.treatmentSelectionIndex = 0;
        [treatmentSelectedButton setTitle:[[self treatmentSelectionTitles] objectAtIndex:treatmentSelectionIndex] forState:UIControlStateNormal];
        
        
        
        //Create a toolbar above the keyboard with a button that dismisses the keyboard
        keyboardToolbar = [[UIToolbar alloc] init];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditingText)];
        NSArray *array = [NSArray arrayWithObject:bbi];
        [keyboardToolbar setItems:array];
        [keyboardToolbar setBarStyle:UIBarStyleBlackTranslucent];
        [keyboardToolbar sizeToFit];
        
        //Set toolbar below the screen
        CGRect frame = keyboardToolbar.frame;
        frame.origin.y = self.view.frame.size.height;
        keyboardToolbar.frame = frame;
        [self.view addSubview:keyboardToolbar];
        
        
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        activityIndicator.center = CGPointMake(250.0, 24.0);
        [self.view addSubview:activityIndicator];
        [activityIndicator setHidden:YES];
        
    }
    return self;
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Add the notifications that will respond to the keyboard opening/closing
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //If previous screen
    if (!didAppearFromImagePickerController){
        //Set the screen defaults
        [self screenDefaults];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //Store variable for local notification
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"userIsOnRecordScreen"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)dealloc
{
    //[locationManager setDelegate:nil];  WHY IS THIS COMMENTED OUT!?!?!
    [areaInfestedTextView setDelegate:nil];
}



- (void)viewDidLoad //Happens only one
{
    [super viewDidLoad];
    
    //Set if the view before this view is the ImagePickerController
    [self setDidAppearFromImagePickerController:false];
    
    //Change font of percent segment
    UIFont *font = [UIFont boldSystemFontOfSize:14.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:UITextAttributeFont];
    [percentSegment setTitleTextAttributes:attributes forState:UIControlStateNormal];
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
    
    //Set to false, auto set to TRUE if returning from ImagePickerController
    //Used for setting defaults on screen
    [self setDidAppearFromImagePickerController:false];
}




























- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Get picked image from info dictionary
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //Put image onto screen
    [imageView setImage:image];
    
    //Don't set to defaults--newrecord screen did not come from tabbar, it came from imagepickerviewcontroller
    //You want the picture to stay on the screen!
    [self setDidAppearFromImagePickerController:true];
    
    //Take image picker off screen (required)
    [self dismissViewControllerAnimated:YES completion:nil];
    
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



- (IBAction)percentDidChange:(id)sender {
    for (int i = 0; i < [percetangeValueArray count]; i++){
        
        if (percentSegment.selectedSegmentIndex == i){
            
            [self setPercentage:[percetangeValueArray objectAtIndex:i]];
            
            return;
        }
    }
    
}



- (IBAction)saveReportingData:(id)sender
{
    
    NSLog(@"Reporting button did click");
    //Check if string is valid
    if ([areaInfestedTextView.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Area infested is missing" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    //Verify the area infested digit is 4 or under
    if (areaInfestedTextView.text.length > 4){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Area infested max digit is 4" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //Before proceeding, check for GPS
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
    //Create datetime
    NSDate *now = [NSDate date];
    
    
    //Add attributes to storage object
    WLDataStorage *storage = [[WLDataStorage alloc] initWithUDID:[[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"] PercentSeen:self.percentage DateTime:now latitude:self.coordinates.latitude longitude:self.coordinates.longitude areaValue:areaInfestedTextView.text areaType:[areaSelectionValues objectAtIndex:self.areaSelectionIndex] notes:userNoteTextView.text notesPlaceHolderText:placeholderNoteText base64Image:b64EncString treatment:[treatmentSelectedButton currentTitle]];
    [storage setDelegate:self];
    
    
    
    //Spin activity indicator
    [activityIndicator startAnimating];
    [activityIndicator setHidden:NO];
    
    [saveButton setEnabled:NO];
    
    //Store attributes on phone
    [storage serializeAndStoreLog];
}

- (IBAction)areaInfestedButtonOnClick:(id)sender {
    [ActionSheetStringPicker showPickerWithTitle:@"Select the Area" rows:[self areaSelectionTitles] initialSelection:[self areaSelectionIndex] target:self successAction:(@selector(areaInfestedWasSelected:element:)) cancelAction:nil origin:sender];
}

- (IBAction)treatmentButtonOnClick:(id)sender {
    NSLog(@"Treatment Button CLICKED");
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select the Treatment Given" rows:self.treatmentSelectionTitles initialSelection:self.treatmentSelectionIndex target:self successAction:(@selector(treatmentButtonWasSelected:element:)) cancelAction:nil origin:sender];
}

- (IBAction)treatmentHelpButtonOnClick:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"What treatment, if any, was conducted?" message:nil delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)percentHelpButtonOnClick:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"How much of the area you see is covered by Wavyleaf?" message:nil delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}
















-(void)treatmentButtonWasSelected:(NSNumber *)selectedIndex element:(id)element
{
    //Grab index
    self.treatmentSelectionIndex = [selectedIndex intValue];
    
    //Set title
    [treatmentSelectedButton setTitle:[[self treatmentSelectionTitles] objectAtIndex:self.treatmentSelectionIndex] forState:UIControlStateNormal];
    
    NSLog(@"Selection: %@", [treatmentSelectionTitles objectAtIndex:self.treatmentSelectionIndex]);
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



- (void)doneEditingText //Rewrite to split it half (called by note & infested text box)
{
    //Add placeholder text back
    // only if user did not enter anything
    if ([areaInfestedTextView isFirstResponder]){
        
        [areaInfestedTextView resignFirstResponder];
        
    } else if ([userNoteTextView isFirstResponder]){
        
        //take away keyboard screen
        [userNoteTextView resignFirstResponder];
    }
}



- (void)keyboardWillHide:(NSNotification *)notification
{
    //Set screen down
    [self moveTextFieldsUp:false];
    
    //Hide the toolbar below keyboard
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect frame = keyboardToolbar.frame;
    frame.origin.y = self.view.frame.size.height;
    keyboardToolbar.frame = frame;
    
    [UIView commitAnimations];
    
    //Add placeholder text
    if ([[userNoteTextView text] isEqualToString:@""]){
        [userNoteTextView setText:placeholderNoteText];
    }
    
}



- (void)keyboardWillShow:(NSNotification *)notification
{
    //Move screen up
    [self moveTextFieldsUp:true];
    
    //Show toolbar above keyboard
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect frame = [keyboardToolbar frame];
    //260 is the height of the keyboard.. so minus it
    frame.origin.y = self.view.frame.size.height - 125.0;
    keyboardToolbar.frame = frame;
    //[self.view addSubview:keyboardToolbar];
    
    [UIView commitAnimations];
    
    //Remove placeholder text
    if ([[userNoteTextView text] isEqualToString:placeholderNoteText]){
        [userNoteTextView setText:@""];
    }
}



- (void)screenDefaults
{
    //Set placeholder text for Notes
    [userNoteTextView setText:placeholderNoteText];
    
    //Use the model's index and set the title of the button from the array
    [areaInfestedButton setTitle:[[self areaSelectionTitles] objectAtIndex:self.areaSelectionIndex] forState:UIControlStateNormal];
    //Clear area text box
    [areaInfestedTextView setText:@""];
    
    //Reset index and title of Treatment button
    self.treatmentSelectionIndex = 0;
    [treatmentSelectedButton setTitle:[[self treatmentSelectionTitles] objectAtIndex:treatmentSelectionIndex] forState:UIControlStateNormal];
    
    //Set the image to default picture
    [imageView setImage:[UIImage imageNamed:@"ic_camera.png"]];
    //Set image identifier to that of @"stockImage" --> Detect if using stock image or not by looking at images identifier
    [[imageView image] setAccessibilityIdentifier:stockImage];
    
    
}

- (void)moveTextFieldsUp:(BOOL)up
{
    CGRect newframe = self.view.frame;
    
    if (up){
        newframe.origin.y -= 133;
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = newframe;
        }];
        
    } else {
        newframe.origin.y += 133;
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = newframe;
        }];
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
-(void)processSucceeded//Data sent succeeded!
{
    [saveButton setEnabled:YES];
    
    //Generate a success popup
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your log has been successfully saved!" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    
    [activityIndicator stopAnimating];
    [activityIndicator setHidden:YES];
    
    //Dismiss the view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)processFailed//Data sent failed!
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
}

@end
