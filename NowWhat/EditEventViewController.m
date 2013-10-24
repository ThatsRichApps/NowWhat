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
    
    NSString *eventText;
    NSString *eventNotes;
    NSDate *eventNSDate;
    BOOL eventChecked;

}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)setEventToEdit:(Event *)newEventToEdit
{
    if (_eventToEdit != newEventToEdit) {
        _eventToEdit = newEventToEdit;
    
        eventText = self.eventToEdit.eventText;
        eventNotes = self.eventToEdit.eventNotes;
        eventNSDate = self.eventToEdit.eventNSDate;
        eventChecked = self.eventToEdit.eventChecked;
        self.eventSchedule = self.eventToEdit.eventSchedule;
        self.isEditEvent= true;

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
    //NSString *eventText = @"This is the Event Text";
    self.dateField.text = eventTime;
    self.eventField.text = eventText;
    self.notesView.text = eventNotes;
    
    //NSLog(@"eventTime is %@", eventTime);
    
    // Make the UIDatePicker a popup connected to the dateField
    // create a UIPicker view as a custom keyboard view
    
    UIDatePicker *timePickerView = [[UIDatePicker alloc] init];
        
    
    [timePickerView setDatePickerMode:UIDatePickerModeTime];
    [timePickerView setDate:self.baseTime animated:YES];
    
    timePicker = timePickerView;
    
    self.dateField.inputView = timePicker;
    
    
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
    _dateField.inputAccessoryView = keyboardDoneButtonView;
    
    // setup the notesView UITextiew
    [_notesView setTextAlignment:UITextAlignmentLeft];
    
    // For the border and rounded corners
    // uses quartcore framework, needs to be added to .h file and to target
    [[_notesView layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[_notesView layer] setBorderWidth:0.8];
    [[_notesView layer] setCornerRadius:10];
    
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
    
    self.notesView.inputAccessoryView = notesDoneButtonView;
    
    
    [self.eventField becomeFirstResponder];

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
    
    
    Event *event = nil;
    // check if event was edited or added
    if (self.eventToEdit != nil) {
    
        event = self.eventToEdit;

    } else {

        event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
        
    }
    
    
    event.eventText = self.eventField.text;
    event.eventNotes = self.notesView.text;
    event.eventNSDate = timePicker.date;
    event.eventDate = [Event returnDate:timePicker.date];
    event.eventChecked = self.eventToEdit.eventChecked;
    event.eventSchedule = self.eventSchedule;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
        abort();
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneClicked:(id)sender {
    // Write out the date...
    
    // get the time from the UIDate Picker
    // Get the Day for this Schedule
    NSDateFormatter *formatter;
    NSString        *timeString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    
    timeString = [formatter stringFromDate:timePicker.date];
    
    self.dateField.text = timeString;
    
    [self.dateField resignFirstResponder];
}

- (void)notesDoneClicked:(id)sender {
    
    [self.notesView resignFirstResponder];
    
}


@end
