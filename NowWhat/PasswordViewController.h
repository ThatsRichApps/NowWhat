//
//  PasswordViewController.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/25/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordViewController : UIViewController <UITextFieldDelegate> {
    
    IBOutlet UITextField *passwordOne;
    IBOutlet UITextField *passwordTwo;
    IBOutlet UITextField *passwordThree;
    IBOutlet UITextField *passwordFour;
    IBOutlet UITextField *realPasswordField;
    IBOutlet UILabel *setPasswordLabel;
    IBOutlet UILabel *feedbackLabel;
    
    int retryCounter;
    
}

@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, assign) int correctPassword;

-(IBAction) typedANumber:(id) sender;
- (void) backClicked:(id)sender;

@end
