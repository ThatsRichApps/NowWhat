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

@class Event;
@class EditEventViewController;

@protocol EditEventViewControllerDelgate <NSObject>

- (void)editEventView:(EditEventViewController *)controller didChangeTime:(NSDate *)newDate;

@end


@interface EditEventViewController : UITableViewController {
    
    IBOutlet UIDatePicker *timePicker;
    
}

@property (nonatomic, strong) IBOutlet UITextField *eventField;
@property (nonatomic, strong) IBOutlet UITextField *dateField;
@property (nonatomic, strong) IBOutlet UITextView *notesView;
@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, assign) BOOL isEditEvent;
    
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Event *eventToEdit;
@property (nonatomic, retain) NSDate *baseTime;
@property (nonatomic, retain) NSString *eventSchedule;

@property (nonatomic, weak) id <EditEventViewControllerDelgate> delegate;


- (IBAction)cancel;
- (IBAction)save;

@end
