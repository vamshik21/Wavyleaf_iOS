//
//  WLCreateAccountVC.m
//  WavyLeafProject
//
//  Created by Eric Forbes on 5/25/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import "WLCreateAccountVC.h"
#import "WLAccountExtendedVC.h"

@interface WLCreateAccountVC ()

@end

@implementation WLCreateAccountVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.navigationItem setTitle:@"Create Account"];
        UIBarButtonItem *bbitem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneCreatingAccount:)];
        [self.navigationItem setRightBarButtonItem:bbitem];

        
        //Create the underline (actually a view)
        //X ----->
        //Y down
        //Width
        //Height
        WLline *myLine = [[WLline alloc] initWithFrame:CGRectMake(20, 117, 280, 2.2)];
        [[self view] addSubview:myLine];
        
        //Default keyboard is not on screen
        isKeyboardOnScreen = false;
        
        
        //Set Delegates of UITextFields
        [nameLabel setDelegate:self];
        [birthYearLabel setDelegate:self];
        [emailLabel setDelegate:self];
        
        
  
        
        //Create a toolbar above the keyboard with a button that dismisses the keyboard
        keyboardToolbar = [[UIToolbar alloc] init];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditingText)];
        NSArray *array = [NSArray arrayWithObject:bbi];
        [keyboardToolbar setItems:array];
        [keyboardToolbar setBarStyle:UIBarStyleDefault];
        [keyboardToolbar sizeToFit];
        
        //Set toolbar below the screen
        CGRect frame = keyboardToolbar.frame;
        frame.origin.y = self.view.frame.size.height;
        keyboardToolbar.frame = frame;
        [self.view addSubview:keyboardToolbar];
        
        
        
        
        //Create a date for the current year
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy"];
        //Convert the dateformat to an integer
        int curYear = [[dateFormat stringFromDate:[NSDate date]] intValue];
        
        //Add the years 1900 - current year in an array for easy access
        yearsArray = [[NSMutableArray alloc] init];
        for (int i = 1900; i <= curYear; i++) {
            [yearsArray addObject:[NSString stringWithFormat:@"%d", i]];
        }

     

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addAlertView];// vamshi
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    //Add the notifications that will respond to the keyboard opening/closing
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.25098 green:0.501961 blue:0.1 alpha:1]];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //Remove the notifications that respond to keyboard opening/closing
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated
{
    //Before proceeding, check for internet
    if (![WLDataStorage checkInternet]){
        
        //Display error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This app requires an active Internet connection" message:@"Please enable in your phone's Settings" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
}







- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //Move screen up
    [self moveTextFieldsUp:TRUE];
    isKeyboardOnScreen = true;
    
    //Show toolbar above keyboard
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect frame = [keyboardToolbar frame];
    //260 is the height of the keyboard.. so minus it
    //However we move the screen up 100, so take that out of the 260
    frame.origin.y = self.view.frame.size.height - 160.0;
    keyboardToolbar.frame = frame;
    //[self.view addSubview:keyboardToolbar];
    
    [UIView commitAnimations];
    //Display Done Button
    
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //Move screen down
    [self moveTextFieldsUp:FALSE];
    //Remove Done button
    
}
- (void)moveTextFieldsUp:(BOOL)up
{
    if (!isKeyboardOnScreen) {
        CGRect newframe = self.view.frame;
        
        if (up){
            newframe.origin.y -= 100;
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame = newframe;
            }];
            
        } else {
            newframe.origin.y += 100;//133
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame = newframe;
            }];
        }
    }
    
    
    
    
}



//Called by toolbar's "Done" button
- (void)doneEditingText
{
    isKeyboardOnScreen = false;
    
    if ([birthYearLabel isFirstResponder]) {
        [birthYearLabel resignFirstResponder];
        
    } else if ([nameLabel isFirstResponder]){
        [nameLabel resignFirstResponder];
        
    } else if ([emailLabel isFirstResponder]){
        [emailLabel resignFirstResponder];
    }
    
    
    
}
- (void)keyboardWillHide:(NSNotification *)notification
{

    
    
    //Hide the toolbar below keyboard
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect frame = keyboardToolbar.frame;
    frame.origin.y = self.view.frame.size.height;
    keyboardToolbar.frame = frame;
    
    [UIView commitAnimations];
    
    //Add placeholder text --> move this to done editing text
    /*
    if ([[userNoteTextView text] isEqualToString:@""]){
        [userNoteTextView setText:placeholderNoteText];
    }
     */
}
- (void)keyboardWillShow:(NSNotification *)notification
{
    //Show toolbar above keyboard
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect frame = [keyboardToolbar frame];
    //260 is the height of the keyboard.. so minus it
    //However we move the screen up 100, so take that out of the 260
    frame.origin.y = self.view.frame.size.height - 160.0;
    keyboardToolbar.frame = frame;
    //[self.view addSubview:keyboardToolbar];
    
    [UIView commitAnimations];
    
    //Remove placeholder text
    /*
    if ([[userNoteTextView text] isEqualToString:placeholderNoteText]){
        [userNoteTextView setText:@""];
    }
     */
}



- (IBAction)doneCreatingAccount:(id)sender {

    
    //Check if birth year is valid (4 digits)
    if ([[birthYearLabel text] length] != 4){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Birth Year is Invalid" message:@"Year must be 4 digits" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    //Check if name is valid
    if  ([[nameLabel text] isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Name is Invalid" message:@"Name is a required field" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    
    //Email regex
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:emailRegex options:0 error:nil];
    NSArray *matches = [regex matchesInString:emailLabel.text options:0 range:NSMakeRange(0, emailLabel.text.length)];
    
    if ([matches count] >= 1){
        
        //Go to extended login page
        WLAccountExtendedVC *extendedAccVC = [[WLAccountExtendedVC alloc] initWithName:nameLabel.text birthYear:birthYearLabel.text emailAddress:emailLabel.text];
        [self.navigationController pushViewController:extendedAccVC animated:YES];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email is Invalid" message:@"Valid email is required" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return;
    } 

    
}


//vamshi - To display the Age verfication Alert for First time Account users
-(void)addAlertView{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                              @"Age Verification" message:@"The Institutional Review Board at Towson Univeristy requires that participants in Project Wavyleaf be 18 years of age or older.If under 18 years old you can still assist in searching for wavyleaf but will need someone over 18 to submit the data using the app. Please confirm that you are 18 years of age or older." delegate:self
                                             cancelButtonTitle:@"Under 18" otherButtonTitles:@"Over 18", nil];
    [alertView setTag:21];
    [alertView show];
}

#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:
(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            if([alertView tag] == 21){
            
                NSLog(@"Under 18 button clicked");

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"The Institutional Review Board at Towson Univeristy requires that participants in Project Wavyleaf be 18 years of age or older! \n Click Home Button to close Wavyleaf App now " delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
//             optional - add more buttons:
//            [alert addButtonWithTitle:@"OK"];
          
            [alert show];
            }
            else
             {
                 NSLog(@"Ok_Under 18 button clicked--Currently disabled");
             }
            
            
        }
            break;
        case 1:
            NSLog(@"Over 18 button clicked");
            break;
            
        default:
            break;
    }
}



@end
