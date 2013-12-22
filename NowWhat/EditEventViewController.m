//
//  EditEventViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 10/14/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "EditEventViewController.h"


@interface EditEventViewController ()

@end


@implementation EditEventViewController {
    

}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)setEventToEdit:(UnmanagedEvent *)newEventToEdit
{
    if (_eventToEdit != newEventToEdit) {
        _eventToEdit = newEventToEdit;
    
        eventText = self.eventToEdit.eventText;
        eventNotes = self.eventToEdit.eventNotes;
        eventNSDate = self.eventToEdit.eventTime;
        eventEndDate = self.eventToEdit.eventEndTime;

    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    NSString *eventTime;
    NSString *endTime;

    if (self.eventToEdit != nil) {
        self.title = @"Edit Event";
        self.baseTime = eventNSDate;
    
        eventTime = [Event formatEventTime:self.baseTime];
        endTime = [Event formatEventTime:eventEndDate];
        baseEndTime = eventEndDate;
        eventDuration = [eventEndDate timeIntervalSinceDate:eventNSDate];
        
    } else {
        
        self.title = @"Add Event";
        eventTime = [Event formatEventTime:self.baseTime];
        eventDuration = 3600;
        endTime = [Event formatEventTime:[self.baseTime dateByAddingTimeInterval:eventDuration]];
        baseEndTime = [self.baseTime dateByAddingTimeInterval:eventDuration];
        [eventField becomeFirstResponder];

    }
    
    //NSString *eventText = @"This is the Event Text";
    dateField.text = eventTime;
    eventField.text = eventText;
    notesView.text = eventNotes;
    endDateField.text = endTime;
    
    //NSLog(@"eventTime is %@", eventTime);
    
    // Make the UIDatePicker a popup connected to the dateField
    // create a UIPicker view as a custom keyboard view
    
    UIDatePicker *timePickerView = [[UIDatePicker alloc] init];
    
    [timePickerView setDatePickerMode:UIDatePickerModeTime];
    [timePickerView setDate:self.baseTime animated:YES];
    
    timePicker = timePickerView;
    
    // set it to update the time field every time it's changed
    [timePicker addTarget:self action:@selector(doneStartClicked:) forControlEvents:UIControlEventValueChanged];
    
    dateField.inputView = timePicker;
    
    //NSDate *newDate = [oldDate dateByAddingTimeInterval:hrs*60*60];
    // Now setup the end time picker
    
    UIDatePicker *timeEndPickerView = [[UIDatePicker alloc] init];
    
    [timeEndPickerView setDatePickerMode:UIDatePickerModeTime];
    [timeEndPickerView setDate:baseEndTime animated:YES];
    
    timeEndPicker = timeEndPickerView;
    
    // set it to update the time field every time it's changed
    [timeEndPicker addTarget:self action:@selector(doneEndClicked:) forControlEvents:UIControlEventValueChanged];
    
    endDateField.inputView = timeEndPicker;
    
 
    if (_isLocked) {
        
        self.title = @"Event Details";
        
        // lock all the fields
        [notesView setEditable:NO];
        [eventField setEnabled:NO];
        [dateField setEnabled:NO];
        [endDateField setEnabled:NO];
        
        // and hide the save button
        [self.navigationItem setRightBarButtonItem:nil];
        
    }
    
    // check to see if we want to use end times, if not don't show those fields
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    
    if (![preferences boolForKey:@"useEndTimes"]) {
    
        endDateField.hidden = YES;
        endDateLabel.hidden = YES;
    
    }
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)cancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)save
{
    
    // return an error if the field is empty
    if ([eventField.text length] == 0) {
        
        UIAlertView *emptyTextAlert;
        
        emptyTextAlert = [[UIAlertView alloc]
                          initWithTitle:@"Please enter an event name"
                          message:@""
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        
        [emptyTextAlert show];
        
        return;
        
    }

    // update master controller with new baseTime
    self.baseTime = timePicker.date;
    
    // add one second to the time, this will keep it in the correct order when adding multiple events at the same time
    self.baseTime = [self.baseTime dateByAddingTimeInterval:1];
    
    [self.delegate editEventView:self didChangeTime:self.baseTime];
    
    
    UnmanagedEvent *unmanagedEvent = [[UnmanagedEvent alloc] init];
    unmanagedEvent.eventText = eventField.text;
    unmanagedEvent.eventNotes = notesView.text;
    unmanagedEvent.eventTime = timePicker.date;
    unmanagedEvent.eventEndTime = timeEndPicker.date;
    
    // check if event was edited or added
    if (self.eventToEdit != nil) {

        [self.delegate editEventView:self editEvent:unmanagedEvent];
        
    } else {

        
        [self.delegate editEventView:self addEvent:unmanagedEvent];
        
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneStartClicked:(id)sender {
    
    NSLog(@"done start clicked");

    
    // write out the date in whatever format is specified in the Event formatEventTime method!
    dateField.text = [Event formatEventTime:timePicker.date];
    
    // get the current interval between start and end and preserve, it starts one hour off
    [timeEndPicker setDate:[timePicker.date dateByAddingTimeInterval:eventDuration] animated:NO];
    
    // set the end date automatically to 1 hour later
    endDateField.text = [Event formatEventTime:timeEndPicker.date];
    
    //[dateField resignFirstResponder];

}


- (void)doneEndClicked:(id)sender {
    
    NSLog(@"done end clicked");

    // write out the date in whatever format is specified in the Event formatEventTime method!
    endDateField.text = [Event formatEventTime:timeEndPicker.date];
    
    // update the event duration based upon the end time
    eventDuration = [timeEndPicker.date timeIntervalSinceDate:timePicker.date];

    
    
    //[endDateField resignFirstResponder];
    
}

- (void)notesDoneClicked:(id)sender {
    
    [notesView resignFirstResponder];
    
}



-(IBAction)dismissKeyboard {
    
    NSLog(@"dismiss keyboard");

    // if this is called from the datepickers, I need to update their text fields
    // or just do it
    //[self doneStartClicked:self];
    //[self doneEndClicked:self];
    
    [self.view endEditing:YES];
    
    //[eventField resignFirstResponder];
    //[notesView resignFirstResponder];

}


#pragma mark -
#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //[textField resignFirstResponder];

//    NSLog(@"Should return");

    return TRUE;
}


- (void) textFieldDidBeginEditing:(UITextField *)textField {

//    NSLog(@"did begin editing");
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    NSLog(@"did end editing");

    if ([textField isEqual:dateField]) {
    
        [self doneStartClicked:self];
    
    } else if ([textField isEqual:endDateField]) {
       
        [self doneEndClicked:self];
    
    }
    
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    return false;

}

// this is deprecated in ios 6, but still needed in 5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
