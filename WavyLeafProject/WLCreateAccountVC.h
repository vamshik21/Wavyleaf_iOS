//
//  WLCreateAccountVC.h
//  WavyLeafProject
//
//  Created by Eric Forbes on 5/25/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLline.h"
@class WLCreateAccountExtVC;


@interface WLCreateAccountVC : UIViewController <UITextFieldDelegate>
{

    UIToolbar *keyboardToolbar; //Toolbar that is shown above keyboard to dismiss it
    
    __weak IBOutlet UITextField *birthYearLabel;
    __weak IBOutlet UITextField *nameLabel;
    __weak IBOutlet UITextField *emailLabel;

    
    NSMutableArray *yearsArray;
    bool isKeyboardOnScreen;
    __weak IBOutlet UINavigationBar *navbar;
}


- (IBAction)doneCreatingAccount:(id)sender;



//Textfield Movement
- (void)moveTextFieldsUp:(BOOL)up;


//Keyboard
- (void)doneEditingText;//Called when keyboard is dismissed
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;

//vamshi- adding Alertview 
-(void)addAlertView;

@end
