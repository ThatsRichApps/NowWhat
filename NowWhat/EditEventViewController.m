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

    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    if (self.eventToEdit != nil) {
        self.title = @"Edit Event";
        self.baseTime = eventNSDate;
        
    } else {
        
        self.title = @"Add Event";
        
    }
    
    NSString *eventTime = [Event formatEventTime:self.baseTime];
    
    NSString *endTime = [Event formatEventTime:[self.baseTime dateByAddingTimeInterval:60*60]];
    
    
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
    
    dateField.inputView = timePicker;
    
    
    //NSDate *newDate = [oldDate dateByAddingTimeInterval:hrs*60*60];
    // Now setup the end time picker
    
    UIDatePicker *timeEndPickerView = [[UIDatePicker alloc] init];
    
    [timeEndPickerView setDatePickerMode:UIDatePickerModeTime];
    [timeEndPickerView setDate:[self.baseTime dateByAddingTimeInterval:60*60] animated:YES];
    
    timeEndPicker = timeEndPickerView;
    
    endDateField.inputView = timeEndPicker;
    
    
    // create a done view + done button, attach to it a doneClicked action, and place it in a toolbar as an accessory input view...
    // Prepare done button
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    // Create a space to put it in the middle
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStyleBordered target:self
                                                                   action:@selector(doneClicked:)];
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:leftSpace,doneButton,leftSpace, nil]];
    
    // Plug the keyboardDoneButtonView into the text field...
    dateField.inputAccessoryView = keyboardDoneButtonView;
    
    
    
    
    
    
    
    // setup the notesView UITextiew
    [notesView setTextAlignment:UITextAlignmentLeft];
    
    // For the border and rounded corners
    // uses quartcore framework, needs to be added to .h file and to target
    [[notesView layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[notesView layer] setBorderWidth:0.8];
    [[notesView layer] setCornerRadius:10];
    
    //[notesView setText:thisEvent.eventNotes];
    
    // Add the same type of done button to the UITextView's keyboard
    UIToolbar* notesDoneButtonView = [[UIToolbar alloc] init];
    notesDoneButtonView.barStyle = UIBarStyleBlack;
    notesDoneButtonView.translucent = YES;
    notesDoneButtonView.tintColor = nil;
    [notesDoneButtonView sizeToFit];
    
    UIBarButtonItem* notesDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                         style:UIBarButtonItemStyleBordered target:self
                                                                        action:@selector(notesDoneClicked:)];
    
    [notesDoneButtonView setItems:[NSArray arrayWithObjects:leftSpace,notesDoneButton,leftSpace, nil]];
    
    notesView.inputAccessoryView = notesDoneButtonView;
    
    // commented out - make the user click it, it works better that way
    // maybe on add??
    //[self.eventField becomeFirstResponder];

    if (_isLocked) {
        
        // lock all the fields
        [notesView setEditable:NO];
        [eventField setEnabled:NO];
        [dateField setEnabled:NO];
        
        // and hide the save button
        [self.navigationItem setRightBarButtonItem:nil];
        
    }
    
    // check to see if we want to use end times, if not don't show those fields
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    
    if (![preferences boolForKey:@"useEndTimes"]) {
    
        endDateField.hidden = YES;
        endDateLabel.hidden = YES;
    
    }
    
    
    
    
    
    
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
    
    // update master controller with new baseTime
    self.baseTime = timePicker.date;
    [self.delegate editEventView:self didChangeTime:self.baseTime];
    
    
    UnmanagedEvent *unmanagedEvent = [[UnmanagedEvent alloc] init];
    unmanagedEvent.eventText = eventField.text;
    unmanagedEvent.eventNotes = notesView.text;
    unmanagedEvent.eventTime = timePicker.date;
    
    // check if event was edited or added
    if (self.eventToEdit != nil) {

        [self.delegate editEventView:self editEvent:unmanagedEvent];
        
    } else {

        
        [self.delegate editEventView:self addEvent:unmanagedEvent];
        
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneClicked:(id)sender {
    
    // write out the date in whatever format is specified in the Event formatEventTime method!
    dateField.text = [Event formatEventTime:timePicker.date];
    
    /*// get the time from the UIDate Picker
    // Get the Day for this Schedule
    NSDateFormatter *formatter;
    NSString        *timeString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    
    timeString = [formatter stringFromDate:timePicker.date];
    
    self.dateField.text = timeString;
    */
    
    [dateField resignFirstResponder];

}

- (void)notesDoneClicked:(id)sender {
    
    [notesView resignFirstResponder];
    
}


@end
