//
//  PasswordViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 10/25/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "PasswordViewController.h"

@interface PasswordViewController ()

@end

@implementation PasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // create unseen text field and make it first responder
    realPasswordField = [[UITextField alloc] initWithFrame:CGRectZero];
    [realPasswordField setDelegate:self];
    realPasswordField.keyboardType = UIKeyboardTypeNumberPad;
    
    [self.view addSubview:realPasswordField];
    
    [realPasswordField becomeFirstResponder];
    
    if (_isLocked) {
        
        setPasswordLabel.text = @"Enter Password to Unlock";
        feedbackLabel.text = @"Application is Locked";
        
    } else {
        
        setPasswordLabel.text = @"Type a Password to Lock";
        feedbackLabel.text = @"Application is Unlocked";
        
    }
    
    
    // Put a back button above the keyboard
    // Prepare done button
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    // Create a space to put it in the middle
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                    style:UIBarButtonItemStyleBordered target:self
                                                                   action:@selector(backClicked:)];
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:leftSpace,backButton,leftSpace, nil]];
    
    // Plug the keyboardDoneButtonView into the text field...
    realPasswordField.inputAccessoryView = keyboardDoneButtonView;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





- (void) backClicked:(id)sender {
    
    // NSLog(@"clicked back button");
    [self dismissModalViewControllerAnimated:YES];
    
}




- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    //	[textField resignFirstResponder];
    
    // NSLog(@"in text field should return");
	
    return YES;
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // NSLog(@"called should change characters");
    // NSLog(@"The values of the textfields are: '%@'%@'%@'%@'",passwordOne.text,passwordTwo.text,passwordThree.text,passwordFour.text);
    
    NSString *typedString = [textField text];
    
    typedString = [typedString stringByReplacingCharactersInRange:range withString:string];
    
    // NSLog(@"You typed in: %@",typedString);
    // NSLog(@"Correct password is: %i",correctPassword);
    
    
    NSInteger index = [typedString length];
    
    // NSLog(@"Index is:%i", index);
    
    if ([string length] == 0) {
        
        // NSLog(@"String is empty, might need to return to main screen");
        
        // We just hit the delete button, clear out the last textfield
        switch (index) {
            case 0:
                passwordOne.text = @"";
                break;
            case 1:
                passwordTwo.text = @"";
                break;
            case 2:
                passwordThree.text = @"";
                break;
            default:
                break;
                
        }
        
    }else if (index == 1) {
        
        passwordOne.text = string;
        
    } else if (index == 2) {
        
        passwordTwo.text = string;
        
    } else if (index == 3) {
        
        passwordThree.text = string;
        
    } else if (index == 4) {
        
        passwordFour.text = string;
        
        // Then we're done, type it again if needed, or compare to saved password
        
        // NSLog(@"You typed in: %@",typedString);
        // NSLog(@"Correct password is: %i",correctPassword);
        
        if (_correctPassword == 0) {
            
            _correctPassword = [typedString intValue];
            
            // NSLog(@"Correct password is now: %i", correctPassword);
            
            setPasswordLabel.text = @"Retype the Password to Confirm";
            feedbackLabel.text = @"Application Will Be Locked";
            
            
            
        } else if ((_correctPassword == [typedString intValue]) || ([typedString intValue] == 9432)) {
            // 9432 is the master password in case we forget the main password
            
            // you got it right!
            // NSLog(@"Correct Password!!");
            
            if (_isLocked) {
                
                // if it was locked, unlock it
                _isLocked = NO;
                setPasswordLabel.text = @"Enter Password to Lock";
                feedbackLabel.text = @"Application is Unlocked";
                
                [self.delegate unlockIt:self withPassword:_correctPassword];
                
                //rootView.isLocked = NO;
                
                // add the buttons here
                //[rootView createAllButtons];
                //rootView.tableView.allowsSelection = YES; // Lets cells from be selectable
                
                [self dismissModalViewControllerAnimated:YES];
                
            } else {
                
                // otherwise lock it
                _isLocked = YES;
                setPasswordLabel.text = @"Enter Password to Unlock";
                feedbackLabel.text = @"Application is Locked";
                
                
                [self.delegate lockIt:self withPassword:_correctPassword];
                /* 2013 this should all be done in a delegate method
                 
                 
                
                //rootView.isLocked = YES;
                //rootView.correctPassword = correctPassword;
                
                // clear the buttons here
                
                // get all the toolbar items and navbar items and set to nil ???
                NSMutableArray *items = [rootView.toolbarItems mutableCopy];
                [items removeAllObjects];
                [rootView setToolbarItems:nil];
                [items release];
                
                // remove the NavBar items
                
                [[rootView navigationItem] setLeftBarButtonItem:nil];
                [[rootView navigationItem] setRightBarButtonItem:nil];
                
                // just add the unlock button
                // Configure the Bottom ToolBar
                UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                
                UIBarButtonItem *lockButton = [[UIBarButtonItem alloc]
                                               initWithImage:[UIImage imageNamed:@"Locked.png"]
                                               style:UIBarButtonItemStylePlain
                                               target:rootView
                                               action:@selector(clickedLockButton:)];
                
                
                [rootView setToolbarItems:[NSArray arrayWithObjects:leftSpace, lockButton,nil]];
                
                //rootView.tableView.allowsSelection = NO; // Keeps cells from being selectable
                
                 */
                
                [self dismissModalViewControllerAnimated:YES];
                
            }
            
        } else {
            
            // so so wrong
            // NSLog(@"Wrong wrong wrong");
            
            if (_isLocked) {
                
                retryCounter++;
                
                // then do not unlock the application
                feedbackLabel.text = @"Incorrect Password, You Have One More Try";
                
                if (retryCounter >= 2) {
                    
                    [self dismissModalViewControllerAnimated:YES];
                    
                }
                
                
            } else {
                
                // then they just didn't type in the first password correctly
                _correctPassword = 0;
                setPasswordLabel.text = @"Enter Password to Lock";
                feedbackLabel.text = @"Retyped Password Did Not Match";
                
            }
            
        }
        
        //clear all the fields and make 1 the first responder again
        passwordOne.text = @"";
        passwordTwo.text = @"";
        passwordThree.text = @"";
        passwordFour.text = @"";
        realPasswordField.text = @"";
        return NO;
    }
    
    //[typedString release];
    
    return YES;
    
}
















@end
