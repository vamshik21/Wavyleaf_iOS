//
//  WLNewRecordViewController.h
//  WavyLeafProject
//
//  Created by Eric Forbes on 3/16/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GoogleMaps/GoogleMaps.h>
#import "WLDataStorage.h"

#define GREEN_R 0.18
#define GREEN_G 0.567
#define GREEN_B 0.0

@interface WLNewRecordViewController : UIViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UIScrollViewDelegate, WLDataStorageDelegate>
{
    
    __weak IBOutlet UIBarButtonItem *saveButton;
    
    UIToolbar *keyboardToolbar; //Toolbar that is shown above keyboard to dismiss it
    NSArray *percetangeValueArray;//Array for available percents the user can choose
    NSString *placeholderNoteText;//Text to display as placeholder text
    UIActivityIndicatorView *activityIndicator;
    NSString *stockImage;//Detect if using stock image or not by looking at images identifier
    
    __weak IBOutlet UIButton *editMapButton;
    __weak IBOutlet UIButton *areaInfestedButton;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UILabel *latitudeLabel;
    __weak IBOutlet UILabel *longitudeLabel;
    __weak IBOutlet UITextView *userNoteTextView; //Notetext
    __weak IBOutlet UITextField *areaInfestedTextView;
    __weak IBOutlet UISegmentedControl *percentSegment;//UISegmenetedControl for Percent Picker
    __weak IBOutlet UIView *mapViewOnScreen;//Map view on XIB
    __strong GMSMapView *mapView_;//Google Maps View
    __weak IBOutlet UIButton *treatmentSelectedButton;

    __weak IBOutlet UISwitch *verifyCoordinateSwitch;
    
}


//Model attributes for data storage
@property (nonatomic) CLLocationCoordinate2D coordinates;//Stores the actual coordinates
@property (nonatomic) NSString *percentage;//Stores the actual percentage seen ("0%"/"1-10%"/etc)
@property (nonatomic) NSString *areatype;//Stores the actual areatype ("SM"/"SF"/"SA")


@property (nonatomic, assign) NSInteger areaSelectionIndex; //Holds current index which interacts between UIPicker and the array to set the name
@property (nonatomic) bool didAppearFromEditingScreen; //Used in viewDidAppear (come from editing screen or not)
@property (nonatomic) NSArray *areaSelectionTitles;//Array holding areavalue titles ("Square Miles")
@property (nonatomic) NSArray *areaSelectionValues;//Array holding actual areavalue values ("SM")
@property (nonatomic) NSArray *treatmentSelectionTitles;//Array holding treatment titles
@property (nonatomic) NSInteger treatmentSelectionIndex;


//Button Actions
- (IBAction)takePicture:(id)sender; //Method called by picture button on UINavigationController
- (IBAction)percentDidChange:(id)sender; //Method called by UISegmentedControl Percent Seg
- (IBAction)editMapLocation:(id)sender; //Method called by map detail disclosure button
- (IBAction)saveReportingData:(id)sender;//Method called by hitting the 'Save' button
- (IBAction)areaInfestedButtonOnClick:(id)sender;//Method called when user selects area infested
- (IBAction)treatmentButtonOnClick:(id)sender;//When user clicks treatment button
- (IBAction)treatmentHelpButtonOnClick:(id)sender;
- (IBAction)percentHelpButtonOnClick:(id)sender;



- (void)doneEditingText;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;

- (void)updateMapUI; //Updates UI elements associating with Google Maps/Colocation
- (void)refreshScreenWithNewDefaults;
- (void)areaInfestedWasSelected:(NSNumber *)selectedIndex element:(id)element;//Called after areaInfestedButton
- (void)treatmentButtonWasSelected:(NSNumber *)selectedIndex element:(id)element;//Called after areaInfestedButton
- (void)moveTextFieldsUp:(BOOL)up;
-(BOOL)internetCheck;
-(BOOL)locationCheck;

- (void)createDataStorageObject:(NSString *)b64EncString;

@end
