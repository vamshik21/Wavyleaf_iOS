//
//  WLNewTripSightViewController.h
//  WavyLeafProject
//
//  Created by Eric Forbes on 5/4/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLDataStorage.h"
#import <CoreLocation/CoreLocation.h>//Import for using CLLocationCoordinate2D class

@interface WLNewTripSightViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, WLDataStorageDelegate>
{
    __weak IBOutlet UIBarButtonItem *saveButton;
    //UI Outlets Connections
    __weak IBOutlet UISegmentedControl *percentSegment;
    __weak IBOutlet UIButton *areaInfestedButton;
    __weak IBOutlet UITextField *areaInfestedTextView;
    __weak IBOutlet UIButton *treatmentSelectedButton;
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UITextView *userNoteTextView;
    //__weak IBOutlet UIToolbar *keyboardToolbar;

    UIActivityIndicatorView *activityIndicator;
    
    NSString *stockImage;//Detect if using stock image or not by looking at images identifier
    
    //Instance variables
    UIToolbar *keyboardToolbar; //Toolbar that is shown above keyboard to dismiss it
    NSArray *percetangeValueArray;//Array for available percents the user can choose
    NSString *placeholderNoteText;//Text to display as placeholder text
}




//Model attributes for data storage
@property (nonatomic) CLLocationCoordinate2D coordinates;//Stores the actual coordinates
@property (nonatomic) NSString *percentage;//Stores the actual percentage seen ("0%"/"1-10%"/etc)
@property (nonatomic) NSString *areatype;//Stores the actual areatype ("SM"/"SF"/"SA")





//Accessor Methods
@property (nonatomic, assign) NSInteger areaSelectionIndex; //Holds current index which interacts between UIPicker and the array to set the name
@property (nonatomic) NSArray *areaSelectionTitles;//Array holding areavalue titles ("Square Miles")
@property (nonatomic) NSArray *areaSelectionValues;//Array holding actual areavalue values ("SM")
@property (nonatomic) BOOL didAppearFromImagePickerController;
@property (nonatomic) NSArray *treatmentSelectionTitles;//Array holding treatment titles
@property (nonatomic) NSInteger treatmentSelectionIndex;



//UI Method Actions
- (IBAction)takePicture:(id)sender;
- (IBAction)percentDidChange:(id)sender;
- (IBAction)saveReportingData:(id)sender;
- (IBAction)areaInfestedButtonOnClick:(id)sender;
- (IBAction)treatmentButtonOnClick:(id)sender;
- (IBAction)treatmentHelpButtonOnClick:(id)sender;
- (IBAction)percentHelpButtonOnClick:(id)sender;



//Init Methods
- (id)initWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate;

//Custom Methods
- (void)areaInfestedWasSelected:(NSNumber *)selectedIndex element:(id)element;//Called after areaInfestedButton
- (void)treatmentButtonWasSelected:(NSNumber *)selectedIndex element:(id)element;//Called after areaInfestedButton
- (void)doneEditingText;//Called when keyboard is dismissed
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)screenDefaults;
- (void)moveTextFieldsUp:(BOOL)up;
-(BOOL)internetAndLocationCheck;
-(BOOL)internetCheck;
-(BOOL)locationCheck;
- (void)createDataStorageObject:(NSString *)b64EncString;

@end
