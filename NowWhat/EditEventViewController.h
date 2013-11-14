//
//  EditEvent.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/14/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import "Event.h"
#import "TemplateEvent.h"
#import "UnmanagedEvent.h"
#import "Schedule.h"

//@class Event;
@class EditEventViewController;
@class UnmanagedEvent;

@protocol EditEventViewControllerDelgate <NSObject>

- (void)editEventView:(EditEventViewController *)controller didChangeTime:(NSDate *)newDate;
- (void)editEventView:(EditEventViewController *)controller addEvent:(UnmanagedEvent *)unmanagedEvent;
- (void)editEventView:(EditEventViewController *)controller editEvent:(UnmanagedEvent *)unmanagedEvent;


@end


@interface EditEventViewController : UITableViewController {
    
    UIDatePicker *timePicker;
    IBOutlet UITextField *eventField;
    IBOutlet UITextField *dateField;
    IBOutlet UITextView *notesView;
    IBOutlet UITextField *endDateField;
    IBOutlet UILabel *endDateLabel;
    
    NSString *eventText;
    NSString *eventNotes;
    NSDate *eventNSDate;
    BOOL eventChecked;


}

@property (nonatomic, assign) BOOL isLocked;
    
//@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UnmanagedEvent *eventToEdit;
@property (nonatomic, retain) NSDate *baseTime;
@property (nonatomic, retain) Schedule *eventSchedule;

@property (nonatomic, weak) id <EditEventViewControllerDelgate> delegate;


- (IBAction)cancel;
- (IBAction)save;

@end
