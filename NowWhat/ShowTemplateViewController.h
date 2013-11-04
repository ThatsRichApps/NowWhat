//
//  ShowTemplateViewController.h
//  NowWhat
//
//  Created by Rich Humphrey on 10/23/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventCell.h"
#import "TemplateEvent.h"
#import "Event.h"
#import "UnmanagedEvent.h"
#import "Template.h"
#import "EditEventViewController.h"
#import "Schedule.h"

@interface ShowTemplateViewController : UITableViewController <NSFetchedResultsControllerDelegate, EditEventViewControllerDelgate, UITableViewDataSource, UITableViewDelegate> {
    
    
    IBOutlet UITextField *templateNameField;
    
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerTemplateEvents;

@property (nonatomic, retain) NSDate *viewNSDate;
@property (nonatomic, retain) Schedule *viewSchedule;
@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, retain) Template *templateToShow;

// baseTime is used to keep track of the time so that it can be reused every time you add or edit
// it is usually preset to 8 am, but I could probably make that a setting
@property (nonatomic, retain) NSDate *baseTime;


- (IBAction)loadTemplateEvents;

@end
