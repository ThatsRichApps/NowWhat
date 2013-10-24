//
//  EditTemplateEventViewController.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/24/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import "TemplateEvent.h"
#import "Event.h"


@class TemplateEvent;
@class EditTemplateEventViewController;

@protocol EditTemplateEventViewControllerDelgate <NSObject>

- (void)editTemplateEventView:(EditTemplateEventViewController *)controller didChangeTime:(NSDate *)newDate;

@end


@interface EditTemplateEventViewController : UITableViewController {
    
    IBOutlet UIDatePicker *timePicker;
    
}

@property (nonatomic, strong) IBOutlet UITextField *eventField;
@property (nonatomic, strong) IBOutlet UITextField *dateField;
@property (nonatomic, strong) IBOutlet UITextView *notesView;
@property (nonatomic, assign) BOOL isLocked;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) TemplateEvent *templateEventToEdit;
@property (nonatomic, retain) NSDate *baseTime;

- (IBAction)cancel;
- (IBAction)save;








@end
